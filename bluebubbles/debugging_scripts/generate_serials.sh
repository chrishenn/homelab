#!/bin/bash

# I don't remember if I used this or not.
# when you boot the docker host, it calls this if you've got -e GENERATE_UNIQUE=true
# which will both generate unique serials, as well as generating a unique bootdisk from those serials

# Make sure your vendor_serials.tsv is copied into wherever you use this thing.
# Manually verify the generated serials for correctness!

# script is in the custom folder
cd custom || exit 1

./generate-unique-machine-values.sh \
	--count 1 \
	--master-plist-url="https://raw.githubusercontent.com/sickcodes/Docker-OSX/master/custom/config-nopicker-custom.plist" \
	--model "MacBookPro14,3" \
	--width "${WIDTH:-1920}" \
	--height "${HEIGHT:-1080}" \
	--output-env ./env
