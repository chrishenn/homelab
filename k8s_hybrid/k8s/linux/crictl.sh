#!/bin/bash

function crictl_install() {
	ver=${1}
	arch=${2}
	socket=${3}

	url="https://github.com/kubernetes-sigs/cri-tools/releases/download/"
	curl -L "${url}v${ver}/crictl-v${ver}-linux-${arch}.tar.gz" | sudo tar -C /usr/local/bin -xz

	cat <<-EOF | sudo tee /etc/crictl.yaml >/dev/null
		runtime-endpoint: ${socket}
		image-endpoint: ${socket}
		timeout: 2
		debug: false
		pull-image-on-create: false
	EOF
}
