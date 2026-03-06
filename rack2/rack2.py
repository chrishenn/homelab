import pulumi

import pulumi
import pulumiverse_talos as talos

import json
import yaml

CLUSTER_NAME = "test-cluster"
NODE_IP = "192.168.122.241"

# To get disks: `talosctl get disks --insecure --nodes <IP>`
MAIN_DISK = "/dev/vdb"

# ---
# Initialize Talos & Kubernetes Secrets
# ---
secrets = talos.machine.Secrets("secrets")

# ---
# Configure cluster
# ---
machine_configuration = talos.machine.get_configuration_output(
    cluster_name=CLUSTER_NAME,
    machine_type="controlplane",
    cluster_endpoint=f"https://{NODE_IP}:6443",
    machine_secrets=secrets.machine_secrets.apply(
        lambda ms: {
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
    ),
)

configuration_apply = talos.machine.ConfigurationApply(
    "configurationApply",
    client_configuration=secrets.client_configuration,
    machine_configuration_input=machine_configuration.machine_configuration,
    node=NODE_IP,
    config_patches=[
        json.dumps(
            {
                "machine": {
                    "install": {
                        "disk": MAIN_DISK,
                    },
                },
            }
        )
    ],
)

# ---
# Bootstrap cluster
# ---
bootstrap = talos.machine.Bootstrap(
    "bootstrap",
    node=NODE_IP,
    client_configuration=secrets.client_configuration,
    opts=pulumi.ResourceOptions(depends_on=[configuration_apply]),
)


# ---
# Retrieve TALOSCONFIG
# ---
def write_talosconfig(
    client_configuration: talos.machine.outputs.ClientConfiguration,
    context_name: str = "default",
):

    talosconfig_dict = {
        "context": context_name,
        "contexts": {
            context_name: {
                "endpoints": [NODE_IP],
                "nodes": [NODE_IP],
                "ca": client_configuration.ca_certificate,
                "crt": client_configuration.client_certificate,
                "key": client_configuration.client_key,
            }
        },
    }

    with open(".secrets/talosconfig", "w") as file_handle:
        yaml.dump(talosconfig_dict, file_handle, default_flow_style=False)


secrets.client_configuration.apply(write_talosconfig)

# ---
# Retrieve KUBECONFIG
# ---

kubeconfig = talos.cluster.Kubeconfig(
    "kubeconfig",
    client_configuration=secrets.client_configuration,
    node=NODE_IP,
    endpoint=NODE_IP,
)

kubeconfig.kubeconfig_raw.apply(
    lambda kubeconfig_raw: open(".secrets/kubeconfig", "w").write(kubeconfig_raw)
)


# Export the raw kubeconfig string to Pulumi outputs
pulumi.export("kubeconfig", kubeconfig.kubeconfig_raw)
pulumi.export("clientConfiguration", secrets.client_configuration)