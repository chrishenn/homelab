#!/bin/bash

function status() {
	for name in "$@"; do
		echo "${name}" "$(systemctl is-active "${name}")" "$(systemctl is-enabled "${name}")"
	done | column -t | grep --color=always '\(disabled\|inactive\|$\)'
}

function verify() {
	printf "\n---->kubelet, containerd"
	printf "\n---->note: kubelet will crashloop until cluster init \n"
	status kubelet containerd
	printf "\n---->crictl \n"
	crictl --version
	printf "\n---->containerd \n"
	containerd --version
	printf "\n---->runc \n"
	runc --version
	printf "\n---->kubectl \n"
	kubectl version --client
	printf "\n---->kubeadm \n"
	kubeadm version
	printf "\n---->kubelet \n"
	kubelet --version
	printf "\n---->kernel module: overlay \n"
	sudo lsmod | grep overlay
	printf "\n---->kernel module: netfilter \n"
	sudo lsmod | grep br_netfilter
	printf "\n---->modules/k8s.conf \n"
	cat /etc/modules-load.d/k8s.conf
	printf "\n---->sysctl/k8s.conf \n"
	cat /etc/sysctl.d/k8s.conf
	printf "\n---->networkmanager/.../calico.conf \n"
	cat /etc/NetworkManager/conf.d/calico.conf
	printf "\n---->free memory: swap should be disabled \n"
	free -m
	printf "\n"
}
