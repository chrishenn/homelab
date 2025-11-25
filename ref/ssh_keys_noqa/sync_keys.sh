#!/bin/bash

# deprecated
# sync ssh keys with python fabric?

function boot {
	# generate the fabric key if not present on local
	if [[ ! -f ~/.ssh/id_rsa ]]; then
		echo "generating key pair"
		ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -P "$SSH_PASS"
	else
		echo "fabric private key already exists"
	fi

	# connect to windows over ssh from bash and pipe public key into window's authorized_keys file
	#    user=chris
	#    host="192.168.1.74"
	#    port=22
	#    file='$HOME/.ssh/authorized_keys'
	#    inp='$input'
	#    cmd="pwsh -NoProfile -Command \"touch $file && $inp >> $file\""
	#    cat ~/.ssh/id_rsa.pub | ssh "$user@$host" -p "$port" "$cmd"
}

boot
