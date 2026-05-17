# nfs

status:

- nfs over rdma is working on both fedora and ubuntu
- Proiority Flow Control (PFC) is needed for a "lossless" network
    - ~should~ be enabled on mikrotik switch
    - can't set Traffic Class (TC) for all ways that connections can be opened
        - (nonworking) this config is used by some: `echo 104 | sudo tee /sys/class/infiniband/$dev/tc/1/traffic_class`
        - (working) this is used by others: `sudo ./sbin/cma_roce_tos -d $dev -t 104`
    - on ubuntu, `/sys/class/infiniband/$dev/tc` will appear when doca-host is installed, but doca is not supported on
      current releases, and partial installs (smaller than doca-all) provide a broken mix of system+mlx packages
    - on fedora aurora, doca-host appears to have installed, but I'm not convinced that all pkgs are working
        - although nfs over rdma is NOT broken, so that's a start
    - mlx_qos and mlx_tos settings must be run at each boot
    - there are extensive methods to verify PFC - I've done none of these - see refs

status: PFC is nonworking because I cannot get the mellanox ofed driver to build.
without the ofed driver, I cannot set the nic to mark traffic_class 3 with prio3 pause PFC/ECN markers

status: I was able to install doca-host, doca-ofed, and doca-roce. However, the kernel modules rpcrdma and nvmet_rdma
will not load because of "unknown symbol" errors in dmesg. This is probably because the entire network stack has not
been replaced by doca packages. Why not install doca-networking or a larger package 'profile' (package set)? Well,
one of the packages in doca-networking depends on some apt package libcppjson25, which does not ship in ubuntu 25.10 -
it's been replaced with libcppjson26.

# ref

https://manpages.ubuntu.com/manpages/noble/man1/nfstest_rdma.1.html
http://www.unstructureddatatips.com/onefs-nfs-over-rdma-client-configuration/
https://forum.level1techs.com/t/does-anybody-here-have-experience-setting-up-nfsordma-in-ubuntu-18-04-lts-with-the-inbox-driver/152774/33
https://blog.chlc.cc/p/nfs-over-rdma/
https://blog.sparktour.me/en/posts/2023/08/24/mount-nfs-via-rdma-on-mlnx-card/
https://blog.mylab.cc/2023/07/24/Enable-L3-PFC-DCQCN-for-RoCE-on-Mellanox-ConnectX-NICs/
https://github.com/Mellanox/mlnx-tools
https://docs.oracle.com/en/learn/gpudirect-rdma-ib-write-bw/index.html#objectives
https://enterprise-support.nvidia.com/s/article/lossless-roce-configuration-for-linux-drivers-in-dscp-based-qos-mode

https://enterprise-support.nvidia.com/s/article/How-To-Enable-Verify-and-Troubleshoot-RDMA
https://enterprise-support.nvidia.com/s/article/mellanox-linux-driver-modules-relationship--mlnx-ofed-x
https://enterprise-support.nvidia.com/s/article/howto-configure-nfs-over-rdma--roce-x
https://enterprise-support.nvidia.com/s/article/howto-configure-nvme-over-fabrics

https://forums.developer.nvidia.com/t/pfc-not-working-with-rdma-over-rocev2-and-connectx-7/368378/2

- https://docs.nvidia.com/networking/display/mlnxofedv497100lts/rdma+over+converged+ethernet+(roce)
- https://enterprise-support.nvidia.com/s/article/recommended-network-configuration-examples-for-roce-deployment
- https://enterprise-support.nvidia.com/s/article/howto-set-egress-tos-dscp-on-rdma-cm-qps

# doca

```bash
# (fedora) online rpm install had a python dependency issue. try manual install
curl -Lo doca.rpm https://www.mellanox.com/downloads/DOCA/DOCA_v3.3.0/host/doca-host-3.3.0-088000_26.01_rhel10.x86_64.rpm
sudo rpm-ostree install doca.rpm
```

# troubleshooting

