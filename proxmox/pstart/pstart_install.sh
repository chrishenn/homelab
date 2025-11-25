#!/bin/bash

sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

sudo cp $sdir/pstart.service /etc/systemd/system/pstart.service
sudo cp $sdir/pstart.sh /usr/local/bin/pstart.sh
sudo systemctl daemon-reload
sudo systemctl enable pstart
