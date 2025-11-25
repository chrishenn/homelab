#!/bin/bash

# notice that I've run this script from the Docker-OSX/custom folder.
# Probably the "custom" stuff makes the magic work for the docker VM host
############
# cd custom
############

# here i've got all my working serials in the ./env file, so doing
# source ./env
# will load DEVICE_MODEL etc into the bash shell for use when calling ./generate-specific-bootdisk.sh
source ./env

# make empty dir Tools, even though it seems like the script should be making it.
# the resulting boot disk does work, so it's probably just the generate- script that was freaking out
mkdir -p ./EFI/OC/Tools

# generate bootdisk for headless boot (bootdisk will have serials installed)
# bootdisk comes out to like 15MB
./generate-specific-bootdisk.sh \
	--master-plist-url="https://raw.githubusercontent.com/sickcodes/Docker-OSX/master/custom/config-nopicker-custom.plist" \
	--model "${DEVICE_MODEL}" \
	--serial "${SERIAL}" \
	--board-serial "${BOARD_SERIAL}" \
	--uuid "${UUID}" \
	--mac-address "${MAC_ADDRESS}" \
	--width "${WIDTH:-1920}" \
	--height "${HEIGHT:-1080}" \
	--output-bootdisk "my_bootdisk.img"
