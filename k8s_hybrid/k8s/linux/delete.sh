function iptables_reset {
	# ip config
	sudo iptables -F
	sudo iptables -X
	sudo iptables -t nat -F
	sudo iptables -t nat -X
	sudo iptables -t raw -F
	sudo iptables -t raw -X
	sudo iptables -t mangle -F
	sudo iptables -t mangle -X
}

function cni_delete {
	sudo rm -rf /opt/cni
	sudo rm -rf /etc/cni
}

function cfg_delete {
	sudo rm -rf "$HOME/.kube/"
	sudo rm -rf /etc/kubernetes
	sudo rm -rf /etc/systemd/system/etcd*
	sudo rm -rf /var/run/kubernetes
	sudo rm -rf /var/lib/kubelet
	sudo rm -rf /var/lib/etcd
	sudo rm -rf /var/etcd
	sudo rm -rf /var/lib/etcd2
	sudo rm -rf /etc/modules-load.d/k8s.conf
	sudo rm -rf /etc/sysctl.d/k8s.conf
	sudo rm -rf /etc/NetworkManager/conf.d/calico.conf
}

function rehash {
	hash -r
}

function rm_node {
	name=${1:-"rack4"}
	kubectl drain "$name" --ignore-daemonsets --delete-emptydir-data --grace-period=0 --force
	kubectl delete node "$name"
}

function del_cluster {
	sudo kubeadm reset -f --cri-socket="unix:///var/run/cri-dockerd.sock"

	iptables_reset
	cni_delete
	cfg_delete
}

##----------------------------------------------------------------------------------------------------------------------

function helm_delete {
	sudo rm -f /usr/local/bin/helm
	sudo rm -rf "$HOME/.cache/helm"
	sudo rm -rf "$HOME/.config/helm"
	sudo rm -rf "$HOME/.local/share/helm"
}

function apt_delete {
	sudo systemctl disable --now kubelet
	sudo rm -f /etc/systemd/system/kubelet.service
	sudo rm -f /etc/systemd/system/kubelet.service.d
	sudo apt purge kubeadm kubectl kubelet kubernetes-cni kube* cri-dockerd
	sudo apt autoremove --purge
}

function bin_delete {
	# binaries from manual install
	dir="/usr/local/bin"
	sudo rm -f "${dir}/kubectl"
	sudo rm -f "${dir}/crictl"
	sudo rm -f "${dir}/kubeadm"
	sudo rm -f "${dir}/kubelet"
	sudo rm -f "${dir}/kube"*
}

function del_all {
	helm_delete
	apt_delete
	bin_delete
}
