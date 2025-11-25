#!/bin/bash
# bluebubbles_start.sh

# global paths and names for the bluebubbles install.
# NOTE: Manually sync across files!
bb_imgs="/mnt/k/osx_files"
bb_scripts="/bb_scripts"
bb_container_name="bluebubbles"

# fail to bring up bluebubbles service here if image files are unreachable
test -f "${bb_imgs}/env" || return 1
test -f "${bb_imgs}/mac_ventura.img" || return 1
test -f "${bb_imgs}/working_bootdisk.img" || return 1

# have to create /dev/kvm on each lxc boot
# don't fail here whether or not the nod exists
mknod /dev/kvm c 10 232 &>/dev/null || true
chmod 777 /dev/kvm
chown root:kvm /dev/kvm
mkdir -p /dev/net
mknod /dev/net/tun c 10 200 &>/dev/null || true
chmod 777 /dev/net/tun
chown root:kvm /dev/net/tun

# libvirtd depends on /dev/kvm being available
sleep 5
systemctl restart libvirtd
# virtlogd doesn't care about /dev/kvm. No need to restart
#systemctl restart virtlogd

# the --rm option should allow a new container to come up on LXC host boot and this same docker run cmd
sleep 5
args=(
	--rm
	--name "${bb_container_name}"
	--device /dev/kvm
	--network host
	-p 50922:10022
	-e RAM=8
	-e SMP=8
	-e CORES=4
	-v "${bb_imgs}/env:/env"
	-v "${bb_imgs}/mac_ventura.img:/image"
	-v "${bb_imgs}/working_bootdisk.img:/bootdisk"
	-e GENERATE_SPECIFIC=true
	-e NOPICKER=true
)
docker run "${args[@]}" sickcodes/docker-osx:naked