```bash
cat /proc/fs/nfsd/portlist
sudo ibstat
sudo iblinkinfo
sudo apt install nfstest -y
nfstest_rdma --server 192.168.1.142
rpc.nfsd --rdma=20049

sudo cat /proc/fs/nfsd/portlist
rdma 20049
rdma 20049
tcp 2049
tcp 2049

# verify rdma link status
rdma link
# Verify RDMA device information. Ensure the device state is PORT_ACTIVE and link layer is Ethernet
ibv_devinfo
# mount an nfs share, then verify the mount uses RDMA. Look for 'proto=rdma,port=20049' in the output
nfsstat -m

# find cable length. note: it did not know how long the cable is lmao nvm
mstdev=/dev/mst/mt4119_pciconf0
sudo mlxlink -d $mstdev -m -c -e | grep -i "distance"

systemctl status nfs-server
# should show "exited with code0". There is no userspace daemon

# to find kernel threads running nfs, do
sudo cat /proc/fs/nfsd/threads
sudo cat /proc/fs/nfsd/versions
ps axf | grep nfsd
ps axf | grep lockd

# view
sudo ./python/mlnx_qos -i $ifname -a
cat /sys/class/infiniband/$dev/ports/1/link_layer
sudo ./sbin/cma_roce_mode -d $dev
# verify pfc is working
ethtool -S $ifname | grep prio3
ethtool -S $ifname | grep -Ei 'pfc|pause|stopped|drop|disc'
rdma link show
ls /dev/infiniband/

# set mtu to 9216?
# network-qos MTU for the RoCE class had been 4200; it was later changed to 9216

# server client bw test (switch observe: packets with DSCP 26)
ib_write_bw -d $dev -F
ib_write_bw -d $dev -F --report_gbits <serverip>
ib_write_bw -d mlx5_1 -F -a
ib_write_bw -d mlx5_1 -F --report_gbits -a <serverip>
rping -s -a 10.13.150.2 -v -d
rping -c -a 10.13.150.2 -C 10 -v -d
```

---

# NFS RDMA

```bash
gh repo clone Mellanox/mlnx-tools
cd mlnx-tools
./sbin/show_gids

# workstation
export ifname=enp15s0np0
export dev=mlx5_0

# rack4
export ifname=nic0
export dev=rocep1s0

# fix broken python import
cp -r ./python/Python/* ./python

# use L3 PFC, default=pcp (L2 PFC)
sudo ./python/mlnx_qos -i $ifname --trust dscp

# enable PFC on PFC Priority 3
sudo ./python/mlnx_qos -i $ifname --pfc 0,0,0,1,0,0,0,0
# service lldpad start # lldptool -T -i eth1 -V PFC enabled=3

# set default ToS (= DSCP value * 4) for RoCE traffic (DSCP value = 26)
echo 104 | sudo tee /sys/class/infiniband/$dev/tc/1/traffic_class
sudo ./sbin/cma_roce_tos -d $dev -t 104

# transciever cable length in meters (fiber or copper only?)
sudo ./python/mlnx_qos -i $ifname --cable_len=100 # workstation
sudo ./python/mlnx_qos -i $ifname --cable_len=5   # rack4 server
```

## server (ubuntu)

```bash
sudo apt install -y \
    nfs-kernel-server nfs-common rdma-core \
    infiniband-diags srptools perftest opensm-doc librdmacm-dev rdmacm-utils librdmacm1 ibacm \
    libibmad-dev libibmad5 libibumad-dev libibumad3 ibverbs-utils libibverbs-dev libibverbs1 opensm librbd1 \
	librados2 libibnetdisc5 ibverbs-providers
sudo systemctl enable --now nfs-kernel-server

echo 'rpcrdma' | sudo tee /etc/modules-load.d/rdma.conf
echo 'rdma 20049' | sudo tee /proc/fs/nfsd/portlist
sudo modprobe rpcrdma svcrdma xprtrdma

# necessary?
# echo 'RPCNFSDOPTS="--rdma=20049"' | sudo tee -a /etc/default/nfs-kernel-server

sudo nano /etc/nfs.conf
# rdma=on
# rdma-port=20049

sudo systemctl restart nfs-kernel-server

# shares: regular
echo '/tmp *(rw,async,insecure,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports
echo '/tmp 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports
# shares: zfs
sudo zfs set sharenfs="rw=@192.168.1.0/24,async,insecure,no_subtree_check,no_root_squash" pool1

# reload exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```

## client (ubuntu)

```bash
sudo apt install -y nfs-common rdma-core
echo 'rpcrdma' | sudo tee /etc/modules-load.d/rdma.conf
echo 'rdma 20049' | sudo tee /proc/fs/nfsd/portlist
sudo modprobe rpcrdma svcrdma xprtrdma

# mount
sudo mkdir -p /mnt/tmp
sudo mount -t nfs 192.168.1.142:/tmp /mnt/tmp -o proto=rdma,port=20049,async,noatime,nodiratime -vvvv

# mount fstab
sudo nano /etc/fstab
192.168.1.142:/tmp /mnt/tmp nfs defaults,proto=rdma,async,noatime,nodiratime 0 0
```

## client (fedora)

all packages/kernels for nfs over rdma client are included ootb

## problem (fedora)

```bash
systemctl status nfs-server
# Dependency failed for nfs-server.service - NFS server and services
journalctl -xe
# /var/mnt/f ntfs dirty flag set and -force not specified
sudo ntfsfix -d /dev/sda1
sudo mount -a
lsblk
sudo systemctl start nfs-server
```