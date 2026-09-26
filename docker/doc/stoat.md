# stoat chat

A real, functional, discord replacement! Assuming that it scales to a couple dozen people in a server.

- running on docker rack4
- exposed by pangolin on vps0
- generate an invite code: `j stoat_invite`

---

- general notes
  - gifbox currently broken everywhere - probably on me
  - UI lacks polish
  - pretty damn simple to configure (esp compared to fluxer - what a mess)
  - video playback is at the whim of the codec gods - highly variable support on diff browsers and platforms
  - there are third-party clients for android and desktop, which is very cool
- web client
  - voice/video won't connect
- android app
  - It can't connect to a custom url :(
  - best-case on android is dekstop mode in chrome browser. Not the worst, but not great
- linux desktop client
  - can connect to my server with `/var/home/chris/.local/share/soar/bin/stoat --force-server=https://stoat.chenn.dev`
  - limited video codecs supported - probably electron's fault - but playback works for supported vids
  - screen share works, but refreshes are limited, encoding is limited, resolutions are limited
  - can't handle pangolin auth

---

In this setup, my services are publicly available on ${VPS0_IP}, and tunneled back to docker containers running in my
laundry room at home

stoat_db

- mongo:8 requires that GLIBC_TUNABLE or else it crashes after a minute - some cpu microarch problem in mongo

stoat-s3

- underscores not allowed in RUSTFS_SERVER_DOMAINS, which must match the service name, network alias, and bucket region
- this rigidity is likely due to rustfs being a bit more picky than minio
- I also had to add aux containers to set the file perms, and create the default bucket, both of which rustfs does not do

livekit.yml

- I set 'use_external_ip: false' and hardcoded the public vps ip VPS0_IP into the livekit start cmd '--node-ip'
- I'm using two ports for media instead of the port ranges - livekit doc sucks donkey - can't find any info as to whether
    this will matter for perf or not

pangolin

- pangolin can reverse proxy each service, but it can't mangle headers on a per-target basis, so caddy is required

secrets

- I inlined the secrets into the configs, but you can pass the revolt.toml secrets as env vars

Create an invite code:

```bash
just stoat_invite

# which just does
export invite=$(openssl rand -hex 32)
docker compose exec -it stoat_db mongosh revolt --eval "db.invites.insertOne({ _id: \"$invite\" })"
```
