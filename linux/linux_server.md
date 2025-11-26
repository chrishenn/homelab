# Linux/Ubuntu Server Setup for {Rack2, Rack4}

Tested with: Kubuntu 25.04

This is a complete config example, so it will duplicate some configs from other repos

---

```bash
# apt basics
sudo apt update && sudo apt upgrade -y
sudo apt install -y "linux-headers-$(uname -r)" build-essential dkms git net-tools curl openssl wget \
    openssh-server

# set ssh to listen on 2200
sudo sd '^(#*)Port(\s){1}(.*)$' "Port 2200" /etc/ssh/sshd_config

sudo systemctl daemon-reload
sudo systemctl enable --now ssh
> sudo lsof -i :22

# disable sleep
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# disable firewall
sudo ufw disable

# git clone the homelab repo
# > install dotfiles
# > mise global tools will put sd, other tools on the path
```

---

# Network

## network - stable nic names

```bash
> sudo nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0"
sudo update-grub

# use systemd to assign nic names.
# NOTE: the name must not collide with any automatic names. Hence I've gone with `nic0` over `eth0`
> sudo nano /etc/systemd/network/10-eth0.link

[Match]
# rack0
# MACAddress=a8:a1:59:49:6e:e9

# rack4
# MACAddress=98:03:9b:ad:37:d0

# kubu
MACAddress=98:03:9b:8c:85:02

[Link]
Name=nic0

# reboot for rules to apply
sudo reboot now
```

## network - upstream DNS

```bash
# rack4 (serves two DNS resolvers, one on each of two IPs)
mac="98:03:9b:ad:37:d0"
ip0="192.168.1.142"
ip1="192.168.1.143"

# rack2
mac="3c:fd:fe:34:d9:82"
ip0="192.168.1.65"

# networkmanager: connection settings (NOT DNS)
function add_con() {
    con="con0"
    gateway="192.168.1.1"

    # empty interface name will allow the connection to follow the nic's mac address instead
    sudo nmcli con add type ethernet con-name "$con"
    sudo nmcli con mod "$con" connection.interface-name ""
    sudo nmcli con mod "$con" 802-3-ethernet.mac-address "$mac"
    sudo nmcli con mod "$con" ethernet.auto-negotiate yes
    sudo nmcli con mod "$con" +ipv4.addresses "$ip0/24" gw4 "$gateway"
    sudo nmcli con mod "$con" +ipv4.addresses "$ip1/24" gw4 "$gateway"
    sudo nmcli con mod "$con" ipv4.method manual
    sudo nmcli con down "$con" || true
    sudo nmcli con up "$con"
}

# networkmanager: do not manage DNS
sudo nano /etc/NetworkManager/NetworkManager.conf

[main]
dns=none
systemd-resolved=false

# restart
sudo systemctl daemon-reload
sudo systemctl restart NetworkManager
sudo systemctl restart systemd-resolved
```

## network - bind to port 53 (DNS server)

```bash
# global dns. note: more than 3 ips in this list may mean that the last ones are ignored
dns="192.168.1.143 192.168.1.3 192.168.1.1 1.1.1.1"

# set global DNS for all connections, using systemd-resolved
sudo $(which sd) '^#(.*)DNS=(.*)$' "DNS=$dns" /etc/systemd/resolved.conf
sudo $(which sd) '^#(.*)DNSStubListener=(.*)$' "DNSStubListener=no" /etc/systemd/resolved.conf
sudo rm /etc/resolv.conf
sudo ln -sf /var/run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```

## sysctl configs

```bash
# allow binding to ip addresses that don't exist yet (virtual IPs for keepalived)
# vm overcommit for redis
# fs.inotify to allow more open files being watched (various containers need it)
# disable ipv6 to simplify networking problems
# note: /etc/sysctl.conf doesn't get loaded on boot, it seems. /etc/sysctl.d/* does
sudo tee /etc/sysctl.d/99-custom.conf -a > /dev/null <<- 'END'
net.ipv4.ip_nonlocal_bind=1
vm.overcommit_memory=1
fs.inotify.max_user_watches=1014796
fs.inotify.max_user_instances=1014796
fs.inotify.max_queued_events=1014796
net.ipv6.conf.all.disable_ipv6=1
END
sudo sysctl --system
```

---

# samba, zfs

```bash
# zfs
sudo apt install -y zfsutils-linux

# create nvdev aliases for zfs
> sudo nano /etc/zfs/vdev_id.conf
alias 00 /dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NG0R404905T
alias 01 /dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NG0R404904D
alias 02 /dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NG0R514123R
alias 03 /dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NG0NB01081T
alias 04 /dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7KGNU0Y409303H
alias 05 /dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7KGNU0Y409341W
sudo udevadm trigger

# create a new pool
pool="pool0"
mnt="/mnt/m"
sudo zpool create -o ashift=13 -O recordsize=1M -O atime=off -O dedup=off -O compression=off -O xattr=sa -O checksum=off $pool 00 01 02 03
sudo zfs set mountpoint=$mnt $pool
sudo chown -R chris:chris $mnt
sudo chmod -R 777 $mnt

# bind an existing zpool pool0 at $mnt
sudo mkdir -p $mnt
sudo chown -R chris:chris $mnt
sudo chmod -R 777 $mnt
sudo zpool import pool0 -f
sudo zfs set mountpoint=$mnt pool0

# samba server
sudo apt install samba -y
sudo smbpasswd -a $USER
sudo smbpasswd -e $USER
sudo ufw allow samba
sudo systemctl enable --now smbd

# configure samba shares
> sudo nano /etc/samba/smb.conf
> see samba/smb.con
sudo systemctl restart smbd
```

---

# nvidia driver, docker, cuda container toolkit

```bash
# nvidia driver (requires reboot to load kernel)
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y nvidia-drivers # (or nvidia-open for GTX 1660 and newer)

# docker (requires logout and login to make docker cli command avail to user)
curl -fsSL https://get.docker.com -o docker.sh && sudo sh docker.sh
sudo usermod -aG docker "$USER"

# cuda container tools
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
	&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
	sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
	sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default

# docker enable TCP socket. NOTE that this will soon be deprecated
> sudo systemctl edit docker.service
# place this in the edit zone near the top
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock -H fd:// -H tcp://192.168.1.142:2375

# reboot
> sudo reboot now

# test
> docker run hello-world
> sudo netstat -lntp | grep dockerd
> docker run --rm --runtime=nvidia --gpus all bitnami/minideb nvidia-smi
```

---

## ssh agent autostart

autostart the default ssh agent (not sure why I needed this on rack4?)

```bash
sudo tee /etc/systemd/system/ssh-agent.service > /dev/null <<- 'END'
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
END

sudo systemctl daemon-reload
sudo systemctl enable --now ssh-agent
```

## networkmanager configs

```bash
# networkmanager don't manage various devices
> sudo nano /etc/NetworkManager/NetworkManager.conf

> by mac
[device-mac525400747956-unmanaged]
match-device=mac:52:54:00:74:79:56
managed=0

> by type
[device-ethernet-unmanaged]
match-device=type:ethernet
managed=0

> multiples
[usbnet-unmanaged]
match-device=interface-name:usb0
managed=0

# if you get "interface is strictly unamanged" then
> sudo nano /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf

# add, maybe the below or some such as appropriate, matcher syntax above
[keyfile]
unmanaged-devices=*,except:type:ethernet

# perhaps I don't want nm to manage docker interfaces, but only the singular main one?
[keyfile]
unmanaged-devices=*,except:interface-name:eth2
```
