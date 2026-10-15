#!/bin/bash

# shares: tmp
sudo tee -a /etc/exports >/dev/null <<-END
	/tmp 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash)
END

# shares
sudo tee -a /etc/exports >/dev/null <<-END
	/var/mnt/f 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash,mp)
	/var/mnt/h 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash,mp)
	/var/mnt/k 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash,mp)
	/var/mnt/r 192.168.1.0/24(rw,async,insecure,no_subtree_check,no_root_squash,mp)
END

# shares: zfs
sudo zfs set sharenfs="rw=@192.168.1.0/24,async,insecure,no_subtree_check,no_root_squash" pool1

sudo exportfs -a
sudo systemctl restart nfs-server

# verify
sudo exportfs -v

# client mounts
sudo mkdir -p \
	/var/mnt/f \
	/var/mnt/h \
	/var/mnt/k \
	/var/mnt/r

# minimal options
192.168.1.142:/var/mnt/f /var/mnt/f nfs defaults,proto=rdma,async,noatime,nodiratime 0 0

# only some nfs mounts aren't mounting at boot (kubuntu 26.04, 7.0.0-14-generic)
opt="auto,nofail,soft,intr,x-systemd.automount,x-systemd.mount-timeout=1s,timeo=10,retrans=3,_netdev,x-systemd.after=network-online.target,defaults,proto=rdma,async,noatime,nodiratime"
sudo tee -a /etc/fstab >/dev/null <<-END
	192.168.1.142:/var/mnt/f /var/mnt/f nfs $opt 0 0
	192.168.1.142:/var/mnt/h /var/mnt/h nfs $opt 0 0
	192.168.1.142:/var/mnt/k /var/mnt/k nfs $opt 0 0
	192.168.1.142:/var/mnt/r /var/mnt/r nfs $opt 0 0
END

sudo systemctl daemon-reload
sudo mount -a
