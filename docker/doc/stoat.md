# stoat chat

A real, functional, discord replacement! Assuming that it scales to a couple dozen people in a server.

- running on docker rack4
- exposed by pangolin on vps0

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
- I bound 40 udp ports 50000-50040 instead of the recommended 100. Just because pangolin config is cumbersome for port
  ranges

pangolin

- pangolin can reverse proxy each service, but it can't mangle headers on a per-target basis

secrets

- I inlined the secrets into the configs, but you can pass the revolt.toml secrets as env vars

Create an invite code:

```bash
just stoat_invite

# which just does
export invite=$(openssl rand -hex 32)
docker compose exec -it stoat_db mongosh revolt --eval "db.invites.insertOne({ _id: \"$invite\" })"
```
