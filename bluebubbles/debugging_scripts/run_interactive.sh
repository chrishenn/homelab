#!/bin/bash

# gives you a gui interface.
# Here we haven't generated the /bootdisk yet, and are generating it each time with GENERATE_SPECIFIC=true
# for whatever reason I had to generate the /bootdisk and mount it manually, or else the machine wouldn't boot headlessly.

docker run -it --rm \
	--device /dev/kvm \
	-e "DISPLAY=${DISPLAY:-:0.0}" \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-p 50922:10022 \
	-e RAM=16 \
	-e SMP=8 \
	-e CORES=4 \
	-v "${PWD}/mac_bluebb_working.img:/image" \
	-e GENERATE_SPECIFIC=true \
	-v "${PWD}/env:/env" \
	sickcodes/docker-osx:naked

# I'm sure this would also work
# --network=host probably means that we don't have to explicitly bind ports in this command (not tested)

FILES="${PWD}/bb_imgs"
args=(
	-it
	--rm
	--device /dev/kvm
	-e "DISPLAY=${DISPLAY:-:0.0}"
	-v /tmp/.X11-unix:/tmp/.X11-unix
	--network host
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
