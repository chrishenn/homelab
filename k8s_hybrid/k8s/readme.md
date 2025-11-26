# K8s Hybrid Cluster: Bootstrap a control plane and join a Windows worker node

---

# Problems

Status: not working. Can't figure out why kube-proxy-windows can't pull its image. Two days spent, outta gas for this.

---

I also tried doing a pod_cidr 192.168.1.0/24 that explicitly collides with my local subnet. That was also a problem,
as you would expect.

---

Ok I'm going to try to set up a pod_network subnet that is valid on my home network, routed by my router
The default pod_cidr is 192.168.0.0/16, which collides with my normal subnet 192.168.1.0/24, which makes them unroutable

There are places in the caclico script that assume the default pod_cidr, so make sure to check (maybe it's just the
svc_cidr? maybe not)

Right now the windows node is reachable by the cluster on ip 192.168.188.66, which is valid as a pod_cidr 192.168.0.
0/16 and somehow reachable from 192.168.1.65 (using a virtual nic?), but not routable from 192.168.1.0/24, nor to
the internet, where it needs to pull containers from

From the doc:
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

--service-cluster-ip-range ipNet - A CIDR notation IP range from which to assign service cluster IPs. This must not
overlap with any IP ranges assigned to nodes for pods.

Take care that your Pod network must not overlap with any of the host networks: you are likely to see problems if there
is any overlap. (If you find a collision between your network plugin's preferred Pod network and some of your host
networks, you should think of a suitable CIDR block to use instead, then use that during kubeadm init with
--pod-network-cidr and as a replacement in your network plugin's YAML).

---

That wasn't the issue. Somehow, kube-proxy-windows managed to pull the image and run the container, but only briefly.
And now we're back to square one - the pod can't pull the image.

I see this error when I manually use crictl, but also this appears in the pod logs after a while. No idea what the
issue is

```powershell
crictl pull docker.io/sigwindowstools/kube-proxy:v1.33.3-calico-hostprocess

"[E0809 01:26:00.280887    3020 log.go:32]" "PullImage from image service failed"
err="rpc error: code = Unknown desc = failed to pull and unpack image"
image="docker.io/sigwindowstools/kube-proxy:v1.33.3-calico-hostprocess"
time="2025-08-09T01:26:00-07:00"
level=fatal
msg="pulling image: failed to pull and unpack image docker.io/sigwindowstools/kube-proxy:v1.33.3-calico-hostprocess:
image verifier bindir blocked pull of docker.io/sigwindowstools/kube-proxy:v1.33.3-calico-hostprocess with
digest sha256:4b2d689bd31c320adcc68ab899e030d0c447fd7748f3707ef5fec35d6a4ff4f6 for reason: verifier calico-ipam.exe
rejected image (exit code 2): "
```

The image is pullable, so the issue must be calico-ipam.exe?

```powershell
docker pull docker.io/sigwindowstools/kube-proxy:v1.33.3-calico-hostprocess

v1.33.3-calico-hostprocess: Pulling from sigwindowstools/kube-proxy
Digest: sha256:4b2d689bd31c320adcc68ab899e030d0c447fd7748f3707ef5fec35d6a4ff4f6
Status: Image is up to date for sigwindowstools/kube-proxy:v1.33.3-calico-hostprocess
docker.io/sigwindowstools/kube-proxy:v1.33.3-calico-hostprocess
```

---

# Troubleshooting

calico windows troubleshooting
kubectl logs -f -n calico-system -l k8s-app=calico-node-windows -c felix

CompleteDeferredWork returned an error -
scheduling a retry error=have VXLAN routes but HNS network, Calico, is of wrong type: L2Bridge

https://learn.microsoft.com/en-us/virtualization/windowscontainers/container-networking/multi-subnet

I delete the HNS network, then rebooted the machine.
It pulled the kube-proxy-windows image that had been failing to pull, but then got the same error from felix

Install-Module -Name HNS -allowclobber

note the id of the network with name Calico

Get-hnsendpoint | ? Name -like "calico*"
Get-hnsnetwork | ? Name -like "calico*"

$net = get-hnsnetwork -ID 78036B15-797C-4995-A8AB-3F5CEEA01714
remove-hnsnetwork $net

Get-HNSNetwork
Get-HNSENdpoint

$sharepath = "/var/lib/kube-proxy/kubeconfig.conf"
$Acl = Get-ACL $SharePath
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("everyone","FullControl","ContainerInherit,Objectinherit","none","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl $SharePath $Acl

---

# Windows Refs

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/adding-windows-nodes/#network-config

https://docs.tigera.io/calico/latest/getting-started/kubernetes/windows-calico/operator

https://lippertmarkus.com/2022/01/22/containerd-ctr-windows/
https://github.com/lippertmarkus/containerd-installer

https://github.com/kubernetes-sigs/sig-windows-tools/blob/master/guides/guide-for-adding-windows-node.md

https://docs.tigera.io/calico/latest/getting-started/kubernetes/windows-calico/operator
https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements
https://docs.tigera.io/calico/latest/getting-started/kubernetes/windows-calico/requirements

---

# Install

```bash
# on windows node: run install.ps1; may require reboot and re-run
# need to run as Admin? not sure
# ssh Administrator@192.168.1.117
. install.ps1
win_install

# on router: nat subnets?
# ssh chris@192.168.1.1 -p 2200
. nat.sh
nat_k8s

# control plane: boot cluster
. vars.sh

. docker.sh
docker_install

. cluster.sh
modcfg
netcfg
aptcfg
swapcfg
misccfg
editor_nano

. cri_dockerd.sh
cri_dockerd_install "$cri_dockerd_ver"

. kubeadm.sh
kubeadm_install "$kube_ver"

. crictl.sh
crictl_install "$crictl_ver" "$arch"

cluster_init "$kube_ver" "$pod_cidr" "$svc_cidr" "$socket"
copy_cfg
just cfg
untaint

# coredns: containerCreating. k get node: notready

. calico.sh
calico_install "$calico_ver"
watch_calico

# wait until calico pods in calico-system namespace are up. coredns comes up. k get nodes shows "ready"

join_node
# windows node "notready"
calico_install_windows "$kube_ver"
```
