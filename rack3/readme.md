# Pulumi Talos K8s cluster on {Rack2, Rack3}

control planes: {rack3}
workers: {rack2}

---

# todo

- [x] kludgy secrets handling reading from env vars - use native op pulumi provider
    - see "notes on secrets" below
- [x] parse pulumi config into dataclasses/pydantic models instead of raw dicts
- [x] add worker node
    - wow that was easy. Just booted the machine, added the data in the config.json, and ran `pulumi up`
- [x] upgrade talos installed disk images
    - [x] add required extensions for longhorn
    - [x] add required longhorn data path mounts, kernel modules required for longhorn V2 data engine
- [x] longhorn
- [x] metallb
- [x] traefik
    - [x] letsencrypt certs working (local storage)
    - [x] secure headers
    - [x] ingressroute for longhorn dash
    - [x] ingressroute for traefik dash
- [x] cert-manager
    - [x] integrate with traefik
- [x] nvidia gpu
- [x] loosen seccomp
- [ ] autoscaler
    - https://docs.siderolabs.com/kubernetes-guides/advanced-guides/hpa
    - https://docs.siderolabs.com/kubernetes-guides/monitoring-and-observability/deploy-metrics-server

apps

- [ ] pangolin
    - [ ] pangolin
    - [x] newt
