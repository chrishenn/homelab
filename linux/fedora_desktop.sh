#!/bin/bash

sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

# fedora atomic init config

# we must do rpm-ostree overlays for 1password and chrome for them to integrate correctly
# use zentool to install zen - works perfectly with 1pass integraton
# aurora ships firefox as a flatpak, so that's a no-go (would need to uninstall and use overlay)

function flatpak_install {
	# fedora atomic (ships with flatpak, flathub, and flatseal)
	flatpak install -y flathub \
		md.obsidian.Obsidian \
		io.github.cboxdoerfer.FSearch \
		com.prusa3d.PrusaSlicer \
		com.github.wwmm.easyeffects \
		org.onlyoffice.desktopeditors \
		org.kde.kdenlive \
		com.belmoussaoui.Obfuscate \
		io.gitlab.adhami3310.Converter \
		org.audacityteam.Audacity \
		org.darktable.Darktable

	flatpak uninstall -y \
		org.mozilla.Thunderbird \
		org.kde.skanpage \
		org.kde.okular \
		org.kde.kontact \
		org.kde.kclock

	# flatpak fix: a bunch didn't launch ootb due to file perm issue
	systemctl --user restart xdg-document-portal.service
}

function chezmoi_mise {
	# careful bootstrap order here, else you'll hit github rate limit
	curl https://mise.run | sh

	# is this going to break jetbrains integration?
	# brew install mise

	mise use -g chezmoi
	eval $(mise activate bash)

	export OP_SERVICE_ACCOUNT_TOKEN=$(op read op://homelab/svc/credential)
	export GITHUB_TOKEN=$(op read op://homelab/github/credential)
	chezmoi init --apply chrishenn
	mise i
}

function installs {
	# aurora builtins
	sudo ujust devmode
	# sudo ujust dx-group
	# ujust --choose
	# ujust aurora-cli

	# uv
	curl -LsSf https://astral.sh/uv/install.sh | sh

	# pixi
	curl -fsSL https://pixi.sh/install.sh | sh

	# soar
	wget -qO- "https://raw.githubusercontent.com/pkgforge/soar/main/install.sh" | sh
	# manual install for these needed for some reason, even though it's in the soar packages file from dotfiles
	soar sync
	soar install ghostty localsend helium-browser
	soar apply -y

	# brew (ships with fedora atomics)
	brew install git-lfs atuin parallel 7-zip trash-cli

	# zed
	curl -f https://zed.dev/install.sh | sh

	# op
	curl -Lo op.rpm https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm
	sudo rpm-ostree install op.rpm
	rm op.rpm

	# you might need to reboot before doing this install
	# sudo nano /etc/yum.repos.d/1password.repo
	# set gpg_check=0
	# sudo rpm-ostree install 1password 1password-cli

	# kvantum
	sudo rpm-ostree install kvantum

	# nvidia container toolkit (shipped installed ootb! but this config step is required)
	sudo nvidia-ctk runtime configure --runtime=docker
	sudo systemctl restart docker
	# test:
	# docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
}

function gclone {
	# depends on chezmoi, mise tools, and other tools (def brew) being bootstrapped
	sudo chmod +x ~/.gclone.sh
	~/.gclone.sh
}

function proton_vpn {
	# this did work - no guarantees about these breaking updates though

	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-vpn-local-agent/python3-proton-vpn-local-agent-1.6.2-1.fc44.x86_64.rpm"
	curl -Lo python3-proton-vpn-local-agent.rpm $url

	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-core/python3-proton-core-0.7.4-1.fc44.noarch.rpm"
	curl -Lo python3-proton-core.rpm $url

	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-keyring-linux/python3-proton-keyring-linux-0.2.1-1.fc44.noarch.rpm"
	curl -Lo python3-proton-keyring-linux.rpm $url

	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-vpn-api-core/python3-proton-vpn-api-core-5.1.2-1.fc44.noarch.rpm"
	curl -Lo python3-proton-vpn-api-core.rpm $url

	url="https://repo.protonvpn.com/fedora-44-stable/proton-vpn-daemon/proton-vpn-daemon-0.13.7-1.fc44.noarch.rpm"
	curl -Lo proton-vpn-daemon.rpm $url

	url="https://repo.protonvpn.com/fedora-44-stable/proton-vpn-gtk-app/proton-vpn-gtk-app-4.16.2-1.fc44.noarch.rpm"
	curl -Lo proton-vpn-gtk-app.rpm $url

	url="https://repo.protonvpn.com/fedora-44-stable/proton-vpn-gnome-desktop/proton-vpn-gnome-desktop-0.10.1-1.fc44.noarch.rpm"
	curl -Lo proton-vpn-gnome-desktop.rpm $url

	sudo rpm-ostree install python3-proton-vpn-local-agent.rpm python3-proton-core.rpm python3-proton-keyring-linux.rpm \
		python3-proton-vpn-api-core.rpm proton-vpn-daemon.rpm proton-vpn-gtk-app.rpm proton-vpn-gnome-desktop.rpm

	# oh ffs. so you would need to ostree-install the repo pkg, then reboot, then ostree-add the actual pkg, then reboot again!
	# rn=$(cat /etc/fedora-release | cut -d' ' -f 3)
	# curl -Lo proton.rpm "https://repo.protonvpn.com/fedora-$rn-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.4-1.noarch.rpm"
	# sudo rpm-ostree install proton.rpm
	# rm proton.rpm
	# reboot
	# sudo rpm-ostree install proton-vpn-gnome-desktop
	# reboot
}

function chrome {
	url="https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-148.0.7778.167-1.x86_64.rpm"
	curl -Lo chrome.rpm $url
	sudo rpm-ostree install chrome.rpm
	rm chrome.rpm
}

function nfs {
	# all nfs rdma packages/modules are shipped with aurora ootb!
	# mounting to /mnt/* works, but displays as /var/mnt/* in dolphin, and shows up twice
	sudo mkdir -p /var/mnt/h /var/mnt/k /var/mnt/f /var/mnt/q /var/mnt/r
	sudo tee -a /etc/fstab >/dev/null <<-END
		192.168.1.142:/var/mnt/h /var/mnt/h nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
		192.168.1.142:/var/mnt/k /var/mnt/k nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
		192.168.1.142:/var/mnt/f /var/mnt/f nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
		192.168.1.142:/var/mnt/q /var/mnt/q nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
		192.168.1.142:/var/mnt/r /var/mnt/r nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
	END
	sudo systemctl daemon-reload
	sudo mount -a
}

function power_shortcuts {
	# untested. not sure aurora will invoke a script from absolute path?
	sudo chmod +x $REPO/linux/power_shortcuts/power_shortcuts.sh
	$REPO/linux/power_shortcuts/power_shortcuts.sh
}

function sudo_timeout {
	tmp=$sdir/tmp
	sudo rm -f $tmp
	echo "Defaults timestamp_timeout=180" | tee -a $tmp
	sudo chmod 0440 $tmp

	if ! sudo visudo -c -q $tmp; then
		echo "ERROR: visudo syntax check failed on temporary file. Exiting without writing to permanent file"
		exit 1
	fi

	dst=/etc/sudoers.d/sudo_timeout
	echo "copying $tmp to $dst"
	sudo cp $tmp $dst
	sudo rm -f $tmp
}
