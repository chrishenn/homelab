#!/bin/bash
set -ex
sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")
cd "$sdir"

# backup destination
dst="/mnt/h/backup/gdrive"

# install deps if needed
if ! grep -qF "https://downloads.1password.com/linux/alpinelinux/stable/" /etc/apk/repositories; then
	sh -c 'echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories'
fi
if [ ! -f /etc/apk/keys/support@1password.com-61ddfc31.rsa.pub ]; then
	wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys
	apk update && apk add 1password-cli rclone libc6-compat
fi

# rclone
op inject -i rclone.conf -o secrets.conf -f
rclone sync --config secrets.conf -P --fast-list --transfers=32 --drive-export-formats txt,docx,ods,odt,odp gdrive:/ "$dst"
rm secrets.conf

# chown backed up files
chown -R 1000:1000 "$dst"
