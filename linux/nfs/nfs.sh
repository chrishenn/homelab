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
echo '/mnt/q *(rw,async,insecure,no_root_squash)' | sudo tee -a /etc/exports

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# or, if using a ZFS filesystem
sudo zfs set sharenfs="rw=@192.168.1.0/24,no_root_squash,insecure,async" pool1

# client
sudo apt install -y nfs-common
sudo modprobe rpcrdma

# verify that these modules are present
lsmod | grep xprtrdma
lsmod | grep svcrdma
lsmod | grep rpcrdma

# verify these modules are in the conf to load auto
cat /etc/rdma/modules/rdma.conf

# mount
sudo mkdir -p /mnt/tmp
sudo mount -t nfs 192.168.1.142:/tmp /mnt/tmp -o proto=rdma,port=20049,async,noatime,nodiratime -vvvv

# client fstab mount
sudo nano /etc/fstab
192.168.1.142:/tmp /mnt/tmp nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0

# testing: we expect to see little to no traffic on the server, using iftop or btm

# res: 24 Gigabit/s write accross network to /tmp (ramdisk) on 66 Gigabit/s connection
sudo mkdir -p /mnt/tmp/speedtest
sudo fio --name=testfile --directory=/mnt/tmp/speedtest --size=2G --numjobs=8 --rw=write --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s

# res: 20 gigabit/s write
sudo fio --name=testfile --directory=/mnt/q/speedtest --size=2G --numjobs=8 --rw=write --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s

