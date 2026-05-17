#!/bin/bash

# shares: tmp
sudo tee -a /etc/exports >/dev/null <<-END
	/tmp 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
END

# shares
sudo tee -a /etc/exports >/dev/null <<-END
	/mnt/h 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
	/mnt/k 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
	/mnt/f 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
END

# shares: zfs
sudo zfs set sharenfs="rw=@192.168.1.0/24,async,insecure,no_subtree_check,no_root_squash" pool1

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# verify
sudo exportfs -v

# client mounts
sudo mkdir -p \
	/var/mnt/f \
	/var/mnt/h \
	/var/mnt/k \
	/var/mnt/q

# minimal
192.168.1.142:/var/mnt/f /var/mnt/f nfs defaults,proto=rdma,async,noatime,nodiratime 0 0

# only some nfs mounts aren't mounting at boot (kubuntu 26.04, 7.0.0-14-generic)
sudo tee -a /etc/fstab >/dev/null <<-END
	192.168.1.142:/var/mnt/f /var/mnt/f nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
	192.168.1.142:/var/mnt/h /var/mnt/h nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
	192.168.1.142:/var/mnt/k /var/mnt/k nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
	192.168.1.142:/var/mnt/q /var/mnt/q nfs x-systemd.automount,x-systemd.mount-timeout=20,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime 0 0
END

sudo systemctl daemon-reload
sudo mount -a
