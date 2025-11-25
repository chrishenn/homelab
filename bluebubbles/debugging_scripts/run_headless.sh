#!/bin/bash

# See bluebubbles_start.sh for the definitive command. This needs a working set of serials /env, macos image /image, and
# generated bootdisk /bootdisk. Then the naked container just boots up the VM, connects the disks, and plumbs in the
# environment variables as needed.

FILES="${PWD}/bb_imgs"
args=(
	--rm
	--device /dev/kvm
	--network host
	-p 50922:10022
	-e RAM=16
	-e SMP=8
	-e CORES=4
	-v "${FILES}/env:/env"
	-v "${FILES}/mac_ventura.img:/image"
	-v "${FILES}/working_bootdisk.img:/bootdisk"
	-e GENERATE_SPECIFIC=true
	-e NOPICKER=true
)
docker run "${args[@]}" sickcodes/docker-osx:naked
