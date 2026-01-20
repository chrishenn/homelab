#!/bin/bash
set -eou pipefail

cpus=$(("$CORES" * 2))
export CPUS="$cpus"

mounted_boxfile="/boxes/$VM_NAME.box"
vagrant_boxpath="default/$VM_NAME"

vagrant_boxpath_esc=$(echo "$vagrant_boxpath" | sed 's|/|-VAGRANTSLASH-|g')
uploaded_box="$HOME/.vagrant.d/boxes/$vagrant_boxpath_esc"

if test -e "$uploaded_box"; then
	echo "using previously uploaded vagrant box for $VM_NAME"

elif test -f "$mounted_boxfile"; then
	echo "uploading box from mounted storage $mounted_boxfile"

	vagrant box add --provider=libvirt "$vagrant_boxpath" "$mounted_boxfile"
	export VAGRANT_BOX_PATH="$vagrant_boxpath"

elif [ "$DOWNLOAD_BOX" == "true" ]; then
	echo "no local box file found; downloading box from $VAGRANT_BOXURL"

	vagrant box add "$VAGRANT_BOXURL"
	export VAGRANT_BOX_PATH="$VAGRANT_BOXURL"

else
	echo "couldn't find mounted box file at $mounted_boxfile and DOWNLOAD_BOX is not true; exiting"
	exit 1
fi

rm -f ./Vagrantfile
envsubst '${VM_NAME},${VAGRANT_BOX_PATH},${MEMORY},${CORES},${CPUS},${DISK_SIZE}' <Vagrantfile.ini >./Vagrantfile

chown root:kvm /dev/kvm
/usr/sbin/libvirtd --daemon
/usr/sbin/virtlogd --daemon

vagrant up

exec "$@"
