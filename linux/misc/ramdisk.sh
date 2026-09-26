#!/bin/bash

disk_size="15G"

mkdir /tmp/ramdisk
chmod 777 /tmp/ramdisk

mount -t tmpfs -o size="$disk_size",noatime myramdisk /tmp/ramdisk
mount | tail -n 1
