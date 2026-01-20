#!/bin/bash

function docker_install() {
	curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
	rm get-docker.sh
	sudo usermod -aG docker "$USER"
}

function docker_verify() {
	docker run hello-world
}

function docker_manual_install() {
	# Add Docker's GPG key
	sudo apt update
	sudo apt install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to apt sources
	source /etc/os-release
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
		sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
	sudo apt update

	# apt install
	sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# add user to docker group
	sudo groupadd docker
	sudo usermod -aG docker "$USER"
	newgrp docker

	docker run hello-world
}

function docker_uninstall() {
	sudo apt purge -y docker-engine docker docker.io docker-ce docker-ce-cli containerd containerd.io runc --allow-change-held-packages
	sudo apt autoremove --purge -y
	sudo rm -rf /var/lib/docker /etc/docker /var/run/docker.sock
	sudo rm -f /etc/apparmor.d/docker
}
