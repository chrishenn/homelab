#!/bin/bash

function system_configs {
	# firewall
	sudo ufw disable

	# note that custom sources from manually-installed debs will not work
	sudo tee -a /etc/apt/apt.conf.d/00proxy >/dev/null <<-'END'
		Acquire::HTTP::Proxy "http://192.168.1.4:3142";
		Acquire::HTTPS::Proxy "http://192.168.1.4:3142/HTTPS";
	END

	# redis, inotify fixes
	sudo tee -a /etc/sysctl.d/99-custom.conf >/dev/null <<-'END'
		net.ipv4.ip_nonlocal_bind=1
		vm.overcommit_memory=1
		fs.inotify.max_user_watches=1014796
		fs.inotify.max_user_instances=1014796
		fs.inotify.max_queued_events=1014796
		net.ipv6.conf.all.disable_ipv6=1
	END
	sudo sysctl --system
}

function nvidia_driver_open {
	# nvidia-open: GTX 1660 and later. otherwise use nvidia-driver
	curl -Lo cuda.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
	sudo apt install -y ./cuda.deb
	sudo apt install -y nvidia-open
	rm cuda.deb
}

function docker {
	# requires logout to work
	curl -fsSL https://get.docker.com | sudo sh
	sudo usermod -aG docker "$USER"
}

function nvidia_container {
	curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg &&
		curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
		sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |
			sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
	sudo apt update && sudo apt install -y nvidia-container-toolkit
	sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
}

function package_managers {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	curl https://mise.run | sh
	curl -fsSL https://pixi.sh/install.sh | sh
	bash <(curl -fsSL https://moonrepo.dev/install/proto.sh)
	wget -qO- "https://raw.githubusercontent.com/pkgforge/soar/main/install.sh" | sh

	# requires a reboot to work
	sudo apt install -y flatpak
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

	# dra + AppImageLauncher no longer needed for appimages - use soar or AM/AppManager instead
	# brew install dra
	# sudo $(which dra) download TheAssassin/AppImageLauncher -is appimagelauncher_3.0.0-alpha-4-gha275.0bcc75d_amd64.deb
}

function tools {
	sudo apt install -y \
		"linux-headers-$(uname -r)" build-essential dkms git 7zip \
		curl openssl gawk net-tools \
		input-remapper-gtk easyeffects

	flatpak install -y flathub \
		md.obsidian.Obsidian \
		io.github.cboxdoerfer.FSearch \
		com.github.tchx84.Flatseal \
		com.obsproject.Studio \
		com.obsproject.Studio.Plugin.DroidCam \
		com.discordapp.Discord \
		dev.zed.Zed
	flatpak override --user --device=all com.obsproject.Studio

	sudo flatpak remote-add --if-not-exists signal-flatpak https://signalflatpak.github.io/signal/signal.flatpakrepo
	flatpak install -y signal-flatpak org.signal.Signal

	# albert
	echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_25.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
	curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_25.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg >/dev/null
	sudo apt update && sudo apt install -y albert

	# jetbrains toolbox
	curl -Lo pkg.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.9.0.56191.tar.gz
	tar -xvf pkg.tar.gz -C ~/.local/share
	pushd ~/.local/share/jetbrains*
	./bin/jetbrains-toolbox
	popd
	rm pkg.tar.gz

	# 1password GUI and CLI. note: other installs will not integrate with browsers
	curl -L https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb -o 1pass.deb &&
		sudo apt install -y ./1pass.deb &&
		sudo apt update &&
		sudo apt install -y 1password-cli &&
		rm 1pass.deb

	# install from mise and soar manifests
	mise i
	soar apply -y

	# vscode: deprecated for zed
	# pushd $HOME
	# curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o code.deb
	# sudo apt install -y ./code.deb
	# rm code.deb
	# popd
}

function chezmoi_init {
	$(op read "op://homelab/svc/bash")
	if [ -z $OP_SERVICE_ACCOUNT_TOKEN ]; then
		echo "chezmoi boot error: op svc token not set"
		return 1
	fi
	sh -c "$(curl -fsLS get.chezmoi.io)" -- init chrishenn --apply
}

function v4l2loopback {
	sudo apt -y install v4l2loopback-dkms v4l2loopback-utils linux-generic linux-headers-generic
	echo 'options v4l2loopback devices=6 video_nr=0,1,2,3,4,5 card_label=video0,video1,video2,video3,video4,video5 exclusive_caps=1,1,1,1,1,1' |
		sudo tee /etc/modprobe.d/v4l2loopback.conf
	echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf
	sudo modprobe -r v4l2loopback
	sudo modprobe v4l2loopback
}

function nfs {
	sudo apt install -y nfs-common
	sudo mkdir -p /mnt/h /mnt/k /mnt/f /mnt/q

	sudo tee -a /etc/fstab >/dev/null <<-'END'
	192.168.1.142:/mnt/h /mnt/h nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
	192.168.1.142:/mnt/k /mnt/k nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
	192.168.1.142:/mnt/f /mnt/f nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
	192.168.1.142:/mnt/q /mnt/q nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
	END

	sudo systemctl daemon-reload
	sudo mount -a
}

function iriun {
	cp /mnt/h/linux/iriunwebcam*.deb ./iriun.deb
	sudo apt install -y ./iriun.deb
	rm iriun.deb

	v4l2loopback
}

function theme {
	sudo apt install -y qt6-style-kvantum fonts-firacode
	# import the kvantum theme: /mnt/h/linux/utterly-sweet
	# in each themes settings section, download and apply utterly-sweet theme

	nano /home/chris/.config/Kvantum/Utterly-Sweet/Utterly-Sweet.kvconfig
	# base.color=#0a112401
	# alt.base.color=#0a112401
}

#### others
# disable apparmor using kernel param
# apparmor=0

# zen browser
# - see zen_browser/

# configs
# - settings dolphin
# - settings konsole
# - settings zen
