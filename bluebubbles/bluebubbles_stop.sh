#!/bin/bash
# bluebubbles_stop.sh

# global paths and names for the bluebubbles install.
# NOTE: Manually sync across files!
bb_imgs="/mnt/k/osx_files"
bb_scripts="/bb_scripts"
bb_container_name="bluebubbles"

# docker run --rm will mean that docker stop here removes the container
docker stop "${bb_container_name}" || true
