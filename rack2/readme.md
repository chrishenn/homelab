# Pulumi Talos

The machine is actually rack3. Try to remember to swap the folder name when pulumi won't freak out about it

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
talosctl --nodes $node0 --talosconfig=.secrets/dev/talosconfig health
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

---

# advanced booting

image schematic id

- cdd6d87822ad5fcd18092af75a54ffd803b9d6e44027deab63b2e26ddbc41a4c

ipxe script - this worked on the first try, somehow. That NEVER happens. I booted to netbootxyz, selected "ipxe shell",
and typed the following. It downloaded from image factory and booted.

The download is slow - I'd probably prefer to boot from an iso next time when I have physical usb access to the machine.
Still, pretty cool

```ipxe
chain https://pxe.factory.talos.dev/pxe/cdd6d87822ad5fcd18092af75a54ffd803b9d6e44027deab63b2e26ddbc41a4c/v1.12.4/metal-amd64
```

For the initial installation of Talos Linux (not applicable for disk image boot), add the following installer image to
the machine configuration:

- factory.talos.dev/metal-installer/cdd6d87822ad5fcd18092af75a54ffd803b9d6e44027deab63b2e26ddbc41a4c:v1.12.4

the halt_if_installed flag will block a new init when booted from iso

```yaml
customization:
    extraKernelArgs:
        - talos.halt_if_installed=0
    systemExtensions:
        officialExtensions:
            - siderolabs/amd-ucode
            - siderolabs/mellanox-mstflint
            - siderolabs/newt
            - siderolabs/nonfree-kmod-nvidia-lts
            - siderolabs/nvidia-container-toolkit-lts
    bootloader: sd-boot
```

booter

- https://github.com/siderolabs/booter
- run booter in a container on the host network
- then, power on machines in the same subnet as booter with UEFI PXE boot enabled
- recommended boot order: disk, then pxe network
- ?? it's not really clear what will happen next - presumably, booter sniffs pxe traffic, then serves your preferred
  talos image to any pxe-booting machine?

```docker
# to serve this schematic with booter
 docker run --rm --network host ghcr.io/siderolabs/booter:v0.3.0 --talos-version=v1.12.4 --schematic-id=cdd6d87822ad5fcd18092af75a54ffd803b9d6e44027deab63b2e26ddbc41a4c
```
