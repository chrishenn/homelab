# https://github.com/kubernetes/kubernetes/releases/latest
kube_ver="1.33.3"

# https://github.com/kubernetes-sigs/cri-tools/releases/latest
crictl_ver="1.33.0"

# https://github.com/projectcalico/calico/releases/latest
calico_ver="3.30.2"

# https://github.com/containerd/containerd/releases/latest
containerd_ver="2.1.4"

# https://github.com/Mirantis/cri-dockerd/releases/latest
cri_dockerd_ver="0.3.18"

# https://github.com/opencontainers/runc/releases/latest
runc_ver="1.3.0"

# container runtime socket location
socket="unix:///var/run/cri-dockerd.sock"

# host arch
arch="amd64"

# network cidrs
pod_cidr="192.168.2.0/24"
svc_cidr="10.96.0.0/12"
