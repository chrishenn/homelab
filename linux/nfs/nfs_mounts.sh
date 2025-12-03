#!/bin/bash

# shares
sudo tee -a /etc/exports >/dev/null <<-END
	/tmp 192.168.1.0/24(rw,async,insecure,no_root_squash)
	/mnt/h 192.168.1.0/24(rw,async,insecure,no_root_squash)
	/mnt/k 192.168.1.0/24(rw,async,insecure,no_root_squash)
	/mnt/f 192.168.1.0/24(rw,async,insecure,no_root_squash)
END

# shares: zfs
sudo zfs set sharenfs="rw=@192.168.1.0/24,async,insecure,no_root_squash" pool1

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# verify
sudo exportfs -v

# client mounts
sudo mkdir -p /mnt/h /mnt/k /mnt/f /mnt/q

sudo tee -a /etc/fstab >/dev/null <<-END
	192.168.1.142:/mnt/h /mnt/h nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
	192.168.1.142:/mnt/k /mnt/k nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
	192.168.1.142:/mnt/f /mnt/f nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
	192.168.1.142:/mnt/q /mnt/q nfs defaults,proto=rdma,port=20049,async,noatime,nodiratime 0 0
END

sudo systemctl daemon-reload
sudo mount -a
