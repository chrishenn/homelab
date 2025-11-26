#!/bin/bash
set -ex
sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")
cd "$sdir"

# backup destination
dst="/mnt/h/backup/github"
gitbkp="https://github.com/ChappIO/git-backup/releases/download/v1.6.1/git-backup-linux-x64"

# 1password
if ! grep -qF "https://downloads.1password.com/linux/alpinelinux/stable/" /etc/apk/repositories; then
	sh -c 'echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories'
fi
if [ ! -f /etc/apk/keys/support@1password.com-61ddfc31.rsa.pub ]; then
	wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys
	apk update && apk add 1password-cli libc6-compat
fi

# git-backup
if [[ ! -f gitbackup ]]; then
	echo "downloading gitbackup binary"
	curl -Lo gitbackup "$gitbkp"
	chmod +x gitbackup
else
	echo "using existing gitbackup binary"
fi

# can't inject the config file from stdin, I assume
op inject -i config.yml -o secrets.yml -f
./gitbackup -backup.path "$dst" -config.file secrets.yml -backup.fail-at-end
rm secrets.yml

# chown backed up files
chmod -R 777 "$dst"
chown -R 1000:1000 "$dst"
