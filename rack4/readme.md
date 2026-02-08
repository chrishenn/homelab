# Rack4 Docker Compose Stack

- Redundant blocky and blocky_keepalived with Rack4
- Redundant traefik and traefik_keepalived with Rack4
- Beszel stats reporter, beszel server
- Various other containers

Deploys to machine: rack4

---

You have to clone/pull the repo to the remote machine, to sync {traefik, blocky} config files.

# Refs

https://github.com/Haxxnet/Compose-Examples/blob/main/examples/traefik/docker-compose.yml
https://github.com/juftin/homelab/blob/main/docker-compose.yaml
https://github.com/bluepuma77/traefik-best-practice
https://github.com/easyselfhost/self-host/blob/main/apps/webtop/docker-compose.yml
https://devhints.io/docker-compose

# Todo

- [x] Add a file provider monitoring on traefik in container.
    - [x] Then the split routing on blocky container can be removed.
- [x] Migrate idrive, gdrive backup LXC's to containers.
- [x] Migrate backups to wasabi cloud
- [x] Replace homarr with homepage
- [ ] ~~Need a script to copy-paste homepage settings into the config folder~~
    - [x] Mounted the config folder from src
- [x] rebuild the rsync image with the new alpine tag (working: 3.20) and test (alpine:3.21 and later are totally
      broken)
    - note: this error is supercronic not being able to find the crontab
- [x] netbootxyz: DHCP config needed to make it work
    - if you ignore 32-bit systems and legacy bios machines, it's actually very easy. Set the next_server and you're
      done
    - [ ] netboot windows (requires extracting an iso)
- [ ] iventoy
- [x] conduit/synapse
- [ ] grafana + loki
- [ ] localsend server

---

# Dev

#### Build fresh local images

Make sure that all images served from REGISTRY are already built and pushed to the registry.
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
