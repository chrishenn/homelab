#!/bin/bash
set -ex
sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")
cd "$sdir"

# backup destination
dst="/mnt/h/gdrive"

# rclone
op inject -i rclone.conf -o secrets.conf -f
rclone sync --config secrets.conf -P --fast-list --transfers=32 --drive-export-formats txt,docx,ods,odt,odp gdrive:/ "$dst"
rm secrets.conf

# chown backed up files
chown -R 1000:1000 "$dst"
