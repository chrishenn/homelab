import json
from pathlib import Path

import pulumi
import pulumiverse_talos as talos
import yaml


def cfg_talos_fmt(
    cc: talos.machine.outputs.ClientConfiguration,
    endpoints: list[str],
    nodes: list[str],
    context_name: str = "default",
) -> dict:
    return {
        "context": context_name,
        "contexts": {
            context_name: {
                "endpoints": endpoints,
                "nodes": nodes,
                "ca": cc.ca_certificate,
                "crt": cc.client_certificate,
                "key": cc.client_key,
            }
        },
    }


def cfg_talos_write(cfg: dict, path: Path):
    with path.open("w") as f:
        yaml.dump(cfg, f, default_flow_style=False)


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


def main():
    # first, boot the node from talos linux iso. Manually find the IP and disk name
    # To get disks: `talosctl get disks --insecure --nodes <IP>`

    # data from config
    config = pulumi.Config()
    cluster_name = config.require("clusterName")
    disk = config.require("diskPath")
    node_ip = config.require("nodeIP")

    # derived consts
    cluster_endpoint = f"https://{node_ip}:6443"
    endpoints = [node_ip]
    nodes = [node_ip]

    cfgpath_talos = Path(".secrets/talosconfig")
    cfgpath_kube = Path(".secrets/kubeconfig")

    # Initialize Talos & Kubernetes Secrets
    secrets = talos.machine.Secrets("secrets")
    cfg_machine = talos.machine.get_configuration_output(
        cluster_name=cluster_name,
        machine_type="controlplane",
        cluster_endpoint=cluster_endpoint,
        machine_secrets=secrets.machine_secrets.apply(sec_machine_fmt),
    )
    cfg_apply = talos.machine.ConfigurationApply(
        "configurationApply",
        client_configuration=secrets.client_configuration,
        machine_configuration_input=cfg_machine.machine_configuration,
        node=node_ip,
        config_patches=[json.dumps({"machine": {"install": {"disk": disk}}})],
    )
    talos.machine.Bootstrap(
        "bootstrap",
        node=node_ip,
        client_configuration=secrets.client_configuration,
        opts=pulumi.ResourceOptions(depends_on=[cfg_apply]),
    )

    # write taloscfg
    cc_fmt: dict = secrets.client_configuration.apply(lambda cc: cfg_talos_fmt(cc, endpoints, nodes))
    cfg_talos_write(cc_fmt, cfgpath_talos)

    # write kubeconfig
    cfg_kube = talos.cluster.Kubeconfig(
        "kubeconfig",
        client_configuration=secrets.client_configuration,
        node=node_ip,
        endpoint=node_ip,
    )
    cfg_kube.kubeconfig_raw.apply(lambda cfg: cfgpath_kube.open("w").write(cfg))

    # Export data to Pulumi outputs
    pulumi.export("kubeconfig", cfg_kube.kubeconfig_raw)
    pulumi.export("clientConfiguration", secrets.client_configuration)


if __name__ == "__main__":
    main()
