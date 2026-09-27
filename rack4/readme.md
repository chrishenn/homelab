# Rack4 Docker Compose

Deploys to machine: rack4

Here's the general thrust of this setup:

- rack4 deploys this docker-compose stack
- some of those services depend on files here in rack4 - I sync them from my workstation to rack4 via github
- projects are provided with all the supporting docker services they would need to run standalone
  - each project gets its own postgres service, redis service, etc, as needed
- docker compose profiles are used to make sure all associated (single-project's worth) services are managed together
  - using the docker compose --profile <profile> flag
- services with an http ui are registered with a card on a single homepage instance
  - I had initially separated 'private' and 'public' services with two homepage instances, but gave up at some point
- web services are exposed through either traefik or newt/pangolin (or both)
  - traefik-routed services at a <name>.henn.dev domain resolve to a LAN ip
  - pangolin-routed services at a <name>.chenn.dev domain resolve to a public ip, which is pangolin, hosted on my
    hostinger vps0 machine
  - newt is hosted in a container on rack4, automatically reading pangolin resource config from docker labels
- public services are usually protected by pangolin SSO; some common policies are defined in
  homelab/vps0/pangolin/policies.yml

---

## dev

### update

Pull newer images and recreate all services. As long as the $REGISTRY image is not being updated, this can just be one
step

```bash
j pullup
```

### update local images

if services depend on images that are built locally, and depend on images that may have been updated, then to update
our local images we must manually build and push them to the local registry ($REGISTRY)

```bash
# Local images requiring a local build. The current list may be longer
imgs="openresume transcodarr blocky_k rsync bulwark opencut"
j build "$imgs"
j pullup core "$imgs"

# there's a bit of an ordering here; the local registry has service deps that it requires to work
# ie: traefik is needed to route zot.henn.dev; traefik_k binds traefik to the host's vip; zot requires its auth provider
# pocketid or else it crashes; pocketid is routed by pangolin via rack4 newt.
j pullup core zot traefik traefik_k pocketid newt
j pullup
docker system prune -a
```

### generate secrets

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
openssl rand -base64 32
openssl rand -hex 32
```

### generate vapid keys

```bash
npx web-push generate-vapid-keys
```
