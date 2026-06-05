# Pulumi Talos K8s cluster on {Rack2, Rack3}

- control planes: {rack3}
- workers: {rack2}

---

# todo

- [x] kludgy secrets handling reading from env vars - use native op pulumi provider
    - see "notes on secrets" below
- [x] parse pulumi config into dataclasses/pydantic models instead of raw dicts
- [x] add worker node
    - wow that was easy. Just booted the machine, added the data in the config.json, and ran `pulumi up`
- [x] upgrade talos installed disk images
    - [x] add required extensions for longhorn, nvidia
    - [x] add required longhorn data path mounts, kernel modules required for longhorn V2 data engine
- [x] longhorn
- [x] metallb
- [x] traefik
    - [x] letsencrypt certs working (local storage for testing)
    - [x] secure headers
    - [x] ingressroutes for apps
- [x] SSL/https automation via
    - [x] cert-manager
    - [x] traefik
- [x] nvidia gpu via nvidia operator
- [x] static IP assignments via network NIC mac addresses
- [ ] connect longhorn storage to the newt connector
- [ ] spec the metallb loadbalancer ip and ip pool in the pulumi config, or config.json
    - [ ] use pulumi to define the metallb ip pool in pool.yml
    - [ ] use pulumi to define the metallb loadbalancer ip in traefik helm values.yml
    - [ ] use pulumi to add a dns record to for the loadbalancer ip

apps

- [x] traefik dashboard
- [x] longhorn dashboard
- [x] whoami
- [x] uptime-kuma
- [x] newt (exposes cluster as a site to my existing pangolin server on vps0)
    - pangolin operator coming in the next few weeks! https://github.com/home-operations/pangolin-operator
- [ ] beszel
    - [x] beszel agents for each node
    - [x] gpu monitoring on gpu nodes
    - [ ] beszel server
    - [ ] helm chart with pod monitoring coming soonish: https://github.com/henrygd/beszel/pull/1586
- [ ] local container registry pull-through cache
    - [x] registry service is up (hosted on rack4 compose)
    - [ ] configure talos clients to use the cache
        - https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/images-container-runtime/pull-through-cache
- [ ] oath2-proxy + pocketid
- [ ] grafana/loki
    - https://github.com/timothystewart6/launchpad/tree/152d6bbcba239f98ea8cfa136a98841dc3cd30cd/kubernetes/kube-prometheus-stack
