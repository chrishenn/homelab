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

update

```bash
# update pangolin profile containers
just pullup pangolin

# update non-pangolin (note that stalwart will need to restart when stalwart_wg_exit is restarted)
just pullup c beszel_agent rustdesk_hbbs rustdesk_hbbr stalwart_wg_exit

# update all
just pullup
```

find a vps id

In hostinger dashboard, go to vps -> manage. The Vps ID is in the url.

add a terraform plugin

```bash
# need to build from main to get new firewall stuff. import from terraform registry when it's released
git clone https://github.com/hostinger/terraform-provider-hostinger
pushd terraform-provider-hostinger
go build -o terraform-provider-hostinger
popd
pulumi package add terraform-provider ./terraform-provider-hostinger/terraform-provider-hostinger
```

---

## todo

---

## Basic Auth Headers

```bash
echo -n "user:pass" | base64

# key: Authorization
# value: Basic <base64_hash>
```
