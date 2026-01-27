# samba client

note: use nfs instead where possible

---

samba client: install and mount

```bash
sudo apt install -y cifs-utils
sudo mkdir -p /mnt/h /mnt/k /mnt/f /mnt/q
sudo nano /etc/fstab

//192.168.1.142/f /mnt/f cifs uid=1000,gid=1000,user=<user>,pass=<pass>,vers=3,noatime,auto,nobrl,noperm 0 0
//192.168.1.142/h /mnt/h cifs uid=1000,gid=1000,user=<user>,pass=<pass>,vers=3,noatime,auto,nobrl,noperm 0 0
//192.168.1.142/k /mnt/k cifs uid=1000,gid=1000,user=<user>,pass=<pass>,vers=3,noatime,auto,nobrl,noperm 0 0
//192.168.1.142/q /mnt/q cifs uid=1000,gid=1000,user=<user>,pass=<pass>,vers=3,noatime,auto,nobrl,noperm 0 0

sudo systemctl daemon-reload
sudo mount -a
```

---

Samba client permissions issue (esp docker).
I'm gonna try mounting without spec file mode, and see how perms appear on client machine.
Yeah they match the perms on the server machine. So, the server still owns the files, and will need to set the perms.
But then they will be visible to the client mount as-is.
I assume because I'm spec uid/gid 1000/1000, I can never access a file with perm 600 on the server, even if the
container
is running as root on the client.

alternatively, you can make a file to hold credentials

```bash
# /home/chris/.smbcredentials
username=<user>
password=<pass>

# /etc/fstab
credentials=/home/chris/.smbcredentials,iocharset=utf8,sec=ntlm
```

command reference

```bash
# it looks like the uid=1000 option from the above standar line also forces "forceuid", but here you can spec manually
//192.168.1.142/k /mnt/k cifs uid=1000,gid=1000,user=<user>,pass=<pass>,forceuid,forcegid 0 0
file_mode=0777,dir_mode=0777,uid=1000,gid=1000,user=<user>,pass=<pass>,vers=3,noatime,auto,nobrl,noperm
file_mode=0777,dir_mode=0777,uid=1000,gid=1000,user=<user>,pass=<pass>,vers=3.0,soft,nofail,noauto,
    x-systemd.automount,x-systemd.device-timeout=5s,iocharset=utf8,cache=loose,fsc,users,guest,noperm,noatime
```
