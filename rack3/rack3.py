import json
import os
from enum import StrEnum, auto
from pathlib import Path

import pulumi
import pulumiverse_talos as talos
import yaml
from pulumi import Resource, ResourceOptions
from pulumi_kubernetes.core.v1 import Namespace
from pulumi_kubernetes.helm.v4 import Chart, RepositoryOptsArgs
from pulumi_kubernetes.meta.v1 import ObjectMetaArgs
from pulumi_kubernetes.yaml.v2 import ConfigGroup
from pydantic import BaseModel
from yaml import SafeLoader


def traefik_dash(deps: list[Resource]) -> list[Resource]:
    svc = ConfigGroup(
        "traefik-dash",
        files=["./traefik_/dash.yml"],
        opts=ResourceOptions(depends_on=deps),
    )
    return [svc]


def beszel(deps: list[Resource]) -> list[Resource]:
    svc = ConfigGroup(
        "beszel-app",
        files=["./app/beszel.yml"],
        opts=ResourceOptions(depends_on=deps),
    )
    return [svc]


def kuma(deps: list[Resource]) -> list[Resource]:
    svc = ConfigGroup(
        "kuma-app",
        files=["./app/kuma.yml"],
        opts=ResourceOptions(depends_on=deps),
    )
    return [svc]


def whoami(deps: list[Resource]) -> list[Resource]:
    svc = ConfigGroup(
        "whoami-app",
        files=["./app/whoami.yml"],
        opts=ResourceOptions(depends_on=deps),
    )
    return [svc]


def longhorn_dash(deps: list[Resource]) -> list[Resource]:
    svc = ConfigGroup(
        "longhorn-dash",
        files=["./app/longhorn_dash.yml"],
        opts=ResourceOptions(depends_on=deps),
    )
    return [svc]


def newt(deps: list[Resource]) -> list[Resource]:
    ns = Namespace(
        "newt-ns",
        metadata=ObjectMetaArgs(name="newt"),
    )
    chart = Chart(
        "newt-chart",
        namespace=ns.metadata.name,
        chart="newt",
        repository_opts=RepositoryOptsArgs(repo="https://charts.fossorial.io"),
        value_yaml_files=[pulumi.FileAsset("newt_/values.yml")],
        opts=ResourceOptions(depends_on=deps),
    )
    return [ns, chart]


def certmanager() -> list[Resource]:
    ns = Namespace(
        "certmanager-ns",
        metadata=ObjectMetaArgs(name="cert-manager"),
    )
    # manual application of crds is a workaround for: https://github.com/pulumi/pulumi-kubernetes/issues/3176
    crds = ConfigGroup(
        "certmanager-crds",
        files=["https://github.com/cert-manager/cert-manager/releases/download/v1.1.1/cert-manager.crds.yaml"],
    )
    chart = Chart(
        "certmanager-chart",
        namespace=ns.metadata.name,
        chart="cert-manager",
        repository_opts=RepositoryOptsArgs(
            repo="https://charts.jetstack.io",
        ),
        value_yaml_files=[pulumi.FileAsset("./certmanager/values.yml")],
        opts=ResourceOptions(depends_on=[ns, crds]),
    )
    issuer = ConfigGroup(
        "certmanager-issuer",
        files=["./certmanager/issuer.yml"],
        opts=ResourceOptions(depends_on=[ns, crds, chart]),
    )
    cert = ConfigGroup(
        "certmanager-chennio-cert",
        files=["./certmanager/chennio.yml"],
        opts=ResourceOptions(depends_on=[ns, crds, chart, issuer]),
    )
    return [ns, crds, chart, issuer, cert]


def traefik() -> list[Resource]:
    ns = Namespace(
        "traefik-ns",
        metadata=ObjectMetaArgs(name="traefik-system"),
    )
    chart = Chart(
        "traefik-chart",
        namespace=ns.metadata.name,
        chart="traefik",
        repository_opts=RepositoryOptsArgs(
            repo="https://traefik.github.io/charts",
        ),
        value_yaml_files=[
            # this filename cannot match the chart/repo name or helm will error
            pulumi.FileAsset("./traefik_/values.yml")
        ],
    )
    hdrs = ConfigGroup(
        "traefik-headers",
        files=["./traefik_/headers.yml"],
        opts=ResourceOptions(depends_on=[ns, chart]),
    )
    return [ns, chart, hdrs]


