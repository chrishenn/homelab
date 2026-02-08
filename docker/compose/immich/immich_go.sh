#!/bin/bash

shopt -s nullglob

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

function install {
	# https://github.com/simulot/immich-go/releases/latest
	ver="v0.26.3"
	url="https://github.com/simulot/immich-go/releases/download/$ver/immich-go_Linux_x86_64.tar.gz"

	tmp="$SCRIPT_DIR/tmp"
	mkdir -p "$tmp"
	pushd "$tmp"

	wget -O immich-go.tar.gz "$url"
	tar -xzf immich-go.tar.gz --wildcards 'immich-go'
	sudo chmod a+x immich-go
	sudo install immich-go /usr/bin/

	popd
	rm -rf "$tmp"
}

function run {
	src="$SCRIPT_DIR/src"
	token=$(op read op://personal/immich/token)
	url=$(op read op://personal/immich/website)

	# it's important to upload multiple archives all at the same time, because data/metadata can be spread across archives
	immich-go upload from-google-photos -s "$url" -k "$token" -u --include-untitled-albums "$src/takeout-"*.zip
}
