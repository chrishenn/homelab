#!/bin/bash

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

function gpth_install {
	# https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper/releases/latest
	ver="v3.4.3"

	url="https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper/releases/download/$ver/gpth-linux"
	curl -Lo ./gpth "$url"
	sudo chmod a+x gpth
	sudo install gpth /usr/bin/
}

function gpth {
	dst="$SCRIPT_DIR/dst"

	mkdir -p "$dst"
	gpth -i "$SCRIPT_DIR/extracted" -o "$dst" --no-skip-extras
}
