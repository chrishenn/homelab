# Pulumi Talos K8s cluster on {Rack2, Rack3}

control planes: rack3
workers: rack2

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
- [x] connect newt to my pangolin instance
- [x] longhorn
- [x] metallb
- [x] traefik
    - [x] letsencrypt certs working (local storage)
    - [x] secure headers
    - [x] ingressroute for longhorn dash
    - [x] traefik: replace helm chart ingressroute for traefik dash with standalone - dedupe the secure headers

- [x] cert-manager
    - [x] integrate with traefik
- [ ] autoscaler
    - https://docs.siderolabs.com/kubernetes-guides/advanced-guides/hpa
    - https://docs.siderolabs.com/kubernetes-guides/monitoring-and-observability/deploy-metrics-server
- [ ] loosen seccomp
    - https://docs.siderolabs.com/kubernetes-guides/security/seccomp-profiles
- [ ] nvidia dra
    - https://docs.siderolabs.com/kubernetes-guides/advanced-guides/dynamic-resource-allocation

apps

- [x] uptime-kuma
- [ ] beszel (https://beszel.dev/guide/advanced-deployment)
- [ ] oath2-proxy + pocketid
- [ ] grafana/loki
    - https://github.com/timothystewart6/launchpad/tree/152d6bbcba239f98ea8cfa136a98841dc3cd30cd/kubernetes/kube-prometheus-stack
- [ ] plane (https://github.com/makeplane/plane)
- [ ] spegel (https://docs.siderolabs.com/kubernetes-guides/advanced-guides/spegel)
- [ ] gitops
    - forgejo repo
    - argo? something auto-deploys the cluster with pulumi, and the apps into the cluster

annoyances

- [ ] traefik: bump the read/write/send timeouts as on rack4
- [ ] traefik chart values podAntiAffinity don't put one replica on each node like I expected
- [ ] figure out how to bring control plane nodes up without the noschedule taint (must apply on first boot)

more

- [ ] hybridize cluster with cloud machines?
    - https://github.com/exivity/pulumi-hcloud-k8s
    - add Ray (or newer compute clustering) https://docs.siderolabs.com/kubernetes-guides/advanced-guides/kuberay
- [ ] boot a prod cluster in addition to the current dev cluster
- [ ] add another CNI?
    - the default CNI on talos is flannel. is that enough for what I need?
    - calico https://docs.siderolabs.com/kubernetes-guides/cni/deploy-calico
    - cilium https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium
    - https://oneuptime.com/blog/post/2026-03-03-configure-pod-and-service-subnets-in-talos-linux/view

---

# manual steps

https://factory.talos.dev/

- grab a talos linux iso from their "image factory"
- iscsi-tools and util-linux-tools are required for Longhorn storage

hit the image factory api with the yml above, and get the image id in response. The image id goes in the image url

```bash
curl -X POST --data-binary @images/image.yml https://factory.talos.dev/schematics
# edf8010de70681c30908eca8ff474bd551034a6a1161c3f3072db3d86d5ee096
curl -X POST --data-binary @images/image_newt.yml https://factory.talos.dev/schematics
# 4e2d8806d9ee1965e2e3513c36a65fed1964cfcc41f2e482aa158af9fe851f2b

# image url and pxe url formats
# factory.talos.dev/metal-installer/9de1ae6b78074fa02f9bff05757590503aa86bdbb3814f0e460b13781b7b0cb3:v1.12.4
# https://pxe.factory.talos.dev/pxe/9de1ae6b78074fa02f9bff05757590503aa86bdbb3814f0e460b13781b7b0cb3/v1.12.4/metal-amd64
```

The doc is extremely unclear, but it seems that extensions are not built into the downloaded iso. You have to spec the
image that will be installed to disk when running the machine configuration apply patch (I've added to pulumi).
Adding the image to the pulumi Resource and running pulumi up does not seem to run the upgrade after the machine has
run the configuration path and rebooted (presumably the image install only applies when first booted from iso, because
the image you spec is then installed to disk).

So I ran a manual upgrade to install an image with the patches included

```bash
# rack3 (control plane) gets newt; worker (rack2) does not
talosctl upgrade -n $rack3 --image "factory.talos.dev/metal-installer/4e2d8806d9ee1965e2e3513c36a65fed1964cfcc41f2e482aa158af9fe851f2b:v1.12.4"
talosctl upgrade -n $rack2 --image "factory.talos.dev/metal-installer/edf8010de70681c30908eca8ff474bd551034a6a1161c3f3072db3d86d5ee096:v1.12.4"
```

starting from the beginning

```bash
pulumi new
pulumi plugin install resource talos
uv add pulumiverse-talos
uv add pulumi-cloudflare
uv add pulumi-kubernetes
uv add pulumi_kubernetes_cert_manager
```

boot from iso. grab ip. using talosctl:

```bash
export node="192.168.1.30"
talosctl get disks --insecure --nodes $node
talosctl get ethtool --insecure --nodes $node
```

populate the node ip and disk name into the config

```bash
export KUBECONFIG=$kcfg
export TALOSCONFIG=$tcfg

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

# manual untaint control plane nodes
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

longhorn

```bash
# pods look identical to the install documentation: https://longhorn.io/docs/1.11.0/deploy/install/install-with-helm/
k -n longhorn-system get pod

# quick n dirty: forward service port to localhost and view longhorn dash on http://localhost:8080
k port-forward service/longhorn-frontend 8080:80 -n longhorn-system
```

traefik

```bash
kubectl create secret generic cloudflare-credentials \
    --namespace traefik-system \
    --from-literal=token=$(op read "op://homelab/cloudflare/token")

# verify that traefik's loadbalancer service has an external IP from metallb (should see EXTERNAL_IP)
k get svc -n traefik-system
```

cert-manager

```bash
# todo: where does this secret live? appears not to persist the way I expected (kubeconfig file?)
kubectl create secret generic cloudflare-credentials \
    --namespace cert-manager \
    --from-literal=token=$(op read "op://homelab/cloudflare/token")

# helm uninstall. you have to manually delete the cert-manager crds, else a subsequent helm install will fail
kubectl delete crd \
  issuers.cert-manager.io \
  clusterissuers.cert-manager.io \
  certificates.cert-manager.io \
  certificaterequests.cert-manager.io \
  orders.acme.cert-manager.io \
  challenges.acme.cert-manager.io

# check for the certificates resource. If the READY field is False, the certificate has not been issued yet
k get -n default certificates
```

---

# notes

- talos endpoint format: https://192.168.1.29:6443
- The halt_if_installed kernel flag will block a new disk install when booted from iso. This adds an extra step if you're
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
