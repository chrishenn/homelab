#!/bin/bash

sudo apt install gmake gawk

git clone --recursive https://github.com/akinomyoga/ble.sh.git
cd ble.sh
gmake

# INSTALL to ~/.local/share/blesh and ~/.local/share/doc/blesh
gmake install
