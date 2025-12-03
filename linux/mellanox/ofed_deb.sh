#!/bin/bash

# this fails on ubu 25.10. dunno why
sudo apt install -y linux-headers-$(uname -r) apt-utils
sudo ./mlnxofedinstall --add-kernel-support --with-nfsrdma --skip-distro-check

# abandoning ofed for now
sudo apt install -y infiniband-diags srptools perftest opensm-doc librdmacm-dev \
	rdmacm-utils librdmacm1 ibacm libibmad-dev libibmad5 libibumad-dev libibumad3 \
	ibverbs-utils libibverbs-dev libibverbs1 mstflint rdma-core opensm fio librbd1 \
	librados2 libibnetdisc5 ibverbs-providers

ip a
# enp15s0np0

# you need rx and tx on
ethtool -a enp15s0np0
# Pause parameters for enp15s0np0:
# Autonegotiate:  off
# RX:             on
# TX:             on
