#!/bin/bash

sudo nano /etc/exports
/tmp 192.168.1.0/24(rw,async,insecure,no_root_squash)
/mnt/h 192.168.1.0/24(rw,async,insecure,no_root_squash)
/mnt/k 192.168.1.0/24(rw,async,insecure,no_root_squash)
/mnt/f 192.168.1.0/24(rw,async,insecure,no_root_squash)

# nfs share zfs
sudo zfs set sharenfs="rw=@192.168.1.0/24,async,insecure,no_root_squash" pool1

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# verify
sudo exportfs -v

# client
sudo apt install -y nfs-common
sudo modprobe rpcrdma

sudo mkdir -p /mnt/h /mnt/k /mnt/f /mnt/q

sudo nano /etc/fstab
192.168.1.142:/mnt/h /mnt/h nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
192.168.1.142:/mnt/k /mnt/k nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
192.168.1.142:/mnt/f /mnt/f nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
192.168.1.142:/mnt/q /mnt/q nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0

sudo systemctl daemon-reload
sudo mount -a