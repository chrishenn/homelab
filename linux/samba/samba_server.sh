#!/bin/bash

sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

# add a user to samba password manager. username must belong to a system account.
sudo adduser chris && usermod -aG sudo chris || true
sudo apt install samba -y
sudo smbpasswd -a chris
sudo smbpasswd -e chris
sudo ufw allow samba

# configure samba shares in smb.conf
# smb.conf is under rack4/ right now
sudo cp $sdir/smb.conf /etc/samba/smb.conf

sudo systemctl daemon-reload
sudo systemctl enable --now smb
