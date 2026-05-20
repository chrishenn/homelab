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
- [ ] fluxer (not quite ready yet)
    - https://fluxer.app/

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
j build openresume transcodarr blocky_k rsync

# there's a bit of an ordering here; the local registry has service deps that it requires to work
# ie: traefik is needed to route zot.henn.dev; traefik_k binds traefik to the host's vip; zot requires its auth provider
# pocketid or else it crashes; pocketid is routed by pangolin via rack4 newt. 
j down
j pullup core zot traefik traefik_k pocketid newt
j pullup

# boot stack fresh
j login_docker
j up zot
j build openresume transcodarr blocky_k rsync
j up
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
