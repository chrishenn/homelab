#!/bin/bash
set -ex

if ! grep -qF "https://downloads.1password.com/linux/alpinelinux/stable/" /etc/apk/repositories; then
	sh -c 'echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories'
fi
if [ ! -f /etc/apk/keys/support@1password.com-61ddfc31.rsa.pub ]; then
	wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys
fi
apk update && apk add git git-lfs 1password-cli libc6-compat github-cli jq fd mise

# we need latest rclone (ahead of apk) for filen support
apk del rclone
mise use -g rclone
export PATH="$HOME/.local/share/mise/shims:$PATH"
