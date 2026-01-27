#!/bin/bash

# status: PFC is nonworking because I cannot get the mellanox ofed driver to build.
# without the ofed driver, I cannot set the nic to mark traffic_class 3 with prio3 pause PFC/ECN markers

# https://manpages.ubuntu.com/manpages/noble/man1/nfstest_rdma.1.html
# http://www.unstructureddatatips.com/onefs-nfs-over-rdma-client-configuration/
# https://forum.level1techs.com/t/does-anybody-here-have-experience-setting-up-nfsordma-in-ubuntu-18-04-lts-with-the-inbox-driver/152774/33
# https://blog.chlc.cc/p/nfs-over-rdma/
# https://blog.sparktour.me/en/posts/2023/08/24/mount-nfs-via-rdma-on-mlnx-card/
# https://blog.mylab.cc/2023/07/24/Enable-L3-PFC-DCQCN-for-RoCE-on-Mellanox-ConnectX-NICs/
# https://github.com/Mellanox/mlnx-tools

# - The rpcrdma kernel module must be loaded on both the server and the client
#     - add rpcrdma to /etc/modules-load.d/rdma.conf
#     - lsmod | grep rpcrdma
# - on server: rdma associated with some port (doesn't matter which one) must appear in /proc/fs/nfsd/portlist

# ---

# server
sudo apt install -y nfs-kernel-server
sudo systemctl enable --now nfs-kernel-server
# sudo systemctl status nfs-kernel-server

echo 'rpcrdma' | sudo tee /etc/modules-load.d/rdma.conf
sudo modprobe rpcrdma
# lsmod | grep rpcrdma

echo 'RPCNFSDOPTS="--rdma=20049"' | sudo tee -a /etc/default/nfs-kernel-server

# not sure if these were necessary for either server or client
sudo apt install -y infiniband-diags srptools perftest opensm-doc librdmacm-dev \
	rdmacm-utils librdmacm1 ibacm libibmad-dev libibmad5 libibumad-dev libibumad3 \
	ibverbs-utils libibverbs-dev libibverbs1 mstflint rdma-core opensm fio librbd1 \
	librados2 libibnetdisc5 ibverbs-providers nfs-kernel-server

# Client
# verify rdma link status
rdma link
# Verify RDMA device information. Ensure the device state is PORT_ACTIVE and link layer is Ethernet
ibv_devinfo
# mount an nfs share, then verify the mount uses RDMA. Look for 'proto=rdma,port=20049' in the output
nfsstat -m

# what is this for?
# cat /proc/fs/nfsd/portlist
# sudo ibstat
# sudo iblinkinfo
# sudo apt install nfstest -y
# nfstest_rdma --server 192.168.1.142
# rpc.nfsd --rdma=20049

sudo nano /etc/nfs.conf
rdma=on
rdma-port=20049

sudo systemctl restart nfs-kernel-server

sudo cat /proc/fs/nfsd/portlist
>rdma 20049
>rdma 20049
>tcp 2049
>tcp 2049

# regular share
echo '/tmp *(rw,async,insecure,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports
echo '/tmp 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports
# zfs share
sudo zfs set sharenfs="rw=@192.168.1.0/24,async,insecure,no_subtree_check,no_root_squash" pool1

# reload exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# systemctl status nfs-server
# should show "exited with code0". There is no userspace daemon
# to find kernel threads running nfs, do
# sudo cat /proc/fs/nfsd/threads
# sudo cat /proc/fs/nfsd/versions
# ps axf | grep nfsd
# ps axf | grep lockd

# client
sudo apt install -y nfs-common

echo 'rpcrdma' | sudo tee /etc/modules-load.d/rdma.conf
sudo modprobe rpcrdma
lsmod | grep rpcrdma

# mount
sudo mkdir -p /mnt/tmp
sudo mount -t nfs 192.168.1.142:/tmp /mnt/tmp -o proto=rdma,port=20049,async,noatime,nodiratime -vvvv

# client fstab mount
sudo nano /etc/fstab
192.168.1.142:/tmp /mnt/tmp nfs defaults,proto=rdma,async,noatime,nodiratime 0 0

# ***
# ***NOTE*** I had to re-run this manually after a reboot
# ***

# set up PFC on mellanox nics
# https://enterprise-support.nvidia.com/s/article/lossless-roce-configuration-for-linux-drivers-in-dscp-based-qos-mode
# assumes that the switch is using pfc on prio3 traffic
git clone https://github.com/Mellanox/mlnx-tools.git
cd mlnx-tools
./sbin/show_gids

# workstation
export ifname=enp15s0np0
export dev=rocep15s0

# rack4 server
export ifname=nic0
export dev=rocep1s0

# fix broken python import
cp -r ./python/Python/* ./python

# use L3 PFC, default=pcp (L2 PFC)
sudo ./python/mlnx_qos -i $ifname --trust dscp

# enable PFC on PFC Priority 3
sudo ./python/mlnx_qos -i $ifname --pfc 0,0,0,1,0,0,0,0

# need ofed to work
# clear Traffic Class (TC) settings
# echo "tclass=-1" | sudo tee /sys/class/infiniband/$dev/tc/1/traffic_class
# set default ToS (= DSCP value * 4) for RoCE traffic
# echo 106 | sudo tee /sys/class/infiniband/$dev/tc/1/traffic_class

# set default ToS for RoCE traffic
sudo ./sbin/cma_roce_tos -d $dev -t 106

# verify pfc is working
ethtool -S $ifname | grep prio3

# verify roce mode
sudo ./sbin/cma_roce_mode -d $dev

# find cable length. note: it did not know how long the cable is lmao nvm
# mstdev=/dev/mst/mt4119_pciconf0
# sudo mlxlink -d $mstdev -m -c -e | grep -i "distance"

# transciever length in meters
sudo ./python/mlnx_qos -i $ifname --cable_len=100 # workstation
sudo ./python/mlnx_qos -i $ifname --cable_len=5   # rack4 server
