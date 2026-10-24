#!/bin/bash

# https://github.com/kubernetes/kubernetes/releases/latest
export kube_ver="1.33.3"

# https://github.com/kubernetes-sigs/cri-tools/releases/latest
export crictl_ver="1.33.0"

# https://github.com/projectcalico/calico/releases/latest
export calico_ver="3.30.2"

# https://github.com/containerd/containerd/releases/latest
export containerd_ver="2.1.4"

# https://github.com/Mirantis/cri-dockerd/releases/latest
export cri_dockerd_ver="0.3.18"

# https://github.com/opencontainers/runc/releases/latest
export runc_ver="1.3.0"

# container runtime socket location
export socket="unix:///var/run/cri-dockerd.sock"

# host arch
export arch="amd64"

# network cidrs
export pod_cidr="192.168.2.0/24"
export svc_cidr="10.96.0.0/12"
