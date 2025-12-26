#!/bin/bash

sudo apt install -y linux-headers-$(uname -r) apt-utils

# I downloaded the mellanox ofed archive

# this fails on ubu 25.10. dunno why
# sudo ./mlnxofedinstall --add-kernel-support --with-nfsrdma