- [x] uptime-kuma
- [ ] beszel (https://beszel.dev/guide/advanced-deployment)
    - [ ] beszel server
    - [x] beszel agents for each node
    - [x] gpu monitoring
- [ ] local container registry pull-through cache
    - [x] docker's official registry (hosted on rack4 compose)
    - [ ] configure talos clients to use the cache
- [ ] oath2-proxy + pocketid
- [ ] grafana/loki
    - https://github.com/timothystewart6/launchpad/tree/152d6bbcba239f98ea8cfa136a98841dc3cd30cd/kubernetes/kube-prometheus-stack
- [ ] plane (https://github.com/makeplane/plane)
- [ ] spegel (https://docs.siderolabs.com/kubernetes-guides/advanced-guides/spegel)
- [ ] gitops
    - forgejo repo
    - argo? something auto-deploys the cluster with pulumi, and the apps into the cluster

annoyances

- [x] traefik chart values podAntiAffinity don't put one replica on each node like I expected
    - fixed - hadn't successfully untainted the control-plane rack3
- [x] traefik: bump the read/write/send timeouts as on rack4
    - copy/paste from rack4 traefik static cfg to helm chart values
- [ ] figure out how to bring control plane nodes up without the noschedule taint (must apply on first boot)

more

- [ ] hybridize cluster with cloud machines
    - https://github.com/exivity/pulumi-hcloud-k8s
    - add Ray (or newer compute clustering) https://docs.siderolabs.com/kubernetes-guides/advanced-guides/kuberay
- [ ] hybridize cluster with a windows worker
- [ ] boot a prod cluster in addition to the current dev cluster
- [ ] add another CNI?
    - the default CNI on talos is flannel. is that enough for what I need?
    - calico https://docs.siderolabs.com/kubernetes-guides/cni/deploy-calico
    - cilium https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium
    - https://oneuptime.com/blog/post/2026-03-03-configure-pod-and-service-subnets-in-talos-linux/view

---

# manual steps

## talos image

https://factory.talos.dev/

- grab a talos linux iso from their "image factory"
- iscsi-tools and util-linux-tools are required for Longhorn storage

hit the image factory api with the yml above, and get the image id in response. The image id goes in the image url

```bash
# rack2: longhorn
# edf8010de70681c30908eca8ff474bd551034a6a1161c3f3072db3d86d5ee096
curl -X POST --data-binary @talos/image_rack2.yml https://factory.talos.dev/schematics

# rack3: longhorn, nvidia
# a3a30b1e9dac52323f3febbe27c6693562874ff8a86f805719652db4f88cb9d6
curl -X POST --data-binary @talos/image_rack3.yml https://factory.talos.dev/schematics

# image url and pxe url formats
# factory.talos.dev/metal-installer/9de1ae6b78074fa02f9bff05757590503aa86bdbb3814f0e460b13781b7b0cb3:v1.12.5
# https://pxe.factory.talos.dev/pxe/9de1ae6b78074fa02f9bff05757590503aa86bdbb3814f0e460b13781b7b0cb3/v1.12.5/metal-amd64
```

The doc is extremely unclear, but it seems that extensions are not built into the downloaded iso. You have to spec the
image that will be installed to disk when running the machine configuration apply patch (I've added to pulumi).
Adding the image to the pulumi Resource and running pulumi up does not seem to run the upgrade after the machine has
run the configuration path and rebooted (presumably the image install only applies when first booted from iso, because
the image you spec is then installed to disk).

So I ran a manual upgrade to install an image with the patches included

```bash
talosctl upgrade -n $rack3 --image "factory.talos.dev/metal-installer/a3a30b1e9dac52323f3febbe27c6693562874ff8a86f805719652db4f88cb9d6:v1.12.5"
talosctl upgrade -n $rack2 --image "factory.talos.dev/metal-installer/edf8010de70681c30908eca8ff474bd551034a6a1161c3f3072db3d86d5ee096:v1.12.5"
```

---

env setup

```bash
pulumi new
pulumi plugin install resource talos
```

boot from iso. grab ip from kvm gui. then

```bash
# populate the node ip and disk name into the config
talosctl get disks --insecure --nodes $rack3
talosctl get ethtool --insecure --nodes $rack3

# 'health' won't work for worker nodes (?). instead use dashboard
talosctl -n $rack3 health
talosctl dashboard

# node info and actions
talosctl -n $rack3 g rd
talosctl -n $rack3 g ethtool
talosctl -n $rack3 reboot
talosctl shutdown

# see current talos machine configuration
talosctl -n $rack3 get mc -o yaml
```

taint

```bash
# manual untaint control plane nodes. had to specify the node names to untaint
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes rack3 node-role.kubernetes.io/control-plane:NoSchedule-

# check taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
kubectl describe node rack3 | grep -A5 Taints

# patch taint - the delete will only succeed once, while the label it deletes exists. duplicated in pulumi code
talosctl patch mc -n $rack3 --patch talos/taint.yml

# delete pods that are not running
kubectl delete pods --field-selector status.phase!=Running
```

longhorn

```bash
# pods look identical to the install documentation: https://longhorn.io/docs/1.11.0/deploy/install/install-with-helm/
k -n longhorn-system get pod

# quick n dirty test: forward service port to localhost and view longhorn dash on http://localhost:8080
k port-forward service/longhorn-frontend 8080:80 -n longhorn-system
```

traefik

```bash
# this is for traefik's built-in letsencrypt SSL from cloudflare - replacing this later with cert-manager
kubectl create secret generic cloudflare-credentials \
    --namespace traefik-system \
    --from-literal=token=$(op read "op://homelab/cloudflare/token")

# verify that traefik's loadbalancer service has an external IP from metallb (should see EXTERNAL_IP)
k get svc -n traefik-system
```

cert-manager

```bash
kubectl create secret generic cloudflare-credentials \
    --namespace cert-manager \
    --from-literal=token=$(op read "op://homelab/cloudflare/token")

# check for the certificates resource. If the READY field is False, the certificate has not been issued yet
k get -n default certificates
```

newt

```bash
kubectl create secret generic newt-cred -n newt --from-env-file=<(fnox export -P newt --no-defaults | sd 'export ' '' | sd "'" '')
```

nvidia

```bash
# the gpu operator does not currently work, although that should change soon
# Talos 1.13 now ships /etc/ld.* files, so this might not be a problem anymore, the gpu operator works now
# https://github.com/NVIDIA/k8s-dra-driver-gpu/pull/695

# dra does not appear to work, because nvidia-smi and other nvidia libs are in nonstandard paths

# verify that modules are loaded
t -n $rack3 read /proc/modules | grep nvidia
# nvidia_uvm 2232320 0 - Live 0x0000000000000000 (PO)
# nvidia_drm 151552 0 - Live 0x0000000000000000 (PO)
# nvidia_modeset 1908736 2 nvidia_drm, Live 0x0000000000000000 (PO)
# drm_ttm_helper 12288 1 nvidia_drm, Live 0x0000000000000000
# nvidia 111489024 8 nvidia_uvm,nvidia_drm,nvidia_modeset, Live 0x0000000000000000 (PO)

t get extensions -n $rack3 | grep nvidia
# 192.168.1.29   runtime     ExtensionStatus   4             1         nonfree-kmod-nvidia-lts        580.126.16-v1.12.5
# 192.168.1.29   runtime     ExtensionStatus   5             1         nvidia-container-toolkit-lts   580.126.16-v1.18.2

# check node labels from node discovery
kubectl label nodes rack2 nvidia.com/gpu.deploy.operands=false
kubectl label nodes rack2 nvidia.com/gpu.deploy.driver=false
kubectl get node rack3 -o json | jq '.metadata.labels | to_entries[] | select(.key | startswith("nvidia.com"))'
kubectl get node rack2 -o json | jq '.metadata.labels | to_entries[] | select(.key | startswith("nvidia.com"))'

kubectl run \
  nvidia-test \
  --restart=Never \
  -ti --rm \
  --image nvcr.io/nvidia/cuda:12.5.0-base-ubuntu22.04 \
  --overrides '{"spec": {"runtimeClassName": "nvidia"}}' \
  nvidia-smi
```

secrets

- pulumi 1password provider
    - not great. Items only - have to access by vault and uuid, can't just grab from secret ref.
- pulumi secrets provider
    - rigid. Can't have secrets embedded into nested configuration objects without them being wholly decrypted into
      plaintext, or the whole configuration object is encrypted

Trying out something like this. We'll see how it goes

```bash
# quotes are not allowed; spaces are fine in values for 'key=value w space'
kubectl create secret generic dev-secrets --from-env-file=<(fnox export | sd 'export ' '' | sd "'" '')
kubectl delete secret dev-secrets
```

---

# notes

- talos endpoint format: https://192.168.1.29:6443
- The halt_if_installed kernel flag will block a new disk install when booted from iso. This adds an extra step if you're
  debugging your infra stack - to reset the host for a new k8s bootstrap, you'll need to boot from iso and select
  the "reset disk" option

### pxe booting

ipxe script - this worked on the first try, somehow. That NEVER happens. I booted to netbootxyz, selected "ipxe shell",
and typed the following. It downloaded from image factory and booted.

The download is slow - I'd probably prefer to boot from an iso next time when I have physical usb access to the machine.
Still, pretty cool

```bash
chain https://pxe.factory.talos.dev/pxe/cdd6d87822ad5fcd18092af75a54ffd803b9d6e44027deab63b2e26ddbc41a4c/v1.12.4/metal-amd64
```

### booter

- https://github.com/siderolabs/booter
- run booter in a container on the host network
- then, power on machines in the same subnet as booter with UEFI PXE boot enabled
- recommended boot order: disk, then pxe network
- ?? it's not really clear what will happen next - presumably, booter sniffs pxe traffic, then serves your preferred
  talos image to any pxe-booting machine?
- presumably, you would need to configure DHCP to hand out the booter's IP as the `next_machine` or whatever it is

```docker
# to serve this schematic with booter
 docker run --rm --network host ghcr.io/siderolabs/booter:v0.3.0 --talos-version=v1.12.4 --schematic-id=cdd6d87822ad5fcd18092af75a54ffd803b9d6e44027deab63b2e26ddbc41a4c
```

---

# ref

metallb

- https://oneuptime.com/blog/post/2026-03-03-set-up-metallb-with-talos-linux/view
- https://oneuptime.com/blog/post/2026-01-07-metallb-traefik-ingress/view

traefik, longhorn

- https://docs.siderolabs.com/kubernetes-guides/advanced-guides/deploy-traefik
- https://github.com/traefik/traefik-helm-chart/blob/master/EXAMPLES.md
- https://github.com/Pittinic/pulumi-traefik-k8s
- https://longhorn.io/docs/1.11.0/deploy/accessing-the-ui/longhorn-httproute/

cert-manager

- https://cert-manager.io/v1.1-docs/installation/kubernetes/
- https://doc.traefik.io/traefik/v3.4/user-guides/cert-manager/
- https://community.hetzner.com/tutorials/howto-k8s-traefik-certmanager
- https://ruan.dev/blog/2023/12/22/how-to-use-cert-manager-dns-challenge-with-cloudflare-on-kubernetes-with-helm

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

possible hybrid clustering

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
- https://docs.siderolabs.com/talos/v1.12/networking/kubespan
