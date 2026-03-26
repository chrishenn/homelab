# Ofed Legacy: Manual Package Installs


## Install OFED

```bash
# BE VERY CAREFUL WITH THIS REMOVE
# SEEMS TO WANT TO DELETE ALL YOUR VIRTUALIZATION FILESYSTEM PACKAGES
# DO THE INSTALL BEFORE INSTALLING FROM THE MELLANOX REPO ??? WHY WOULD THYE ONLY MENTION IT AFTER ADDING THE REPO WTF

# per the mellanox website:
sudo apt purge libipathverbs1 librdmacm1 libibverbs1 libmthca1 libopenmpi-dev openmpi-bin openmpi-common openmpi-doc 
libmlx4-1 ibverbs-utils ibutils rdmacm-utils perftest infiniband-diags ibverbs-providers

# --add the repo--
apt update
apt install mlnx-ofed-basic
```

## proxmox 8.0.2

```bash
repo_root="http://linux.mellanox.com/public/repo/mlnx_ofed/23.10-1.1.9.0/debian12.1"
repo_url="$repo_root/$(dpkg --print-architecture)"

key_url="https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox"
key_name="RPM-GPG-KEY-Mellanox"
key_dir="/etc/apt/keyrings"
key_fname="$key_dir/$key_name"

list_url="$repo_root/mellanox_mlnx_ofed.list"
list_name="mellanox_mlnx_ofed.list"
list_dir="/etc/apt/sources.list.d"
list_fname="$list_dir/$list_name"

sudo mkdir -m 0755 -p "$key_dir"

wget -O- "$key_url" |
    gpg --dearmor |
    sudo tee "$key_fname" > /dev/null
    sudo chmod 644 "$key_fname"

wget $list_url -O "$list_fname"
nano "$list_fname"
echo "deb [signed-by=$key_fname] <leave-unchanged-here>" |
    sudo tee "$list_fname"
    sudo chmod 644 "$list_fname"
```

## Uninstall OFED

packages deleted
```bash
apt remove --purge *mlnx*

# classic mft / mst hardware config tools
mft
kernel-mft-dkms
mstflint

# ofed / classic mlx tools   
sudo apt install \
  ofed-scripts mlnx-ofed-basic mlnx-ofed-kernel-dkms mlnx-ofed-kernel-utils  mlnx-ethtool mlnx-iproute2 mlnx-tools 
 
# mentioned as conflicting by the ofed website
sudo apt install \
  infiniband-diags ibverbs-providers ibverbs-utils ibutils ibacm  \
  libibumad-dev libibverbs-dev  libopensm \
  libopensm-devel librdmacm-dev opensm opensm-doc rdma-core rdmacm-utils rshim srptools 
 
# questionable
sudo apt install \
  libibmad-dev libibmad5 libibnetdisc5 libfabric1 libibdm1 libosmcomp1 libibumad3 libjsoncpp25 \
  openmpi-bin libopenmpi-dev openmpi-doc openmpi-common libcoarrays-openmpi-dev 
```

## notes

NOTE: DO NOT INSTALL OFED IF YOU HAVE A QEMU/KVM SETUP ON A DEBIAN-LIKE OS
```bash
# same results by heading into /DEBS/ and trying to install mlnx_ofed_basic.deb, except apt will not uninstall 
# old/conflicting packages
# Those packages should be removed before uninstalling MLNX_OFED_LINUX:
# trying to uninstall these will absoutely nuke my qemu/kvm setup
```