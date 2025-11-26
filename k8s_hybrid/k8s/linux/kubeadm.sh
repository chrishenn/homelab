function kubeadm_install() {
	kube_ver=${1}

	# major.minor only of kube version (so 1.33 instead of 1.33.0)
	local ver=$(echo "$kube_ver" | cut -d '.' -f 1,2)

	sudo mkdir -p /var/lib/kubelet
	sudo chmod 777 /var/lib/kubelet

	echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$ver/deb/ /" |
		sudo tee /etc/apt/sources.list.d/kubernetes.list
	curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$ver/deb/Release.key" |
		sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

	sudo apt update
	sudo apt install -y kubelet kubeadm kubectl
	sudo apt-mark hold kubelet kubeadm kubectl
	sudo systemctl enable --now kubelet
}

function kubeadm_manual_install() {
	# https://kubernetes.io/releases/
	ver="1.33.0"
	arch="amd64"
	dst="/usr/local/bin"

	# install kubeadm, kubelet
	sudo mkdir -p /var/lib/kubelet
	sudo chmod 777 /var/lib/kubelet
	sudo curl -L --remote-name-all "https://dl.k8s.io/release/v${ver}/bin/linux/${arch}/{kubeadm,kubelet}"
	sudo chmod +x {kubeadm,kubelet}
	sudo mv {kubeadm,kubelet} "${dst}"

	# install kubelet systemd unit service files.
	# template version does not appear to change
	tver="v0.16.2"
	url="https://raw.githubusercontent.com/kubernetes/release/"
	curl -sSL "${url}${tver}/cmd/krel/templates/latest/kubelet/kubelet.service" |
		sed "s:/usr/bin:${dst}:g" | sudo tee /etc/systemd/system/kubelet.service
	sudo mkdir -p /etc/systemd/system/kubelet.service.d
	curl -sSL "${url}${tver}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" |
		sed "s:/usr/bin:${dst}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

	sudo systemctl daemon-reload
	sudo systemctl enable --now kubelet
	printf "\n\n NOTE: kubectl requires reboot to work"
}

function kubectl_manual_install() {
	# https://kubernetes.io/releases/
	ver="1.33.0"
	dst="/usr/local/bin"

	# install kubectl
	curl -LO "https://dl.k8s.io/release/v${ver}/bin/linux/amd64/kubectl"
	curl -LO "https://dl.k8s.io/v${ver}/bin/linux/amd64/kubectl.sha256"
	echo "$(cat kubectl.sha256) kubectl" | sha256sum --check
	sudo install -o root -g root -m 0755 kubectl "${dst}/kubectl"
}
