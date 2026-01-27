# Filen

Mount an S3-ish proxy to filen cloud files using the filne cli

```yml
# docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' filenS3
# mc alias set filen http://192.168.100.109:80 "filen_key" "filen_secret" --insecure --path "off" --api "s3v4"
filenS3:
    profiles: [nextcloud]
    image: filen/cli:latest
    container_name: filenS3
    environment:
        FILEN_EMAIL: ${FILEN_EMAIL}
        FILEN_PASSWORD: ${FILEN_PASSWORD}
        FILEN_2FA_CODE: ${FILEN_2FA_CODE}
    command: s3 --s3-access-key-id "filen_key" --s3-secret-access-key "filen_secret"
    networks: [traefik]
```

Mount to storage as network drive (could not get this to work)

```yml
# dc run -it --entrypoint /bin/sh filen
# /usr/local/bin/bunx filen-cli mount /root/filen
filen:
    profiles: [nextcloud]
    image: filen/cli:latest
    container_name: filen
    environment:
        FILEN_EMAIL: ${FILEN_EMAIL}
        FILEN_PASSWORD: ${FILEN_PASSWORD}
        FILEN_2FA_CODE: ${FILEN_2FA_CODE}
    volumes:
        - $DATA/filen/mnt:/root/filen
    command: mount /root/filen
```

Mount filen cloud files as webdav proxy

```yml
# webdav, login and pass, http://filen:80, uncheck 'secure https://', webdav_user, webdav_pass
filen:
    profiles: [nextcloud]
    image: filen/cli:latest
    container_name: filen
    environment:
        FILEN_EMAIL: ${FILEN_EMAIL}
        FILEN_PASSWORD: ${FILEN_PASSWORD}
        FILEN_2FA_CODE: ${FILEN_2FA_CODE}
    command: webdav --w-user "webdav_user" --w-password "webdav_pass"
    networks: [traefik]
```

---

# Filen Backrest Rclone

https://rclone.org/filen/
https://docs.filen.io/

The initial setup for Filen requires that you get an API key for your account, currently this is only possible using
the Filen CLI. This means you must first download the CLI, login, and then run the export-api-key command.

```bash
curl -sL https://filen.io/cli.sh | bash
# Added ~/.filen-cli/bin to $PATH in /home/chris/.bashrc
# Added ~/.filen-cli/bin to $PATH in /home/chris/.profile
. /home/chris/.bashrc

filen export-api-key
rclone config

# initial fill from gdrive local backup -> filen

# obscuring inline. rclone will also read password/api_key from these env vars, and they must be obscured already
cp -r /mnt/h/gdrive /mnt/h/filen
rclone sync -P \
--filen-email $RCLONE_FILEN_EMAIL \
--filen-password $(echo $RCLONE_FILEN_PASSWORD | rclone obscure -) \
--filen-api-key $(echo $RCLONE_FILEN_API_KEY | rclone obscure -) \
/mnt/h/filen \
:filen:

# as in
cp -r /mnt/h/gdrive /mnt/h/filen
rclone sync -P \
--filen-email $RCLONE_FILEN_EMAIL \
--filen-password $RCLONE_FILEN_PASSWORD \
--filen-api-key $RCLONE_FILEN_API_KEY \
/mnt/h/filen \
:filen:

# sync filen -> local, for restic to send local -> wasabi
rclone sync -P \
--filen-email $RCLONE_FILEN_EMAIL \
--filen-password $RCLONE_FILEN_PASSWORD \
--filen-api-key $RCLONE_FILEN_API_KEY \
:filen: \
/mnt/h/filen \
&& chown -R 1000:1000 /mnt/h/filen
```

---

# Filen Rclone Mount in Docker

note: this does not unmount correctly, resulting in "socket" errors on subsequent mounts.

```yml
services:
    filen:
        profiles: [nextcloud]
        image: ${REGISTRY}/rclone:latest
        build:
            context: ./rclone
            args:
                PUID: $PUID
                PGID: $PGID
        container_name: filen
        user: $PUID:$PGID
        privileged: true
        cap_add: [SYS_ADMIN]
        devices:
            - /dev/fuse:/dev/fuse
        security_opt:
            - apparmor:unconfined
        environment:
            RCLONE_FILEN_EMAIL: ${RCLONE_FILEN_EMAIL}
            RCLONE_FILEN_PASSWORD: ${RCLONE_FILEN_PASSWORD}
            RCLONE_FILEN_API_KEY: ${RCLONE_FILEN_API_KEY}
        volumes:
            - $DATA/filen:/home/appuser:shared
        entrypoint: ['/bin/sh']
        command: -c 'rclone mount :filen:/ /home/appuser/mnt --allow-non-empty --allow-other --allow-root'
        networks: [traefik]
```

---

# Filen Systemd Rclone Mount

note: this is reliable thus far. start and stop even works

run rclone manually to populate rclone.conf with credentials

add user_allow_other in
sudo nano /etc/fuse.conf

```systemd
# /etc/systemd/system/rclone_filen.service

[Unit]
Description=rclone filen mount
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
Environment=RCLONE_CONFIG=/home/chris/.config/rclone/rclone.conf
RestartSec=5
ExecStartPre=mkdir -p /home/chris/data/filen
ExecStart=/home/chris/.local/share/mise/installs/rclone/1.73.0/rclone-v1.73.0-linux-amd64/rclone mount filen:/ \
    /home/chris/data/filen --allow-non-empty --allow-other
ExecStop=/bin/fusermount3 -uz /home/chris/data/filen
Restart=on-failure
User=chris
Group=chris

[Install]
WantedBy=multi-user.target
```

sudo systemctl daemon-reload
sudo systemctl enable --now rclone_filen

sudo systemctl daemon-reload
sudo systemctl restart rclone_filen
sudo systemctl status rclone_filen