def metallb() -> list[Resource]:
    priv = {
        "pod-security.kubernetes.io/enforce": "privileged",
        "pod-security.kubernetes.io/audit": "privileged",
        "pod-security.kubernetes.io/warn": "privileged",
    }
    ns = Namespace(
        "metallb-ns",
        metadata=ObjectMetaArgs(name="metallb-system", labels=priv),
    )
    chart = Chart(
        "metallb-chart",
        namespace=ns.metadata.name,
        chart="metallb",
        repository_opts=RepositoryOptsArgs(
            repo="https://metallb.github.io/metallb",
        ),
    )
    cfg = ConfigGroup(
        "metallb-ippool-default",
        files=["./metallb_/pool.yml"],
        opts=ResourceOptions(depends_on=[ns, chart]),
    )
    return [ns, chart, cfg]


def longhorn() -> list[Resource]:
    ns = Namespace(
        "longhorn-ns",
        metadata=ObjectMetaArgs(name="longhorn-system", labels={"pod-security.kubernetes.io/enforce": "privileged"}),
    )
    chart = Chart(
        "longhorn-chart",
        namespace=ns.metadata.name,
        chart="longhorn",
        repository_opts=RepositoryOptsArgs(
            repo="https://charts.longhorn.io",
        ),
        value_yaml_files=[
            # this filename cannot match the chart/repo name or helm will error
            pulumi.FileAsset("./longhorn_/values.yaml")
        ],
    )
    return [ns, chart]


class NodeType(StrEnum):
    controlplane = "controlplane"
    worker = "worker"


class NodeCap(StrEnum):
    gpu = auto()


class Newt(BaseModel):
    pangolin_endpoint: str
    newt_id: str | None
    newt_secret: str | None


class Node(BaseModel):
    i: int
    name: str
    caps: set[NodeCap]
    nodetype: NodeType
    ip: str
    disk: str
    image: str
    ifc: str
    dhcp: bool
    newt: Newt


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
        self.cfg_secrets.mkdir(parents=True, exist_ok=True)
        return self.cfg_secrets / "talosconfig"

    @property
    def cfg_kube(self) -> Path:
        self.cfg_secrets.mkdir(parents=True, exist_ok=True)
        return self.cfg_secrets / "kubeconfig"


class Clusters(BaseModel):
    clusters: list[Cluster]


def cfg_talos_write(cfg: dict, path: Path) -> None:
    with path.open("w") as f:
        yaml.dump(cfg, f, default_flow_style=False)


def cfg_talos_fmt_write(
    cc: talos.machine.outputs.ClientConfiguration,
    endpoints: list[str],
    nodes: list[str],
    path: Path,
    tctx: str = "default",
) -> None:
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


def sec_machine_fmt(ms: talos.machine.outputs.MachineSecretsResult) -> dict:
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


def node_dns(_cluster: Cluster, _node: Node) -> None:
    """Per Talos docs, we only need domain names for controlplane nodes
    Note that these dns records are used instead of a TCP load balancer like HAProxy, nginx, (probably) traefik
    """
    # if node.nodetype != NodeType.controlplane:
    #     return None
    #
    # rec = cf.DnsRecord(
    #     resource_name=f"dnsrec_{node.i}",
    #     type="A",
    #     name=cluster.name,
    #     content=node.ip,
    #     ttl=1,
    #     zone_id=cluster.zoneid,
    #     proxied=False,
    # )
    return


def env_valid(name: str) -> str:
    assert name in os.environ
    val = os.getenv(name)
    assert val
    return val


def load_yaml(path: Path) -> dict:
    assert path.exists()
    with path.open() as f:
        return yaml.load(f, SafeLoader)


def patch_cmn(node: Node) -> str:
    patch = {
        "machine": {
            "install": {"disk": node.disk, "image": node.image},
            "network": {"interfaces": [{"interface": node.ifc, "dhcp": node.dhcp}]},
            "kubelet": {
                "extraMounts": [
                    {
                        "destination": "/var/lib/longhorn",
                        "type": "bind",
                        "source": "/var/lib/longhorn",
                        "options": ["bind", "rshared", "rw"],
                    }
                ]
            },
            "sysctls": {"vm.nr_hugepages": "1024"},
            "kernel": {
                "modules": [
                    {"name": "nvme_tcp"},
                    {"name": "vfio_pci"},
                ],
            },
        },
        "cluster": {
            "proxy": {"extraArgs": {"ipvs-strict-arp": True}},
            "allowSchedulingOnControlPlanes": True,
        },
    }
    return json.dumps(patch)


