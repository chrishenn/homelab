import json
from enum import StrEnum
from pathlib import Path

import pulumi
import pulumi_cloudflare as cf
import pulumiverse_talos as talos
import yaml
from pulumi import ResourceOptions
from pydantic import BaseModel


class NodeType(StrEnum):
    controlplane = "controlplane"
    worker = "worker"


class Node(BaseModel):
    nodetype: NodeType
    i: int
    ip: str
    disk: str
    ifc: str
    dhcp: bool


class Cluster(BaseModel):
    model_config = {"arbitrary_types_allowed": True}

    name: str
    domain: str
    zoneid: str
    enpt: str
    cfg_secrets: Path
    nodes: list[Node]
    secrets: talos.machine.Secrets | None

    @property
    def cfg_talos(self) -> Path:
        return self.cfg_secrets / "talosconfig"

    @property
    def cfg_kube(self) -> Path:
        return self.cfg_secrets / "kubeconfig"


class Clusters(BaseModel):
    clusters: list[Cluster]


def cfg_talos_write(cfg: dict, path: Path):
    with path.open("w") as f:
        yaml.dump(cfg, f, default_flow_style=False)


def cfg_talos_fmt_write(
    cc: talos.machine.outputs.ClientConfiguration,
    endpoints: list[str],
    nodes: list[str],
    path: Path,
    tctx: str = "default",
):
    cfg_talos = {
        "context": tctx,
        "contexts": {
            tctx: {
                "endpoints": endpoints,
                "nodes": nodes,
                "ca": cc.ca_certificate,
                "crt": cc.client_certificate,
                "key": cc.client_key,
            }
        },
    }
    cfg_talos_write(cfg_talos, path)


def sec_machine_fmt(ms: talos.machine.outputs.MachineSecretsResult):
    return {
        "certs": {
            "k8sAggregator": ms.certs.k8s_aggregator,
            "os": ms.certs.os,
            "etcd": ms.certs.etcd,
            "k8s": ms.certs.k8s,
            "k8sServiceaccount": ms.certs.k8s_serviceaccount,
        },
        "secrets": {
            "bootstrapToken": ms.secrets.bootstrap_token,
            "secretboxEncryptionSecret": ms.secrets.secretbox_encryption_secret,
        },
        "trustdinfo": ms.trustdinfo,
        "cluster": {
            "id": ms.cluster.id,
            "secret": ms.cluster.secret,
        },
    }


def node_dns(cluster: Cluster, node: Node):
    """Per Talos docs, we only need domain names for controlplane nodes
    Note that these dns records are used instead of a TCP load balancer like HAProxy, nginx, (probably) traefik
    """
    if node.nodetype != NodeType.controlplane:
        return None

    return cf.DnsRecord(
        resource_name=f"dnsrec_{node.i}",
        type="A",
        name=cluster.name,
        content=node.ip,
        ttl=1,
        zone_id=cluster.zoneid,
        proxied=False,
    )


def node_cfg(cluster: Cluster, node: Node):
    assert cluster.secrets is not None

    patch = {
        "machine": {
            "install": {"disk": node.disk},
            "network": {"interfaces": [{"interface": node.ifc, "dhcp": node.dhcp}]},
        }
    }
    nodecfg = talos.machine.get_configuration_output(
        cluster_name=cluster.name,
        machine_type=node.nodetype,
        cluster_endpoint=cluster.enpt,
        machine_secrets=cluster.secrets.machine_secrets.apply(sec_machine_fmt),
    )
    return talos.machine.ConfigurationApply(
        f"cfgapply_{node.i}",
        client_configuration=cluster.secrets.client_configuration,
        machine_configuration_input=nodecfg.machine_configuration,
        node=node.ip,
        config_patches=[json.dumps(patch)],
    )


def cluster_cfg(cluster: Cluster):
    # various resources depend on this cluster-wide set of secrets
    cluster.secrets = talos.machine.Secrets("secrets")

    # dns A records for cluster domain, configure nodes, boot cluster
    dnsrecs = [node_dns(cluster, node) for node in cluster.nodes]
    dnsrecs = [rec for rec in dnsrecs if rec is not None]
    cfgapps = [node_cfg(cluster, node) for node in cluster.nodes]
    talos.machine.Bootstrap(
        "bootstrap",
        node=cluster.nodes[0].ip,
        client_configuration=cluster.secrets.client_configuration,
        opts=ResourceOptions(depends_on=cfgapps),
    )

    # write taloscfg. NOTE: these 'endpoints' must be ips or else you get a tls error using the resulting talosconfg
    ips = [n.ip for n in cluster.nodes]
    cluster.secrets.client_configuration.apply(lambda cc: cfg_talos_fmt_write(cc, ips, ips, cluster.cfg_talos))

    # write kubeconfig. NOTE: this `endpoint` must be an ip or the cluster domain name, NOT the talos enpdpoint
    cfg_kube = talos.cluster.Kubeconfig(
        "kubeconfig",
        client_configuration=cluster.secrets.client_configuration,
        node=cluster.nodes[0].ip,
        endpoint=cluster.domain,
        opts=ResourceOptions(depends_on=dnsrecs),
    )
    cfg_kube.kubeconfig_raw.apply(lambda cfg: cluster.cfg_kube.open("w").write(cfg))

    # export data to pulumi outputs
    pulumi.export("kubeconfig", cfg_kube.kubeconfig_raw)
    pulumi.export("clientConfiguration", cluster.secrets.client_configuration)


def main():
    cfgf = Path("config.json")
    assert cfgf.exists()

    with cfgf.open() as f:
        cfg = Clusters.model_validate_json(f.read())
    list(map(cluster_cfg, cfg.clusters))


if __name__ == "__main__":
    main()
