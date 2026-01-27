# Nvidia Driver

NOTE: latest open drivers are too new for older gpus like the GTX 1080

---

## Install

```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update

# NOTE: "open" drivers are too new for GTX 1080 - only GTX 1660 or later
sudo apt install nvidia-open

# "proprietary" drivers are compatible with older gpus (GTX 1080)
sudo apt install nvidia-driver-580

# if secure boot is enabled
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
```

## purge

```bash
sudo apt purge nvidia*
sudo apt autoremove --purge
sudo reboot now
```

## Install (ppa)

```bash
sudo add-apt-repository ppa:graphics-drivers/ppa
```

## Install (ubuntu-drivers)

note: not recommended

```bash
sudo ubuntu-drivers list

ubuntu-drivers devices
sudo ubuntu-drivers install nvidia

# 560 and 550 are buggy at time of writing
sudo ubuntu-drivers install nvidia:560

# for servers
sudo ubuntu-drivers install nvidia:560-server

# auto install for "server or comput"
sudo ubuntu-drivers install --gpgpu

# auto install (defaults to open-source drivers, it seems)
sudo ubuntu-drivers install
```

## Troubleshoot

```bash
sudo dmesg
# nvidia 0000:0a:00.0: probe with driver nvidia failed with error -1
# NVRM: installed in this system is not supported by open

grep nvidia /etc/modprobe.d/* /lib/modprobe.d/*
sudo update-initramfs -u

# sudo nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="pci=nocrs pci=realloc"
sudo update-grub

# not sure what nvidia prime helps with. Laptops?
sudo apt install nvidia-prime -y
sudo prime-select nvidia

# package that adds nviida modprobe config on boot? seems hacky
sudo apt install nvidia-modprobe
sudo nvidia-modprobe
```

---

## Uninstall

```bash
sudo apt remove --purge -y '^nvidia-.*'
sudo apt remove --purge -y '^libnvidia-.*'
sudo apt remove --purge -y '^cuda-.*'
sudo apt autoremove --purge -y
```

## Remove

```bash
sudo rm /etc/X11/xorg.conf
echo 'nouveau' | sudo tee -a /etc/modules
```

---

## Modesetting

None of this was necessary for 25.04

```bash
## modesetting and kernel module blacklist.
# modeset nvidia kernel mod
# sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<- 'END'
# options nvidia-drm modeset=1
# END

# blacklist nouveau
# sudo tee /etc/modprobe.d/blacklist-nvidia-nouveau.conf > /dev/null <<- 'END'
#sudo tee /etc/modprobe.d/blacklist-nouveau.conf > /dev/null <<- 'END'
#blacklist nouveau
#options nouveau modeset=0
#END

# modeset in kernel params
#> sudo nano /etc/default/grub
#nvidia_drm.modeset=1 fbdev=1

# update
# replaced by `sudo dracut --force` in 26.04
#sudo update-initramfs -u
#sudo update-grub

# (modesetting ref): this should not be necessary, but maybe on systems that previously didn't use an nvidia gpu
# sudo rm /lib/modprobe.d/blacklist-nvidia.conf
# modprobe.blacklist=nouveau
# nvidia-drm.modeset=1
```
