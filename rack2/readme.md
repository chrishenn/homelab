# Pulumi Talos

https://docs.siderolabs.com/talos/v1.12/getting-started/getting-started
https://oneuptime.com/blog/post/2026-03-03-manage-multiple-talos-linux-clusters/view
https://oneuptime.com/blog/post/2026-03-03-use-pulumi-to-deploy-talos-linux-clusters/view
https://github.com/scottslowe/talos-aws-pulumi/blob/main/main.go

---

grab a talos linux iso from their "image factory"
https://factory.talos.dev/

I added

- siderolabs/amd-ucode
- siderolabs/mellanox-mstflint
- siderolabs/newt
- siderolabs/nvidia-container-toolkit-lts
- siderolabs/nonfree-kmod-nvidia-lts

Ok now to figure out how to boot this thing. I think the pulumi provider will render this image schematic and configure
the initial boot with these schematics, but I don't think the example I'm using starts from that early.

I'll just download the iso, presumably with extensions built-in

---

image schematic id

- 5b6317c5bbf6b053adb1d2388e93b1dabb1959d2afe2b79b62fb7cec60d308ed

pxe script

- https://pxe.factory.talos.dev/pxe/5b6317c5bbf6b053adb1d2388e93b1dabb1959d2afe2b79b62fb7cec60d308ed/v1.12.4/metal-amd64

pxe booter

- https://github.com/siderolabs/booter
- run booter in a container on the host network
- then, power on machines in the same subnet as booter with UEFI PXE boot enabled
- recommended boot order: disk, then pxe network
- ?? it's not really clear what will happen next - presumably, booter sniffs pxe traffic, then serves your preferred
  talos image to any pxe-booting machine?

For the initial installation of Talos Linux (not applicable for disk image boot), add the following installer image to
the machine configuration:

- factory.talos.dev/metal-installer/5b6317c5bbf6b053adb1d2388e93b1dabb1959d2afe2b79b62fb7cec60d308ed:v1.12.4

```yaml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/amd-ucode
            - siderolabs/mellanox-mstflint
            - siderolabs/newt
            - siderolabs/nonfree-kmod-nvidia-lts
            - siderolabs/nvidia-container-toolkit-lts
    bootloader: sd-boot
```

---

```bash
pulumi new
pulumi plugin install resource talos
uv add pulumiverse-talos
uv add pulumi-cloudflare
```

boot from iso. grab ip. using talosctl on dev machine:

```bash
export node0="192.168.1.29"
talosctl get disks --insecure --nodes $node0
# disk: nvme0n1
```

populate the node ip and disk name (as /dev/nvme0n1) into the Pulumi.dev.yaml

```bash
pulumi preview
pulumi up
talosctl --nodes $node0 --talosconfig=.secrets/talosconfig health
KUBECONFIG=.secrets/kubeconfig kubectl get nodes

# see all resource definitions
talosctl -n $node0 --talosconfig=.secrets/talosconfig g rd

# ethtool on node0
talosctl -n $node0 --talosconfig=.secrets/talosconfig get ethtool
```

# todo

- kludgy secrets handling reading from env vars - use native op pulumi provider
- parse pulumi config into dataclasses instead of raw dicts
- add worker node
- hybridize cluster with cloud machines?
- boot a prod cluster in addition to the current dev cluster
