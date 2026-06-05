#!/bin/bash

function sshd_cfg_clean {
	declare file=${1:-'/etc/ssh/sshd_config'}
	shift

	# remove comments
	sudo sd -f gm '^#(.*)\n*' '' "$file"
	# remove lines containing just a newline
	sudo sd -f gm -A '^\n' '' "$file"
}

function replace_or_append_line {
	# match on this string
	declare match=${1}
	shift
	# replace with this string
	declare replace=${1}
	shift
	# target file
	declare file=${1:-'/etc/ssh/sshd_config'}
	shift

	if ! sudo grep -q "$match" "$file"; then
		echo "$replace" | sudo tee -a "$file"
	else
		sudo sd -f gm -n 1 "^(.*)$match(.*)$" "$replace" "$file"
	fi
}

function sshd_config {
	# todo: first you must add your public key to ~/.ssh/authorized_keys
	# 	before removing passwordauth (server does not come with an ssh key like vps does)
	brew install sd

	sshd_cfg_clean
	replace_or_append_line 'Port' 'Port 2200'
	replace_or_append_line 'PermitRootLogin' 'PermitRootLogin no'
	replace_or_append_line 'PasswordAuthentication' 'PasswordAuthentication no'
	sudo systemctl daemon-reload
	sudo semanage port -a -t ssh_port_t -p tcp 2200
	sudo systemctl enable --now sshd
}

function sysctl_config {
	sudo tee /etc/sysctl.d/99-custom.conf -a >/dev/null <<-'END'
		net.ipv4.ip_nonlocal_bind=1
		net.ipv4.ip_forward=1
		vm.overcommit_memory=1
		fs.inotify.max_user_watches=1014796
		fs.inotify.max_user_instances=1014796
		fs.inotify.max_queued_events=1014796
		net.ipv6.conf.all.disable_ipv6=1
	END
	sudo sysctl --system
}

function chezmoi_mise {
	# just ssh "$(op read op://homelab/svc/bash); $(op read op://homelab/github/token); bash -l"

	brew install mise
	mise use -g chezmoi op
	eval "$(mise activate bash --shims)"
	chezmoi init chrishenn -a --force --promptDefaults
	mise i
}

function homelab_clone {
	# just ssh '$(op read op://homelab/svc/bash); $(op read op://homelab/github/token); bash -l'

	mkdir -p ~/Projects
	cd ~/Projects
	gh repo clone chrishenn/homelab
}

function installs {
	sudo ujust update
	sudo ujust toggle-user-motd
	sudo ujust toggle-devmode
	sudo ujust dx-group
	curl -LsSf https://astral.sh/uv/install.sh | sh
	curl -fsSL https://pixi.sh/install.sh | sh
	brew install git-lfs atuin parallel 7-zip trash-cli
	sudo nvidia-ctk runtime configure --runtime=docker
	sudo systemctl restart docker
}

function power_shortcuts {
	sudo chmod +x $REPO/linux/power_shortcuts/power_shortcuts.sh
	$REPO/linux/power_shortcuts/power_shortcuts.sh
}

function sudo_timeout {
	tmp=~/tmpfile
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

function disks {
	# sudo lsblk --fs

	# unset dirty flag on ntfs volume
	# sudo ntfsfix -d /dev/sda1
	# set label on ntfs volume
	# sudo ntfslabel -f /dev/sda1 WD_10TB_F

	sudo mkdir -p \
		/var/mnt/f \
		/var/mnt/h \
		/var/mnt/k \
		/var/mnt/q \
		/var/mnt/r

	sudo tee -a /etc/fstab >/dev/null <<-END
		UUID=8A462E2E462E1B87                     /var/mnt/f ntfs3 nofail,noatime 0 0
		UUID=3c9ebf74-af51-4b0b-b47e-6ee4c5fdd0e4 /var/mnt/h ext4  nofail,noatime 0 0
		UUID=ec5c17bd-2389-43cf-9ccd-ca35e92a213a /var/mnt/k ext4  nofail,noatime 0 0
		UUID=80a1ee5d-7a6b-4fdc-9244-e5e2432bc968 /var/mnt/r ext4  nofail,noatime 0 0
	END
	sudo systemctl daemon-reload
	sudo mount -a

	sudo zpool import pool1 -f
	sudo zfs set mountpoint=/var/mnt/q pool1
}

function zpool_fix {
	sudo zpool clear pool1
	sudo zpool scrub pool1
	# the scrub runs async. watch with:
	# watch -n 1 sudo zpool status -v
}

function nfs_server {
	# not sure if necessary
	# echo 'rpcrdma' | sudo tee /etc/modules-load.d/rdma.conf
	# sudo modprobe rpcrdma svcrdma xprtrdma

	sudo tee -a /etc/exports >/dev/null <<-END
		/var/mnt/f 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
		/var/mnt/h 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
		/var/mnt/k 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
		/var/mnt/r 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
	END
	sudo zfs set sharenfs="rw=@192.168.1.0/24,async,insecure,no_subtree_check,no_root_squash" pool1

	sudo systemctl disable --now firewalld
	sudo setsebool -P nfs_export_all_rw 1

	sudo systemctl daemon-reload
	sudo systemctl enable --now nfs-server
}

function samba_server {
	# sudo nano /etc/samba/smb.conf
	# copy smb.conf from linux/samba/smb.con

	sudo systemctl disable --now firewalld
	sudo setsebool -P samba_export_all_rw 1

	sudo smbpasswd -a chris
	sudo smbpasswd -e chris

	sudo systemctl daemon-reload
	sudo systemctl enable --now smb
}
