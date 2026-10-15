# deprecated fedora atomic universalblue setup steps

function deprecated_rpm_install {
	# replaced with mise bootstrap
	# proton and chrome depend on repos/repo files being installed.
	# musl pkgs are needed to compile a musl target with rust from system env (my rust ide is stuck in system env)
	sudo rpm-ostree install \
		proton-vpn-gnome-desktop \
		google-chrome-stable \
		kvantum \
		firefox \
		musl-gcc musl-libc-static musl-devel
}

function deprecated_nfs_client {
	# replaced with mise bootstrap
	sudo mkdir -p /etc/fstab.d
	sudo mkdir -p /var/mnt/h /var/mnt/k /var/mnt/f /var/mnt/q /var/mnt/r

	opt="auto,nofail,soft,intr,x-systemd.automount,x-systemd.mount-timeout=1s,timeo=10,retrans=3,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime"
	sudo tee -a /etc/fstab.d/nfs >/dev/null <<-END
		192.168.1.142:/var/mnt/f /var/mnt/f nfs $opt 0 0
		192.168.1.142:/var/mnt/h /var/mnt/h nfs $opt 0 0
		192.168.1.142:/var/mnt/k /var/mnt/k nfs $opt 0 0
		192.168.1.142:/var/mnt/r /var/mnt/r nfs $opt 0 0
	END
	sudo systemctl daemon-reload
	sudo mount -a --fstab /etc/fstab.d/nfs
}

function deprecated_nfs_client_2 {
	# replaced with mise bootstrap
	# mounting to /mnt/* works, but displays as /var/mnt/* in dolphin, and shows up twice
	sudo mkdir -p /var/mnt/h /var/mnt/k /var/mnt/f /var/mnt/q /var/mnt/r
	opt="auto,nofail,soft,intr,x-systemd.automount,x-systemd.mount-timeout=1s,timeo=10,retrans=3,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime"
	sudo tee -a /etc/fstab >/dev/null <<-END
		192.168.1.142:/var/mnt/f /var/mnt/f nfs $opt 0 0
		192.168.1.142:/var/mnt/h /var/mnt/h nfs $opt 0 0
		192.168.1.142:/var/mnt/k /var/mnt/k nfs $opt 0 0
		192.168.1.142:/var/mnt/r /var/mnt/r nfs $opt 0 0
	END
	sudo systemctl daemon-reload
	sudo mount -a
}

function deprecated_chrome {
	# replaced with mise bootstrap
	sudo tee /etc/yum.repos.d/google-chrome.repo >/dev/null <<-'END'
		[google-chrome]
		name=google-chrome
		baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
		enabled=1
		gpgcheck=1
		gpgkey=https://dl.google.com/linux/linux_signing_key.pub
	END
	sudo rpm-ostree install google-chrome-stable

	# manual rpm
	url="https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-148.0.7778.167-1.x86_64.rpm"
	curl -Lo chrome.rpm "$url"
	sudo rpm-ostree install chrome.rpm
	rm chrome.rpm
}

function deprecated_zen {
	# replaced with zentool installer
	# note: this installation method DOES NOT integrate with 1password. use zentool
	sudo tee /etc/yum.repos.d/zen-browser.repo >/dev/null <<-'END'
		[zen-browser]
		name=Zen Browser
		baseurl=https://xins3c.github.io/zen-browser-rpm
		enabled=1
		gpgcheck=1
		gpgkey=https://xins3c.github.io/zen-browser-rpm/RPM-GPG-KEY-zen-browser
	END
	sudo rpm-ostree install zen-browser
}

