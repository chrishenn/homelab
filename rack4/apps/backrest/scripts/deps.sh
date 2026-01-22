#!/bin/bash
set -ex

if ! grep -qF "https://downloads.1password.com/linux/alpinelinux/stable/" /etc/apk/repositories; then
	sh -c 'echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories'
fi
if [ ! -f /etc/apk/keys/support@1password.com-61ddfc31.rsa.pub ]; then
	wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys
fi
apk update && apk add 1password-cli rclone libc6-compat github-cli jq fd
