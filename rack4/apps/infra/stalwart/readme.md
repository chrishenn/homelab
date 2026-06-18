# stalwart

status

- email is working
- bulwark is working (including magic oidc setup with stalwart)
- unknown: are the storage containers (redis, s3, postgres) working correctly?
- unknown: are all the services (caldav, carddav) working?

Huge thanks to markfalk for sharing his working wireguard setup:

- https://github.com/markfalk/stalwart-mail-wgproxy

---

The goal:

- run stalwart/bulwark on my home machine
    - with a bunch of (relatively) heavy services like {redis, postgres, opensearch, garage}

Restrictions:

- Email must send from a public ip (non-residential)
- I have a vps that I prepaid for two years
- My Hostinger vps only gets one public ip
- The pangolin server I'm running on that vps binds ports {80, 443}, which are also needed for stalwart

The working setup:

- My pangolin instance running on hostinger (vps0) reverse-proxies mail.chenn.dev back to the stalwart and bulwark containers
  running on my home machine (rack4)
- I set up a wireguard tunnel between docker on vps0 and docker at home (rack4)
- The stalwart container (rack4) routes all outgoing traffic through the tunnel, exiting on vps0
    - except local traffic (rack4) to its storage containers {redis, postgres, opensearch, garage}
- The wireguard server on vps0 also binds to ports (25,465,993) and forwards them to stalwart through the tunnel

Because pangolin's traefik (vps0) is generating TLS certs for my domain, I need to run a somewhat convoluted scheme to dump
them into the format stalwart wants, then copy them from the pangolin host (vps0) to the stalwart host (rack4)

For the working setup, see:

- rack4/apps/infra/stalwart.yml
- vps0/apps/wg.yml

The failed setup:

- pangolin reverse-proxies mail.chenn.dev as above
- proxy_protocol tunnels TCP on (25,465,993) from vps0 to stalwart rack4
- problem: outgoing mail from stalwart -> WAN leaves from rack4
    - but it really needs to leave to WAN mailservers from a non-residential ip (vps0)
    - port 25 is universally blocked from residential IPs
- incoming mail from gmail.com -> stalwart succeeded
- DNS DKIM/DMARC etc tests were passing, but only after an insane wait time - like 30 seconds? Not sure why
- bulwark webmail works to recieve mail
- but the sending? no worky. also, failures were very slow.

For the failed setup, see:

- rack4/apps/infra/stalwart_proxy.yml

---

# Config

### Config: DNS (cloudflare)

- cloudflare dashboard -> chenn.dev -> dns -> settings -> enable dnssec
    - cloudflare automatically adds a DS record (to the dns parent! not your domain) if you also buy your domain from them
    - refresh the settings page to see DNSSEC is enabled
- cloudflare dashboard -> create a token with appropriate permissions to make DNS records on your domain

### Config: Wireguard

- pangolin/gerbil binds to the standard wireguard port on the vps (port 51820/udp), so I'll use 51821 for this tunnel
- punch port 51821/udp on the vps firewall

```bash
# generate key pairs for each wg endpoint ('client' on rack4, 'server' on vps0)
wg genkey
echo <privatekey> | wg pubkey

# disable the apparmor profile for wg-quick on vps0
sudo apt install -y apparmor-utils
sudo aa-complain /etc/apparmor.d/wg-quick

# verify tunneling is working
docker compose exec -it -u 0 stalwart /bin/bash
apt update && apt install -y iputils-ping
ping stalwart_db
# < should respond, meaning split-tunneling to local services is working >
curl ip.me
# < this should be the vps ip, not your home ip >
```

### Config: UI

- In the first-run wizard, choose manual TLS and DNS
- TLS -> Certificates
    - /data/certs/chenn.dev/cert.pem
    - /data/certs/chenn.dev/key.pem
- Network -> General -> Default Certificate
- Network -> HTTP -> General -> "Obtain remote IP from Forwarded header"
- Network -> HTTP -> Security -> "Enable HTTP Strict Transport"
- Actions -> Reload TLS Certificates
- Network -> DNS -> DNS Providers -> add Cloudflare with token
- Domains -> Domains -> DNS -> DNS Managment -> Automatic -> Record Types -> add them all
    - enabling automatic DNS management will push DNS records to cloudflare, replacing old ones where needed

### Config: Bulwark

- sign into https://mail.chenn.dev/webmail with your stalwart account
    - NOT your bulwark admin pass
    - NOT the dedicated admin page https://mail.chenn.dev/webmail/admin
- admin shield icon -> Authentication -> automagic oidc setup -> should work magically
- if you server bulwark on a different domain than stalwart, you'll need to loosen the CORS policy (untested)

### Config: CLI

After doing a full config in the web UI, I'll export the configuration objects I've changed. Hopefully I can re-create
this configuration state by applying this jsonl file

```bash
brew install stalwartlabs/tap/stalwart-cli

# I use mise/fnox to set these
export STALWART_URL=
export STALWART_USER=
export STALWART_PASSWORD=
stalwart-cli describe

# output to stdout does not write valid json for later doing cli-apply of the same. odd...output to jsonl instead
stalwart-cli snapshot SystemSettings Certificate Domain AcmeProvider DnsServer Directory Tenant Role Http \
    DataStore BlobStore SearchStore InMemoryStore \
    --output $REPO/rack4/apps/infra/stalwart/stalwart.jsonl

# (untested)
stalwart-cli apply $REPO/rack4/apps/infra/stalwart/stalwart.jsonl
```

### Config: Loose Ends

- "reverse DNS does not match the sending domain"
    - I think this PTR record is configurable under hostinger dash for vps0
    - I set it to 'chenn.dev' but maybe it should be 'mail.chenn.dev'
    - hostinger dash didn't update the value?
    - they do warn that it takes hours, so we'll see later

### Testing

- https://www.mail-tester.com/
- https://www.checktls.com/TestReceiver
- https://mxtoolbox.com/SuperTool.aspx
