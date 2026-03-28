doca-host

```bash
# 1. install kernel headers. make sure the gcc is installed that the kernel was built with
sudo apt install -y dkms gcc make perl mokutil linux-headers-generic \
	build-essential debhelper fakeroot autoconf automake quilt pkgconf apt-utils

# this package only has doca-ofed and doca-roce, not the larger profiles {networking, all}
url="https://www.mellanox.com/downloads/DOCA/DOCA_v3.3.0/host/doca-host_3.3.0-088000-26.01-ubuntu2510_amd64.deb"
wget -O doca.deb $url
sudo dpkg -i doca.deb

# deb install
sudo apt update
sudo apt install -y doca-ofed

# dkms build and install
sudo apt install -y doca-extra
/opt/mellanox/doca/tools/doca-kernel-support
sudo dpkg -i /tmp/DOCA.8jIe6eR5vO/doca-kernel-repo-26.01-1.0.0.0-6.17.0.19.generic_26.01.1.0.0.0_amd64.deb
sudo apt update
sudo apt install -y doca-ofed

# automatically updates mellanox firmware
sudo apt install -y mlnx-fw-updater
```

uninstall doca packages

```bash
# apt list --installed | grep -i doca
sudo apt purge doca-host doca-ofed doca-kernel-repo-26.01-1.0.0.0-6.17.0.19.generic
sudo apt autoremove --purge
```

install base networking packages

```bash
sudo apt install -y infiniband-diags srptools perftest opensm-doc librdmacm-dev rdmacm-utils librdmacm1 ibacm
  libibmad-dev libibmad5 libibumad-dev libibumad3 ibverbs-utils libibverbs-dev libibverbs1 rdma-core opensm librbd1 \
  librados2 libibnetdisc5 ibverbs-providers
```

verify rdma

```bash
# on server
udaddy
# on client
udaddy -s 192.168.1.142

# server
rping -s -C 10 -v
# client
rping -c -C 10 -a 192.168.1.142
```

verify kernel modules

```bash
$ lsmod | grep '\(^ib\|^rdma\)'
rdma_ucm               24576  0
ib_uverbs              65536  1 rdma_ucm
ib_iser                49152  0
rdma_cm                57344  3 ib_iser,rpcrdma,rdma_ucm
ib_umad                24576  0
ib_ipoib              114688  0
ib_cm                  45056  2 rdma_cm,ib_ipoib
rdmavt                 57344  1 hfi1
ib_core               208896  11 ib_iser,ib_cm,rdma_cm,ib_umad,ib_uverbs,rpcrdma,ib_ipoib,iw_cm,rdmavt,rdma_ucm,hfi1
```

unload rpcrmda
```bash
# lsmod | grep rpcrdma
sudo modprobe -r rpcrdma rdma_cm sunrpc ib_core
```