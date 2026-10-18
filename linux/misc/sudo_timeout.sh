#!/bin/bash
sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

function sudo_timeout {
	# replaced with mise bootstrap
	tmp=$sdir/tmp
	sudo rm -f "$tmp"
	echo "Defaults timestamp_timeout=180" | tee -a "$tmp"
	sudo chmod 0440 "$tmp"

	if ! sudo visudo -c -q "$tmp"; then
		echo "ERROR: visudo syntax check failed on temporary file. Exiting without writing to permanent file"
		exit 1
	fi

	dst=/etc/sudoers.d/sudo_timeout
	echo "copying $tmp to $dst"
	sudo cp "$tmp" "$dst"
	sudo rm -f "$tmp"
}