- [ ] plane (https://github.com/makeplane/plane)
- [ ] spegel (https://docs.siderolabs.com/kubernetes-guides/advanced-guides/spegel)
- [ ] gitops
    - forgejo repo
    - argo? something auto-deploys the cluster with pulumi, and the apps into the cluster
- [ ] https://github.com/kite-org/kite
- [ ] autoscaler
    - https://docs.siderolabs.com/kubernetes-guides/advanced-guides/hpa
    - https://docs.siderolabs.com/kubernetes-guides/monitoring-and-observability/deploy-metrics-server

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

- longhorn requires:
    - iscsi-tools
    - util-linux-tools
- nvidia requires:
    - nvidia-open-gpu-kernel-modules
    - nvidia-container-toolkit

```bash
# hit the image factory api with a yml def, and get the image id in response

# rack2: longhorn
curl -X POST --data-binary @talos/image_rack2.yml https://factory.talos.dev/schematics

# rack3: longhorn, nvidia
curl -X POST --data-binary @talos/image_rack3.yml https://factory.talos.dev/schematics

# image url and pxe url formats:
# factory.talos.dev/metal-installer/<imgid>:v1.13.0
# https://pxe.factory.talos.dev/pxe/<imgid>/v1.13.0/metal-amd64
```

I had an outdated image_id/spec in the initial talos machine config.
So I ran a manual upgrade to install an image with the patches included:

```bash
talosctl upgrade -n $rack3 --image "factory.talos.dev/metal-installer/9a0cbf0604c695d9a60e3f140da8a9558b514f14d797abcb939192e3eb5e9783:v1.13.0"
talosctl upgrade -n $rack2 --image "factory.talos.dev/metal-installer/a4b64fe7fc7fac8e76ea7f1952cea3b797e20adb7c4b562cd1f7f33155255343:v1.13.0"
```

---

boot from iso. grab ip from kvm gui. then

```bash
# populate the node ip, network interface mac address, and disk name into the config
talosctl get disks --insecure --nodes $rack3
talosctl get ethtool --insecure --nodes $rack3
talosctl get links --insecure -n $rack3

# 'health' only works for control plane nodes. Use talos dashboard to see all node status in cluster:
talosctl -n $rack3 health
talosctl dashboard

# node info, resource descriptors, builtin verbs
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
talosctl patch mc -n $rack3 --patch talos/taint2.yml

# delete pods that are not running
kubectl delete pods --field-selector status.phase!=Running -A

# this taint is due to cordoning
# Taints:             node.kubernetes.io/unschedulable:NoSchedule
# Unschedulable:      true
# uncordon with:
k uncordon rack3
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
# testing only: this is for traefik's built-in letsencrypt SSL from cloudflare - replacing this later with cert-manager
# kubectl create secret generic cloudflare-credentials \
#     --namespace traefik-system \
#     --from-literal=token=$(op read "op://homelab/cloudflare/token")

# verify that traefik's loadbalancer service has an external IP from metallb (should see EXTERNAL_IP)
k get svc -n traefik-system
```

cert-manager

```bash
# todo: you have to create the namespace before you can put the secret there - do this in pulumi code if possible
kubectl create secret generic cloudflare-credentials \
    --namespace cert-manager \
    --from-literal=token=$(op read "op://homelab/cloudflare/token")

# check for the certificates resource. If the READY field is False, the certificate has not been issued yet
k get -n default certificates
```

newt

```bash
# todo: you have to create the namespace before you can put the secret there - do this in pulumi code if possible
k delete secret newt-cred -n newt
kubectl create secret generic newt-cred -n newt --from-env-file=<(fnox export -P newt --no-defaults | sd 'export ' '' | sd "'" '')
```

nvidia

```bash
# verify that modules are loaded
talosctl -n $rack3 read /proc/modules | grep nvidia
talosctl get modules -n $rack3 | grep nvidia
# nvidia
# nvidia_drm
# nvidia_modeset
# nvidia_uvm

talosctl get extensions -n $rack3 | grep nvidia
# 192.168.1.29   runtime     ExtensionStatus   4             1         nonfree-kmod-nvidia-lts        580.126.16-v1.12.5
# 192.168.1.29   runtime     ExtensionStatus   5             1         nvidia-container-toolkit-lts   580.126.16-v1.18.2

# check node labels from node discovery
kubectl get node rack2 -o json | jq '.metadata.labels | to_entries[] | select(.key | startswith("nvidia.com"))'
kubectl get node rack3 -o json | jq '.metadata.labels | to_entries[] | select(.key | startswith("nvidia.com/gpu.present"))'
kubectl get node rack3 -o json | jq '.metadata.labels | to_entries[] | select(.key | startswith("nvidia.com/gpu.product"))'

# manually add node labels - the gpu operator should do this automatically
# kubectl label nodes rack2 nvidia.com/gpu.deploy.operands=false
# kubectl label nodes rack2 nvidia.com/gpu.deploy.driver=false

# test. you should see the nvidia-smi output in the pod logs
kf nvidia_/test.yml
k logs pod/nvsmi
kd nvidia_/test.yml

# test2: vectoradd output in logs
kf nvidia_/test2.yml
k logs pod/nvadd
kd nvidia_/test2.yml
```

pangolin (newt)

I was able to expose a service running in my talos cluster by manually defining a public resource in my pangolin server
web console. The newt "site" connector running in the cluster can reach any service, but services in a different namespace
must be addressed with this format:

`service-name.namespace-name.svc.cluster.local`
eg:
`uptime-kuma.kuma.svc.cluster.local`

I tried to pass my containerd socket to the newt connector through its helm chart's values (/var/containerd/containerd.sock);
it looks like newt tried to connect to it over http and failed? Not sure.

The newt chart's values.yaml says in its readme that it can be configured with env vars, but I couldn't get them to work.
Possibly because I'm applying the chart throug pulumi? Not sure. Adding the newt site with a provisioning token did work,
but I need to connect it to persistent storage. As it is, the newt site re-provisions as a new site when I recreate it.

---

secrets

- pulumi 1password provider
    - not great. Items only - have to access by vault and uuid, can't just grab from secret ref.
- pulumi secrets provider
    - rigid. Can't have secrets embedded into nested configuration objects without them being wholly decrypted into
      plaintext, or the whole configuration object is encrypted

Trying out something like this. We'll see how it goes

```bash
# quotes are not allowed; spaces are fine in values for 'key=value w space'
kubectl create secret generic dev-secrets -n beszel --from-env-file=<(fnox export | sd 'export ' '' | sd "'" '')
kubectl delete secret dev-secrets
```

outputs recovery

imagine you've deleted your kubeconfig and talosconfig files. what a dunce!

```bash
pulumi stack output --show-secrets kubeconfig
pulumi stack output --show-secrets clientConfiguration
```

k9s
https://www.hackingnote.com/en/cheatsheets/k9s/

```bash
# sort by namespace
shift-p
```

pulumi state taint

My newt secrets have changed, because I have new pangolin install. I've updated the secrets in my password manager,
which are put into (the shell?) practice with k delete secret / k create secret. The helm chart's values.yaml refers to
the secrets - how to force pulumi to re-create the helm release?

note: this did not work. Did I update the wrong secret?

```bash
pulumi stack graph tmp
# search file 'tmp' for newt-chart
pulumi state taint urn:pulumi:dev::rack3::kubernetes:helm.sh/v4:Chart::newt-chart
pulumi up -y
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
