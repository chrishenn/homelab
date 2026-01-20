#!/bin/bash

function cri_dockerd_install() {
	ver=${1}

	# install cri-dockerd, service
	pkg="cri-dockerd_$ver.3-0.debian-bookworm_amd64.deb"
	wget -O cri-dockerd.deb "https://github.com/Mirantis/cri-dockerd/releases/download/v$ver/$pkg"
	sudo apt install -y ./cri-dockerd.deb
	rm cri-dockerd.deb

	wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
	wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
	sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/

	sudo systemctl daemon-reload
	sudo systemctl enable --now cri-docker
}

function cri_dockerd_verify() {
	sudo systemctl status cri-docker
}
