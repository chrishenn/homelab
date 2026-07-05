# vps0: Hostinger vps running Pangolin: Server Setup, CloudFlare DNS (Pulumi)

- Connect to hostinger vps "vps0", push docker configs (sync this repo via git)
- Bring up pangolin server on vps0
- Create the necessary DNS entries in cloudflare using pulumi

---

## create dns records with pulumi

```bash
# preview the resource plan
pulumi preview --save-plan=plan.json

# apply
pulumi up
```

verify open ports on vps

```bash
# when the batch size -b is too big, no open ports are found, even though there are several
rustscan -a pangolin.chenn.dev -b 10
```

## dev

update containers

```bash
just pullup
# docker compose up -d --remove-orphans --force-recreate --pull always
```

---

## todo

- pulumi has a hostinger provider - use that to configure the VPS, rather than the bash snippets used here
- set up docker host with secure remote access from local docker cli

---

## Basic Auth Headers

```bash
echo -n "user:pass" | base64

# key: Authorization
# value: Basic <base64_hash>
```
