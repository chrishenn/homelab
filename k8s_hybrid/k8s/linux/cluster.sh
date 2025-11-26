#!/bin/bash

function modcfg {
	# ensure that required networking modules are loaded on boot
	cat <<-END | sudo tee /etc/modules-load.d/k8s.conf
		overlay
		br_netfilter
	END

	# load these modules now
	sudo modprobe overlay
	sudo modprobe br_netfilter
}

function netcfg {
	# sysctl params required by setup, so that params persist across reboots
	cat <<-END | sudo tee /etc/sysctl.d/k8s.conf
		net.ipv4.ip_forward = 1
	END

	# apply sysctl params without reboot
	sudo sysctl --system
}

function aptcfg {
	# prereqs
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y conntrack glibc-source curl apt-transport-https ca-certificates gpg gnupg2 \
		software-properties-common sd
}

function swapcfg {
	# disable swap. reboot needed after if you had had swap enabled
	sudo swapoff -a                             # Disable all devices marked as swap in /etc/fstab
	sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab # Comment the swap mounting point
	sudo systemctl mask swap.target             # disable across reboot
}

function misccfg {
	# disable firewall
	sudo ufw disable

	# time server
	sudo apt install systemd-timesyncd
	sudo timedatectl set-ntp true
	sudo timedatectl status
}

function editor_nano {
	# set editor to nano instead of default vim
	if ! grep -q 'export EDITOR=nano' ~/.bashrc; then
		echo 'export EDITOR=nano' | tee -a ~/.bashrc
		. ~/.bashrc
	fi
}

function cluster_init {
	kube_ver=${1}
	pod_cidr=${2}
	svc_cidr=${3}
	socket=${4}

	sudo kubeadm init --kubernetes-version="$kube_ver" --pod-network-cidr="$pod_cidr" --service-cidr="$svc_cidr" \
		--cri-socket="$socket"
}

function copy_cfg {
	# configure kubectl for this user on this cluster
	mkdir -p "$HOME/.kube"
	sudo cp -f /etc/kubernetes/admin.conf "$HOME/.kube/config"
	sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"
}

function untaint {
	# remove taints on control-plane nodes
	kubectl taint nodes --all node-role.kubernetes.io/control-plane-
	kubectl label nodes --all node.kubernetes.io/exclude-from-external-load-balancers-
}

function join_node {
	# on control plane:
	# kubeadm token create --print-join-command

	# paste the join command as printed on the worker node
	# worker will show as NotReady until cni is installed (next step)
	echo ""
}

####

function node_test {
	docker run -it --rm --privileged --net=host \
		-v /:/rootfs -v "$HOME/.kube/config":/etc/kubernetes/admin.conf -v ./log:/var/result \
		registry.k8s.io/node-test:0.2
}

function watch_pod {
	watch -n 1 kubectl get pods -A -o wide
}

function watch_node {
	watch -n 1 kubectl get nodes -o wide
}

function watch_svc {
	watch -n 1 kubectl get svc --all-namespaces -o wide
}

function force_delete {
	kubectl delete --force <thing >--grace-period=0
}

function see_pod_cidr {
	kubectl -n kube-system get configmap kubeadm-config -o yaml | grep podSubnet
}

function coredns_bounce {
	kubectl delete pods -n kube-system -l k8s-app=kube-dns --grace-period=0 --force
}

function logs_deploy {
	kubectl logs -l app= <deployment-label >-n <namespace >--all-containers=true
}

function infodump {
	kubectl cluster-info dump
}

function describe {
	kubectl describe node name
	kubectl describe pod name -n kube-system
	kubectl logs name -n kube-system
	kubectl get events
	kubectl describe installation default
	kubectl api-resources
	kubectl describe tigerastatus apiserver
	kubectl describe APIServer
	kubectl describe cm kubeadm-config -n kube-system
}

function kubeproxy {
	kubectl describe daemonset kube-proxy -n kube-system
}

function cluster_ips {
	hostip="$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')"
	echo "hostip: $hostip"

	POD_CIDR=$(kubectl cluster-info dump | grep -m 1 -Po '(?<=--cluster-cidr=)[0-9.\/]+')
	SVC_CIDR=$(kubectl cluster-info dump | grep -m 1 -Po '(?<=--service-cluster-ip-range=)[0-9.\/]+')
	echo "POD_CIDR: $POD_CIDR"
	echo "SERVICE_CIDR: $SERVICE_CIDR"

	APISERVER_ADDR=$(kubectl get endpointslice kubernetes -n default -o jsonpath='{.endpoints[0].addresses[0]}')
	APISERVER_PORT=$(kubectl get endpointslice kubernetes -n default -o jsonpath='{.ports[0].port}')
	echo "APISERVER_ADDR: $APISERVER_ADDR"
	echo "APISERVER_PORT: $APISERVER_PORT"
}
