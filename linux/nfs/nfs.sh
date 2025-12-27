#!/bin/bash

# https://manpages.ubuntu.com/manpages/noble/man1/nfstest_rdma.1.html
# http://www.unstructureddatatips.com/onefs-nfs-over-rdma-client-configuration/
# https://forum.level1techs.com/t/does-anybody-here-have-experience-setting-up-nfsordma-in-ubuntu-18-04-lts-with-the-inbox-driver/152774/33
# https://blog.chlc.cc/p/nfs-over-rdma/
# https://blog.sparktour.me/en/posts/2023/08/24/mount-nfs-via-rdma-on-mlnx-card/

# ---

# server

sudo apt install nfs-kernel-server
sudo systemctl enable --now nfs-kernel-server

sudo modprobe rpcrdma
echo 'rdma 20049' | sudo tee /proc/fs/nfsd/portlist

sudo nano /lib/systemd/system/nfs-kernel-server.service

# add
# ExecStartPre=/sbin/modprobe rpcrdma
# ExecStartPost=/bin/bash -c "sleep 3 && echo 'rdma 20049' | tee /proc/fs/nfsd/portlist"

# ...
# [Service]
# Type=oneshot
# RemainAfterExit=yes
# ExecStartPre=-/usr/sbin/exportfs -r
# ExecStartPre=/sbin/modprobe rpcrdma
# ExecStart=/usr/sbin/rpc.nfsd
# ExecStartPost=/bin/bash -c "sleep 3 && echo 'rdma 20049' | tee /proc/fs/nfsd/portlist"
# ExecStop=/usr/sbin/rpc.nfsd 0
# ExecStopPost=/usr/sbin/exportfs -au
# ExecStopPost=/usr/sbin/exportfs -f
# ...

sudo systemctl daemon-reload
sudo systemctl restart nfs-kernel-server

cat /proc/fs/nfsd/portlist
# rdma 20049
# rdma 20049
# tcp 2049
# tcp 2049

# ??
# echo 'rdma=nfsrdma' | sudo tee -a /etc/nfs.conf

# server: shares (tmpfs should be a ramdisk)
mount | grep /tmp

echo '/tmp *(rw,async,insecure,no_root_squash)' | sudo tee -a /etc/exports
exportfs -a
sudo systemctl restart nfs-kernel-server

# or if using a ZFS filesystem
zfs set sharenfs="rw=@192.168.1.0/24,no_root_squash,async" pool0

# client
sudo apt install -y nfs-common
sudo modprobe rpcrdma

sudo mkdir -p /mnt/q_nfs
sudo mount -t nfs 192.168.1.142:/mnt/q /mnt/q_nfs -o proto=rdma,port=20049,async,noatime,nodiratime -vvvv

# on the server: sudo chmod -R 777 /mnt/q/speedtest
sudo mkdir -p /mnt/q_nfs/speedtest
fio --name=testfile --directory=/mnt/q_nfs/speedtest --size=2G --numjobs=8 --rw=write --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=60 --time_based --group_reporting --eta-newline=1s

# The write speed was able to max out the 10G network card (1078MiB/s), and no traffic was visible on the network card
# during the test via iftop, indicating that NFS traffic was being directly transmitted over RDMA

# WRITE: bw=1871MiB/s
# network speed like 15 Gb/s
# I saw traffic on network on btm
# traffic also shows on iftop