function deprecated_chezmoi_mise {
	# replaced with mise bootstrap
	curl https://mise.run | sh
	mise use -g chezmoi
	eval "$(mise activate bash)"

	export OP_SERVICE_ACCOUNT_TOKEN=$(op read op://homelab/svc/credential)
	export GITHUB_TOKEN=$(op read op://homelab/github/credential)
	chezmoi init --apply chrishenn
	. ~/.bashrc
	mise i
}

function deprecated_protonvpn {
	# replaced with mise bootstrap
	sudo tee /etc/yum.repos.d/protonvpn-stable.repo >/dev/null <<-'END'
		[protonvpn-fedora-stable]
		name = ProtonVPN Fedora Stable repository
		baseurl = https://repo.protonvpn.com/fedora-$releasever-stable
		enabled = 1
		gpgcheck = 1
		repo_gpgcheck = 0
		skip_if_unavailable = true
		gpgkey = https://repo.protonvpn.com/fedora-$releasever-stable/public_key.asc
	END
	sudo rpm-ostree install proton-vpn-gnome-desktop

	# manual rpm
	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-vpn-local-agent/python3-proton-vpn-local-agent-1.6.2-1.fc44.x86_64.rpm"
	curl -Lo python3-proton-vpn-local-agent.rpm "$url"
	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-core/python3-proton-core-0.7.4-1.fc44.noarch.rpm"
	curl -Lo python3-proton-core.rpm "$url"
	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-keyring-linux/python3-proton-keyring-linux-0.2.1-1.fc44.noarch.rpm"
	curl -Lo python3-proton-keyring-linux.rpm "$url"
	url="https://repo.protonvpn.com/fedora-44-stable/python3-proton-vpn-api-core/python3-proton-vpn-api-core-5.1.2-1.fc44.noarch.rpm"
	curl -Lo python3-proton-vpn-api-core.rpm "$url"
	url="https://repo.protonvpn.com/fedora-44-stable/proton-vpn-daemon/proton-vpn-daemon-0.13.7-1.fc44.noarch.rpm"
	curl -Lo proton-vpn-daemon.rpm "$url"
	url="https://repo.protonvpn.com/fedora-44-stable/proton-vpn-gtk-app/proton-vpn-gtk-app-4.16.2-1.fc44.noarch.rpm"
	curl -Lo proton-vpn-gtk-app.rpm "$url"
	url="https://repo.protonvpn.com/fedora-44-stable/proton-vpn-gnome-desktop/proton-vpn-gnome-desktop-0.10.1-1.fc44.noarch.rpm"
	curl -Lo proton-vpn-gnome-desktop.rpm "$url"
	sudo rpm-ostree install \
		python3-proton-vpn-local-agent.rpm \
		python3-proton-core.rpm \
		python3-proton-keyring-linux.rpm \
		python3-proton-vpn-api-core.rpm \
		proton-vpn-daemon.rpm \
		proton-vpn-gtk-app.rpm \
		proton-vpn-gnome-desktop.rpm

	# repository package - need to reboot after installing? not sure
	rn=$(cat /etc/fedora-release | cut -d' ' -f 3)
	curl -Lo proton.rpm "https://repo.protonvpn.com/fedora-$rn-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.4-1.noarch.rpm"
	sudo rpm-ostree install proton.rpm
	rm proton.rpm
	sudo rpm-ostree install proton-vpn-gnome-desktop

	# uninstall
	sudo rpm-ostree uninstall \
		python3-proton-vpn-local-agent \
		python3-proton-core \
		python3-proton-keyring-linux \
		python3-proton-vpn-api-core \
		proton-vpn-daemon \
		proton-vpn-gtk-app \
		proton-vpn-gnome-desktop
}

function deprecated_settings_grub {
	# editing grub config is not supported on ublue-based systems per https://github.com/ublue-os/bluefin/discussions/3414

	# this does not work on fedora ublue-based systems
	sudo tee /boot/grub2/user.cfg >/dev/null <<-'END'
		set timeout_style=menu
		set timeout=3
	END

	# the correct sequence would be something like(?) not sure about this
	sudo rpm-ostree kargs --append=ostree.prepare-root.composefs=0
	reboot
	sudo grub2-editenv -set menu_auto_hide=1
	sudo grub2-mkconfig -o /etc/grub2.cfg
	reboot
	sudo rpm-ostree kargs --delete-if-present=ostree.prepare-root.composefs=0
	reboot
}

function deprecated_settings_sysctl {
	# replaced with mise bootstrap files
	sudo tee /etc/sysctl.d/99-custom.conf >/dev/null <<-'END'
		net.ipv4.ip_nonlocal_bind=1
		vm.overcommit_memory=1
		fs.inotify.max_user_watches=1014796
		fs.inotify.max_user_instances=1014796
		fs.inotify.max_queued_events=1014796
		net.ipv6.conf.all.disable_ipv6=1
	END
	sudo sysctl --system
}

function deprecated_brew {
	# automated by mise bootstrap packages
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install \
		atuin \
		parallel \
		7-zip \
		trash-cli
	brew install --cask \
		font-fira-code-nerd-font \
		font-jetbrains-mono-nerd-font
}

function deprecated_flatpak {
	# automated by mise bootstrap packages
	sudo dnf install flatpak
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

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
}

function deprecated_1password {
	# note: use the brew cask from ublue-os/tap - they automated this script with a bunch of extras

	# they broke the installer script bundled into the rpm
	# sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
	# sudo rpm-ostree install 1password 1password-cli

	# not sure I would do this?
	# curl -Lo op.rpm https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm
	# sudo rpm-ostree install op.rpm
	# rm op.rpm

	# latest stable
	# https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm
	# latest beta
	# https://downloads.1password.com/linux/rpm/beta/x86_64/1password-latest.rpm
	# latest nightly
	# https://downloads.1password.com/linux/rpm/edge/x86_64/1password-latest.rpm

	### manual repo files for diff channels
	# sudo nano /etc/yum.repos.d/1password.repo

	# [1password]
	# name=1Password Stable Channel
	# baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
	# enabled=1

	# [1password]
	# name=1Password Beta Channel
	# baseurl=https://downloads.1password.com/linux/rpm/beta/$basearch
	# enabled=1

	# [1password]
	# name=1Password Edge Channel
	# baseurl=https://downloads.1password.com/linux/rpm/edge/$basearch
	# enabled=1

	# manual script
	curl -Lo 1password.tar.gz https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz
	sudo mkdir -p /opt/1Password
	sudo tar -xf 1password.tar.gz --strip-components=1 -C /opt/1Password
	sudo cp /opt/1Password/resources/1password.desktop /var/home/chris/.local/share/applications
	sudo cp -rf /opt/1Password/resources/icons/* /var/home/chris/.local/share/icons
	touch /var/home/chris/.local/share/icons/hicolor

	sudo chmod 4755 /opt/1Password/chrome-sandbox
	GROUP_NAME="onepassword"
	if [ ! "$(getent group "$GROUP_NAME")" ]; then
		sudo groupadd "$GROUP_NAME"
	fi
	BROWSER_SUPPORT_PATH="/opt/1Password/1Password-BrowserSupport"
	sudo chgrp "$GROUP_NAME" "$BROWSER_SUPPORT_PATH"
	sudo chmod g+s "$BROWSER_SUPPORT_PATH"

	# this permission change is probably unnecessary except when zentool creates this file
	sudo chmod 777 /etc/1password/custom_allowed_browsers
	brew install --cask 1password-gui-linux
	sudo chmod 644 /etc/1password/custom_allowed_browsers
}
