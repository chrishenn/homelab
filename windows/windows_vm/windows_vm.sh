#!/bin/bash

# Note: we got issues here, trying to pass through an AMD iGPU. Kinda more than I'm up for right this second
# see the bottom of this file

# this guide includes looking glass with a shared fbuffer. not sure the full extent of what this requires
# https://tek.place/en/posts/2024/02/setting-up-gpu-passthrough-with-kvm-on-ubuntu-for-windows/
# https://discourse.ubuntu.com/t/qemu-gpu-passthrough/54509
# https://github.com/HarbourHeading/KVM-GPU-Passthrough

# ---

# check hardware compat
grep -Ec '(vmx|svm)' /proc/cpuinfo
##> 32 (number of cores enabled with virt extensions)

sudo dmesg | grep -E "VT-d|AMD-Vi"
##> AMD-Vi: IOMMU performance counters supported

# if iommu not enabled, edit kernel params to enable intel or amd iommu for your cpu
# amd_iommu=on
# intel_iommu=on
# iommu=pt

sudo apt install -y cpu-checker
sudo kvm-ok
##> INFO: /dev/kvm exists
##> KVM acceleration can be used

# kernel modules
sudo tee -a /etc/initramfs-tools/modules <<-'END'
	vfio
	vfio_iommu_type1
	vfio_pci
	vfio_virqfd
	vhost-net
END
sudo update-initramfs -u
##> reboot if you did this

# install
sudo apt install -y qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf virtiofsd
sudo adduser "$USER" libvirt
sudo adduser "$USER" kvm
sudo systemctl enable --now libvirtd

##> log out and back in

# verify
systemctl status libvirtd
sudo virsh list --all
groups chris

# download the virtio drivers
curl -Lo virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
sudo mv virtio-win.iso /var/lib/libvirt/images

# this skeleton includes the hook-helper script
curl -Lo repo.zip https://github.com/slackdaystudio/qemu-gpu-passthrough/archive/refs/heads/main.zip
sudo unzip repo.zip -d repo
sudo cp -r repo/qemu-gpu-passthrough-main/qemu_hook_skeleton/* /etc/libvirt/hooks/
sudo rm -rf repo repo.zip
sudo systemctl restart libvirtd

# see iommu.sh to find relevant pcie addresses/devices
# IOMMU Group: 14 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3090] [10de:2204]
# IOMMU Group: 31 7b:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Granite Ridge

# use the pcie addresses you found from iommu.sh to edit kvm.conf
sudo nano /etc/libvirt/hooks/kvm.conf
# gpu="0000:7b:00.0"
# aud="0000:7b:00.1"

# symlink hooks into vm's hook locations for prepare, release
sudo virsh list --all
sudo ln -sf "/etc/libvirt/hooks/qemu.d/.gpu-passthrough" "/etc/libvirt/hooks/qemu.d/win11"

# GUI steps
# use vmmanager GUI to add gpu to VM
# vm settings -> hardware -> host device -> gpu, aud individually -> add -> pci -> add

# in the VM, install the relevant graphics driver
# https://www.amd.com/en/support/download/drivers.html

# mount vfio drivers iso into the vm. in the vm, install vfio drivers by finding the cdrom and running the installer

# code 43
# oh no. Found the solution?
# https://www.reddit.com/r/VFIO/comments/16mrk6j/amd_7000_seriesraphaelrdna2_igpu_passthrough/?sort=new
# another solution
# https://forums.unraid.net/topic/112649-amd-apu-ryzen-5700g-igpu-passthrough-on-692/page/6/

# also suggested:
# disable resizable bar?
# disable above 4g decoding?
# disable CAM clever access memory?
# disable CSM?
# disable spice?
# connect a physical display to the gpu output
# connect a dummy plug to the gpu output