def patch_taint() -> str:
    # this delete patch will fail when the exclude label no longer exists
    patch = {
        # "machine": {
        #     "nodeLabels": {
        #         "node.kubernetes.io/exclude-from-external-load-balancers": {
        #             "$patch": "delete"
        #         }
        #     }
        # },
        "cluster": {"allowSchedulingOnControlPlanes": True}
    }
    return json.dumps(patch)


def nvidia(deps: list[Resource]) -> list[Resource]:
    ns = Namespace(
        "nvdp-ns",
        metadata=ObjectMetaArgs(name="gpu", labels={"pod-security.kubernetes.io/enforce": "privileged"}),
    )
    svc = ConfigGroup(
        "nvdp-runtimeclass",
        files=["./nvidia/class.yml"],
        opts=ResourceOptions(depends_on=deps),
    )
    chart = Chart(
        "nvdp-chart",
        chart="nvidia-device-plugin",
        namespace=ns.metadata.name,
        repository_opts=RepositoryOptsArgs(repo="https://nvidia.github.io/k8s-device-plugin"),
        value_yaml_files=[pulumi.FileAsset("nvidia/nvdp.yml")],
        opts=ResourceOptions(depends_on=svc),
    )
    return [svc, chart]


def patch_nvidia(node: Node) -> str:
    if NodeCap.gpu not in node.caps:
        return ""
    patch = {
        "machine": {
            "kernel": {
                "modules": [
                    {"name": "nvidia"},
                    {"name": "nvidia_uvm"},
                    {"name": "nvidia_drm"},
                    {"name": "nvidia_modeset"},
                ]
            },
            "sysctls": {"net.core.bpf_jit_harden": 1},
        },
    }
    return json.dumps(patch)


def node_cfg(cluster: Cluster, node: Node) -> Resource:
    assert cluster.secrets is not None

    mc = [patch_cmn(node), patch_taint(), patch_nvidia(node)]
    mc = list(filter(bool, mc))

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
        config_patches=mc,
    )


def cluster_cfg(cluster: Cluster) -> list[Resource]:
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

    # write taloscfg. these 'endpoints' must be control plane ips
    ips = [n.ip for n in cluster.nodes]
    eps = [n.ip for n in cluster.nodes if n.nodetype == NodeType.controlplane]
    cluster.secrets.client_configuration.apply(lambda cc: cfg_talos_fmt_write(cc, eps, ips, cluster.cfg_talos))

    # write kubeconfig. NOTE: this `endpoint` must be an ip or the cluster domain name, NOT the talos endpoint
    cfg_kube = talos.cluster.Kubeconfig(
        "kubeconfig",
        client_configuration=cluster.secrets.client_configuration,
        node=cluster.nodes[0].ip,
        endpoint=cluster.nodes[0].ip,
        opts=ResourceOptions(depends_on=dnsrecs),
    )
    cfg_kube.kubeconfig_raw.apply(lambda cfg: cluster.cfg_kube.open("w").write(cfg))

    # export data to pulumi outputs
    pulumi.export("kubeconfig", cfg_kube.kubeconfig_raw)
    pulumi.export("clientConfiguration", cluster.secrets.client_configuration)

    return [cluster.secrets, cfg_kube]


def cluster_val(cluster: Cluster) -> None:
    assert len(cluster.nodes) >= 1
    assert cluster.nodes[0].nodetype == NodeType.controlplane, "Node0 in any cluster must be a control plane"


def main() -> None:
    cfgf = Path("config.json")
    assert cfgf.exists()

    with cfgf.open() as f:
        cfg = Clusters.model_validate_json(f.read())

    list(map(cluster_val, cfg.clusters))
    list(map(cluster_cfg, cfg.clusters))

    svc_rscs = []
    svc_rscs.extend(longhorn())
    svc_rscs.extend(metallb())
    svc_rscs.extend(traefik())
    svc_rscs.extend(certmanager())

    nvidia(svc_rscs)
    newt(svc_rscs)
    traefik_dash(svc_rscs)
    longhorn_dash(svc_rscs)
    whoami(svc_rscs)
    kuma(svc_rscs)
    beszel(svc_rscs)


if __name__ == "__main__":
    main()
