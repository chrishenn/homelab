#!/bin/bash

# I used this command to boot a docker arch host with KVM Macos VM inside, and it will download the installer media
# for macos ventura.

# From the apple recovery env, format the largest KVM disk AS APFS (necessary for this and probably more modern MacOS)
# Boot to the installer over and over again until the installer goes away and the machine boots to desktop

# Here you can see that I've already generated the serials in ./env and used them to boot the machine

# once the machine was booted and macos installed, shut down the VM. The docker overlay2 driver keeps a diff of the .img
# file your container has generated (volume?) so you need to shut down the container before the changes commit to the .img.

# I went and found the system drive disk with
# sudo find /var/lib/docker -size +10G | grep mac_hdd_ng.img

# and made sure I was copying out the latest .img by comparing time stamps

# If you boot an image this way, with -e GENERATE_UNIQUE=true, and an existing file mounted to
# -v "${PWD}/env:/env", I think the config script inside the VM host will populate the /env file with serials for ventura

docker run -it \
	--device /dev/kvm \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e "DISPLAY=${DISPLAY:-:0.0}" \
	-p 50922:10022 \
	-e RAM=16 \
	-e SMP=8 \
	-e CORES=4 \
	-e GENERATE_UNIQUE=true \
	-v "${PWD}/env:/env" \
	sickcodes/docker-osx:ventura
