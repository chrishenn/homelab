# Rack4 Docker Compose Stack

Deploys to machine: rack4

You have to clone+pull the repo to the remote machine, to sync config files via github. Is it great? No. Do I want to
deal with a more complicated setup? Not right now.

---

# todo

- [x] Add a file provider monitoring on traefik in container.
    - [x] Then the split routing on blocky container can be removed.
- [x] idrive, gdrive backup LXC -> compose
- [x] github backup
- [x] backup storage: backrest local -> wasabi cloud
- [x] homarr -> homepage
- [x] netbootxyz: PXE DHCP config
    - [ ] PXE boot windows
- [x] matrix
- [ ] iventoy
- [ ] grafana + loki
- [ ] fluxer (not quite ready yet)
    - https://fluxer.app/

---

# dev

#### Build fresh local images

Make sure that all images served from $REGISTRY are already built and pushed to the registry.
`dc up --pull always` will NOT build and push missing images

```bash
# the current list may be longer
j build blocky_k openresume rsync rebuild

# bounce with pull, including from local REGISTRY
j down
j up forgejo
j up core traefik traefik_k
j pullup
```

---

# ref

https://github.com/Haxxnet/Compose-Examples/blob/main/examples/traefik/docker-compose.yml
https://github.com/juftin/homelab/blob/main/docker-compose.yaml
https://github.com/bluepuma77/traefik-best-practice
https://github.com/easyselfhost/self-host/blob/main/apps/webtop/docker-compose.yml
https://devhints.io/docker-compose
