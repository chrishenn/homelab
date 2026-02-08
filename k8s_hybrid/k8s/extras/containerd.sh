#!/bin/bash

function containerd_install() {
	# NOTE: MANUAL CONTAINERD INSTALL WILL DESTROY/INTERFERE WITH DOCKER INSTALL

	# https://github.com/containerd/containerd/releases/latest
	ver=${1:-"2.1.0"}
	arch=${2:-"amd64"}
	dst=${3:-"/usr/local"}

	# download and install the latest containerd binary
	url="https://github.com/containerd/containerd/releases/download"
	release="${url}/v${ver}/containerd-${ver}-linux-${arch}.tar.gz"
	curl -L "${release}" | sudo tar -C "$dst" -xz

	# install containerd unit files
	url_unit="https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
	file_unit="/etc/systemd/system/containerd.service"
	curl -sSL "$url_unit" | sudo tee "$file_unit" >/dev/null

	sudo systemctl daemon-reload
	sudo systemctl enable --now containerd

	# create the default configuration
	sudo mkdir -p /etc/containerd
	sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
}

function containerd_apt_install() {
	# NOTE: APT CONTAINERD INSTALL WILL DESTROY/INTERFERE WITH DOCKER INSTALL

	# install containerd.io from docker project, which bundles containerd and runc
	# interchangeable with apt pkg containerd, which brings runc as a dep?
	echo "deb [signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu/ /" | sudo tee /etc/apt/sources.list.d/docker.list
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	sudo apt update
	sudo apt install -y containerd.io
	sudo apt-mark hold containerd.io

	sudo mkdir -p /etc/containerd
	sudo containerd config default | sudo tee /etc/containerd/config.toml

	sudo systemctl enable --now containerd
	sudo systemctl status containerd
}
