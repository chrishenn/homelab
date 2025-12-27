#!/bin/bash

# https://manpages.ubuntu.com/manpages/noble/man1/nfstest_rdma.1.html
# http://www.unstructureddatatips.com/onefs-nfs-over-rdma-client-configuration/
# https://forum.level1techs.com/t/does-anybody-here-have-experience-setting-up-nfsordma-in-ubuntu-18-04-lts-with-the-inbox-driver/152774/33
# https://blog.chlc.cc/p/nfs-over-rdma/
# https://blog.sparktour.me/en/posts/2023/08/24/mount-nfs-via-rdma-on-mlnx-card/

# ---

# requirements
# - The rpcrdma kernel module must be loaded on both the server and the client
#     - add rpcrdma to /etc/modules-load.d/rdma.conf
#     - lsmod | grep rpcrdma
echo 'rpcrdma' | sudo tee /etc/modules-load.d/rdma.conf
sudo modprobe rpcrdma
lsmod | grep rpcrdma
# - on server: rdma associated with some port (doesn't matter which one) must appear in /proc/fs/nfsd/portlist
echo 'RPCNFSDOPTS="--rdma=20049"' | sudo tee -a /etc/default/nfs-kernel-server
cat /proc/fs/nfsd/portlist

# server

# not sure if these were necessary for either server or client
sudo apt install -y infiniband-diags srptools perftest opensm-doc librdmacm-dev \
    rdmacm-utils librdmacm1 ibacm libibmad-dev libibmad5 libibumad-dev libibumad3 \
    ibverbs-utils libibverbs-dev libibverbs1 mstflint rdma-core opensm fio librbd1 \
    librados2 libibnetdisc5 ibverbs-providers

sudo apt install -y nfs-kernel-server
sudo systemctl enable --now nfs-kernel-server

# server: shares (tmpfs should be a ramdisk)
mount | grep /tmp

# regular
echo '/tmp *(rw,async,insecure,no_root_squash)' | sudo tee -a /etc/exports
echo '/tmp 192.168.1.0/24(rw,async,insecure,no_root_squash)' | sudo tee -a /etc/exports
# zfs
sudo zfs set sharenfs="rw=@192.168.1.0/24,no_root_squash,insecure,async" pool1

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# client
sudo apt install -y nfs-common

# mount
sudo mkdir -p /mnt/tmp
sudo mount -t nfs 192.168.1.142:/tmp /mnt/tmp -o proto=rdma,port=20049,async,noatime,nodiratime -vvvv

# client fstab mount
sudo nano /etc/fstab
192.168.1.142:/tmp /mnt/tmp nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0

# testing: we expect to see little to no traffic on the server, using iftop or btm

# res: 24 Gigabit/s write accross network to /tmp (ramdisk) on 66 Gigabit/s connection
sudo mkdir -p /mnt/tmp/speedtest
sudo fio --name=testfile --directory=/mnt/tmp/speedtest --size=2G --numjobs=10 --rw=write --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s

# res: 20 gigabit/s write
sudo mkdir -p /mnt/q/speedtest
sudo fio --name=testfile --directory=/mnt/q/speedtest --size=2G --numjobs=10 --rw=write --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s



