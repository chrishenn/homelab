import json
import os
from pathlib import Path

import pulumi
import pulumi_cloudflare as cf
import pulumiverse_talos as talos
import yaml
from cytoolz import curry, pluck
from pulumi import ResourceOptions


def cfg_talos_dump(cfg: dict, path: Path):
    with path.open("w") as f:
        yaml.dump(cfg, f, default_flow_style=False)


def cfg_talos_write(
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
    cfg_talos_dump(cfg_talos, path)


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


@curry
def boot_node(cluster: dict, node: dict):
    dnsrec = None
    if node["type"] == "controlplane":
        dnsrec = cf.DnsRecord(
            resource_name=f"dnsrec_{node['i']}",
            type="A",
            name=cluster["name"],
            content=node["ip"],
            ttl=1,
            zone_id=cluster["zoneid"],
            proxied=False,
        )
    patch = {
        "machine": {
            "install": {"disk": node["disk"]},
            "network": {"interfaces": [{"interface": node["if"], "dhcp": True}]},
        }
    }
    cfg_node = talos.machine.get_configuration_output(
        cluster_name=cluster["name"],
        machine_type=node["type"],
        cluster_endpoint=cluster["enpt"],
        machine_secrets=cluster["secrets"].machine_secrets.apply(sec_machine_fmt),
    )
    return talos.machine.ConfigurationApply(
        f"cfgapply_{node['i']}",
        client_configuration=cluster["secrets"].client_configuration,
        machine_configuration_input=cfg_node.machine_configuration,
        node=node["ip"],
        config_patches=[json.dumps(patch)],
        opts=ResourceOptions(depends_on=dnsrec),
    )


def boot_cluster(cluster: dict):
    # TODO: cf secrets - zoneid for cluster_domain
    cluster["zoneid"] = env_valid("ZONEID")
    cluster["secrets"] = talos.machine.Secrets("secrets")
    env_valid("CLOUDFLARE_API_TOKEN")

    # file paths
    sec_dir = Path(f".secrets/{cluster['name']}")
    sec_dir.mkdir(parents=True, exist_ok=True)
    paths = {
        "talos": Path(sec_dir / "talosconfig"),
        "kube": Path(sec_dir / "kubeconfig"),
    }

    # configure nodes, boot cluster
    sec = cluster["secrets"]
    cfgapps = list(map(boot_node(cluster), cluster["nodes"]))
    talos.machine.Bootstrap(
        "bootstrap",
        node=cluster["nodes"][0]["ip"],
        client_configuration=sec.client_configuration,
        opts=ResourceOptions(depends_on=cfgapps),
    )

    # write taloscfg
    ips = list(pluck("ip", cluster["nodes"]))
    sec.client_configuration.apply(lambda cc: cfg_talos_write(cc, ips, ips, paths["talos"]))

    # TODO: this is failing. I assume the cluster-endpoint is invalid, since that's the only thing that changed from the
    #   working example
    # wrong zoneid! made the entrypoint under the wrong domain
    # write kubeconfig
    cfg_kube = talos.cluster.Kubeconfig(
        "kubeconfig",
        client_configuration=sec.client_configuration,
        node=cluster["nodes"][0]["ip"],
        endpoint=cluster["enpt"],
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
