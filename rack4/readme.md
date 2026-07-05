# Rack4 Docker Compose Stack

Deploys to machine: rack4

You have to clone+pull the repo to the remote machine, to sync config files via github. Is it great? No. Do I want to
deal with a more complicated setup? Also no.

---

# todo

- [x] netbootxyz
- [x] use a docker registry that requires no manual config (zot. done!)
    - [ ] enable mTLS
- [ ] a way to PXE boot windows
    - [ ] iventoy?
    - [ ] netbootxyz?
- [ ] grafana + loki
- [ ] fluxer server (not quite ready yet)
    - https://fluxer.app/
- [ ] stoat chat server (not quite ready yet)
    - https://stoat.chat/

---

# dev

#### update

Pull newer images and recreate all services. As long as the $REGISTRY image is not being updated, this can just be one
step

```bash
j pullup
```

#### update local images

if services depend on images that are built locally, and depend on images that may have been updated, then to update
our local images we must manually build and push them to the local registry ($REGISTRY)

```bash
# Local images requiring a local build. The current list may be longer
j build openresume transcodarr blocky_k rsync bulwark

# there's a bit of an ordering here; the local registry has service deps that it requires to work
# ie: traefik is needed to route zot.henn.dev; traefik_k binds traefik to the host's vip; zot requires its auth provider
# pocketid or else it crashes; pocketid is routed by pangolin via rack4 newt.
j down
j pullup core zot traefik traefik_k pocketid newt
j pullup

# boot stack fresh
j login_docker
```

---

# ref

- https://github.com/Haxxnet/Compose-Examples/blob/main/examples/traefik/docker-compose.yml
- https://github.com/juftin/homelab/blob/main/docker-compose.yaml
- https://github.com/bluepuma77/traefik-best-practice
- https://github.com/easyselfhost/self-host/blob/main/apps/webtop/docker-compose.yml
- https://devhints.io/docker-compose

generate secrets

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
openssl rand -base64 32
openssl rand -hex 32
```

host pangolin install for ssh access

```bash
newt \
--id ${RACK4_NEWT_ID} \
--secret ${RACK4_NEWT_SECRET} \
--endpoint ${VPS0_PANGOLIN_ENDPOINT}

sudo mkdir -p /etc/newt
sudo tee -a /etc/newt/newt.env >/dev/null <<- END
NEWT_ID=${RACK4_NEWT_ID}
NEWT_SECRET=${RACK4_NEWT_SECRET}
PANGOLIN_ENDPOINT=${VPS0_PANGOLIN_ENDPOINT}
END
sudo chmod 600 /etc/newt/newt.env

sudo tee -a /etc/systemd/system/newt.service >/dev/null <<- END
[Unit]
Description=Newt
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
Group=root
EnvironmentFile=/etc/newt/newt.env
ExecStart=/usr/local/bin/newt
Restart=always
RestartSec=2
UMask=0077
PrivateTmp=true

[Install]
WantedBy=multi-user.target
END

sudo systemctl daemon-reload
sudo systemctl enable --now newt
sudo systemctl status newt
```

pangolin blueprints for public-policies from docker labels are not applying?

```bash
curl -fsSL https://static.pangolin.net/get-cli.sh | bash
pangolin login
pangolin select org --org coop
pangolin apply blueprint --file $REPO/rack4/policies.yml
```
