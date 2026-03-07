# Pulumi Talos K8s cluster on {Rack2, Rack3}

control planes: rack3
workers: rack2

talos

- https://docs.siderolabs.com/talos/v1.12/getting-started/getting-started
- https://oneuptime.com/blog/post/2026-03-03-manage-multiple-talos-linux-clusters/view
- https://oneuptime.com/blog/post/2026-03-03-use-pulumi-to-deploy-talos-linux-clusters/view

talos alternatives

- rancher k8s engine
    - https://www.pulumi.com/registry/packages/rke/
    - https://github.com/pulumi/pulumi-rancher2

metal machines alternatives

- proxmox VMs, where the VMs are then clustered
    - https://www.pulumi.com/registry/packages/proxmoxve/

possible hybrid cluster cloud targets

- koyeb
    - https://www.pulumi.com/registry/packages/koyeb/
- linode
    - https://www.pulumi.com/registry/packages/linode/
- aws + talos
    - https://github.com/scottslowe/talos-aws-pulumi/blob/main/main.go
- hetzner + talos
    - https://github.com/exivity/pulumi-hcloud-k8s
- google cloud
    - https://www.pulumi.com/registry/packages/gcp/

---

# todo

- [x] kludgy secrets handling reading from env vars - use native op pulumi provider
    - see "notes on secrets" below
- [x] parse pulumi config into dataclasses/pydantic models instead of raw dicts
- [x] add worker node
    - wow that was easy. Just booted the machine, added the data in the config.json, and ran `pulumi up`
- [ ] add storage
    - https://github.com/exivity/pulumi-hcloud-k8s/blob/main/pkg/k8s/charts/longhorn/longhorn.go
- [ ] hybridize cluster with cloud machines?
    - https://github.com/exivity/pulumi-hcloud-k8s
- [ ] boot a prod cluster in addition to the current dev cluster

---

# manual steps

grab a talos linux iso from their "image factory"
https://factory.talos.dev/

these last two extensions are required for Longhorn storage

```yaml
# 9de1ae6b78074fa02f9bff05757590503aa86bdbb3814f0e460b13781b7b0cb3
# https://pxe.factory.talos.dev/pxe/9de1ae6b78074fa02f9bff05757590503aa86bdbb3814f0e460b13781b7b0cb3/v1.12.4/metal-amd64
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/amd-ucode
            - siderolabs/iscsi-tools
            - siderolabs/mellanox-mstflint
            - siderolabs/newt
            - siderolabs/nonfree-kmod-nvidia-lts
            - siderolabs/nvidia-container-toolkit-lts
            - siderolabs/util-linux-tools
    bootloader: sd-boot
```

```bash
pulumi new
pulumi plugin install resource talos
uv add pulumiverse-talos
uv add pulumi-cloudflare
uv add pulumi-kubernetes
```

boot from iso. grab ip. using talosctl:

```bash
export node="192.168.1.30"
talosctl get disks --insecure --nodes $node
talosctl get ethtool --insecure --nodes $node
```

populate the node ip and disk name into the config

```bash
pulumi preview
pulumi up

export KUBECONFIG=$kcfg
export TALOSCONFIG=$tcfg

# 'health' won't work for worker nodes (?). instead use dashboard
talosctl -n $node0 health
talosctl dashboard

# see all resource definitions
talosctl -n $node0 g rd

# ethtool on node0
talosctl -n $node0 g ethtool

# reboot
talosctl -n $node0 reboot
```

---

# notes

- talos endpoint format: https://192.168.1.29:6443
- The halt_if_installed kernel flag will block a new init when booted from iso. This adds an extra step if you're
  debugging your infra stack - to reset the host for a new k8s bootstrap, you'll need to boot from iso and select
  the "reset disk" option

### notes on secrets

pulumi 1password provider not great. Items only - have to access by vault and uuid, can't just grab from secret ref.
pulumi secrets provider is rigid. Can't have secrets embedded into nested configuration objects without them being
wholly decrypted into plaintext, or the whole configuration object is encrypted

---

# pxe booting

ipxe script - this worked on the first try, somehow. That NEVER happens. I booted to netbootxyz, selected "ipxe shell",
and typed the following. It downloaded from image factory and booted.

The download is slow - I'd probably prefer to boot from an iso next time when I have physical usb access to the machine.
Still, pretty cool

```ipxe
chain https://pxe.factory.talos.dev/pxe/cdd6d87822ad5fcd18092af75a54ffd803b9d6e44027deab63b2e26ddbc41a4c/v1.12.4/metal-amd64
```

### booter

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
