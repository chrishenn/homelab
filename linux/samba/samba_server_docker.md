# samba server docker

not working yet

to try
https://hub.docker.com/r/servercontainers/samba
https://github.com/crazy-max/docker-samba

---

note: nonworking
https://github.com/dperson/samba

```bash
docker run -d --name samba \
--restart unless-stopped \
-e "USERID=1000" \
-e "GROUPID=1000" \
--net=host \
-m 16g \
-v /pool0:/pool0 \
-v /mnt/p:/mnt/p \
-d dperson/samba \
-g "security = user" \
-g "encrypt passwords = true" \
-g "force create mode = 0777" \
-g "store dos attributes = no" \
-g "unix extensions = no" \
-g "wide links = yes" \
-g "strict locking = no" \
-u "$USER;$PASS" \
-s "m;/pool0;yes;no;no;all" \
-s "p;/mnt/p;yes;no;no;all"
```

---

note: nonworking
https://github.com/dockur/samba

initial try, one container per share

```bash
services:
  samba-p:
    image: dockurr/samba
    container_name: samba-p
    environment:
      NAME: "p"
      USER: ${USER}
      PASS: ${PASS}
      UID: "1000"
      GID: "1000"
    volumes:
      - /mnt/p:/storage
    restart: unless-stopped
    network_mode: host
  samba-m:
    image: dockurr/samba
    container_name: samba-m
    environment:
      NAME: "m"
      USER: ${USER}
      PASS: ${PASS}
      UID: "1000"
      GID: "1000"
    volumes:
      - /pool0:/storage
    restart: unless-stopped
    network_mode: host
```

suggested smb.conf

```bash
[global]
	server string = samba
	idmap config * : range = 3000-7999
	security = user
	server min protocol = SMB2

	# disable printing services
	load printers = no
	printing = bsd
	printcap name = /dev/null
	disable spoolss = yes

[Data]
	path = /storage
	comment = Shared
	valid users = @smb
	browseable = yes
	writable = yes
	read only = no
	force user = root
	force group = root
```

second try, both shares in one container/service. The bash script that runs the user-creation logic in the container may not be able to handle this

```bash
services:
  samba:
    image: dockurr/samba
    container_name: samba
    environment:
      USER: ${USER}
      PASS: ${PASS}
      UID: "1000"
      GID: "1000"
    volumes:
      - /mnt/p:/mnt/p
      - /pool0:/pool0
    restart: unless-stopped
    network_mode: host
```

```bash
[global]
	server string = samba
	idmap config * : range = 3000-7999
	security = user
	server min protocol = SMB2

	# disable printing services
	load printers = no
	printing = bsd
	printcap name = /dev/null
	disable spoolss = yes

[m]
path = /pool0
browseable = yes
read only = no
guest ok = no
writable = yes
valid users = @chris

[p]
path = /mnt/p
browseable = yes
read only = no
guest ok = no
writable = yes
valid users = @chris
```
