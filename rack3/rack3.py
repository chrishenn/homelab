import json
import os
from pathlib import Path

import pulumi
import pulumi_cloudflare as cf
import pulumiverse_talos as talos
import yaml
from cytoolz import pluck
from pulumi import ResourceOptions


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


def env_valid(name: str) -> str:
    assert name in os.environ
    val = os.environ[name]
    assert val
    return val


def dns_node(cluster: dict, node: dict):
    if node["type"] != "controlplane":
        return None

    return cf.DnsRecord(
        resource_name=f"dnsrec_{node['i']}",
        type="A",
        name=cluster["name"],
        content=node["ip"],
        ttl=1,
        zone_id=cluster["zoneid"],
        proxied=False,
    )


def cfg_node(cluster: dict, node: dict):
    patch = {
        "machine": {
            "install": {"disk": node["disk"]},
            # "network": {"interfaces": [{"interface": node["if"], "dhcp": True}]},
        }
    }
    # talos endpoint format: https://192.168.1.29:6443
    node_cfg = talos.machine.get_configuration_output(
        cluster_name=cluster["name"],
        machine_type=node["type"],
        cluster_endpoint=cluster["enpt"],
        machine_secrets=cluster["secrets"].machine_secrets.apply(sec_machine_fmt),
    )
    return talos.machine.ConfigurationApply(
        f"cfgapply_{node['i']}",
        client_configuration=cluster["secrets"].client_configuration,
        machine_configuration_input=node_cfg.machine_configuration,
        node=node["ip"],
        config_patches=[json.dumps(patch)],
    )


def boot_cluster(cluster: dict):
    # TODO: cf secrets - zoneid for cluster_domain
    cluster["zoneid"] = env_valid("ZONEID")
    cluster["secrets"] = sec = talos.machine.Secrets("secrets")
    env_valid("CLOUDFLARE_API_TOKEN")

    # file paths
    sec_dir = Path(f".secrets/{cluster['name']}")
    sec_dir.mkdir(parents=True, exist_ok=True)
    paths = {
        "talos": Path(sec_dir / "talosconfig"),
        "kube": Path(sec_dir / "kubeconfig"),
    }

    # configure nodes, dsn A records for cluster domain, boot cluster
    dnsrecs = [dns_node(cluster, node) for node in cluster["nodes"]]
    cfgapps = [cfg_node(cluster, node) for node in cluster["nodes"]]
    talos.machine.Bootstrap(
        "bootstrap",
        node=cluster["nodes"][0]["ip"],
        client_configuration=sec.client_configuration,
        opts=ResourceOptions(depends_on=cfgapps),
    )

    # write taloscfg
    # NOTE: these 'endpoints' must be ips or else you get a tls error using the resulting talosconfg
    # I do not think these can be put behind an https load balancer, though
    ips = list(pluck("ip", cluster["nodes"]))
    sec.client_configuration.apply(lambda cc: cfg_talos_fmt_write(cc, ips, ips, paths["talos"]))

    # write kubeconfig
    # NOTE: this endpoint must be an ip or the cluster endpoint domain name NOT the talos enpdpoint
    cfg_kube = talos.cluster.Kubeconfig(
        "kubeconfig",
        client_configuration=sec.client_configuration,
        node=cluster["nodes"][0]["ip"],
        endpoint=cluster["main"],
        opts=ResourceOptions(depends_on=dnsrecs),
    )
    cfg_kube.kubeconfig_raw.apply(lambda cfg: paths["kube"].open("w").write(cfg))

    # Export data to Pulumi outputs
    pulumi.export("kubeconfig", cfg_kube.kubeconfig_raw)
    pulumi.export("clientConfiguration", sec.client_configuration)


def main():
    cfg = pulumi.Config()
    clusters: list[dict] = cfg.require_object("clusters")
    list(map(boot_cluster, clusters))


if __name__ == "__main__":
    main()
