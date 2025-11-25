#!/bin/bash

sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

function pwr_install {
	# copy files over the installed ones
	sudo chmod a+x $sdir/pwr/*.sh
	cp -f $sdir/pwr/* $HOME/.local/share/applications/

	# allow user `chris` to run `sudo <script>` without typing password
	tmp=$sdir/tmp
	sudo rm -f $tmp
	echo 'chris ALL=(root) NOPASSWD:/home/chris/.local/share/applications/shutdown.sh' | tee -a $tmp
	echo 'chris ALL=(root) NOPASSWD:/home/chris/.local/share/applications/restart.sh' | tee -a $tmp
	sudo chmod 0440 $tmp

	dst=/etc/sudoers.d/pwr
	if ! sudo visudo -c -q $tmp; then
		echo "ERROR: visudo syntax check failed on temporary file. Exiting without writing to permanent file"
		exit 1
	fi
	echo "copying $tmp to $dst"
	sudo cp $tmp $dst
}
