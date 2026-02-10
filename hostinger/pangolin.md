# pangolin

hosted on hostinger VPS

---

# install

```bash
# in the hostinger web console, open firewall ports:
# 80 (TCP), 443 (TCP), 51820 (UDP), and 21820 (UDP for clients)

# in the cloudflare web console, add a DNS A record to point to pangolin VPS

# pangolin installer
mkdir -p ~/pangolin && cd pangolin
curl -fsSL https://static.pangolin.net/get-installer.sh | bash
sudo ./installer
```

---

# config

Note the non-standard smtp SSL port 465.
The standard port is 587, which didn't work for me

```bash
$SSH_CHRIS -t "cd /home/chris/pangolin ; bash --login"

# connect to proton smtp
sudo nano config/config.yml

sudo chris pass:
op read "op://homelab/vps0/chris_pass"

email:
    smtp_host: "op://homelab/proton/SMTP/smtp_host"
    smtp_port: 465
    smtp_user: "op://homelab/proton/SMTP/smtp_user"
    smtp_pass: "op://homelab/proton/SMTP/smtp_token"
    no_reply: "op://homelab/proton/SMTP/smtp_user"
    smtp_secure: true
    smtp_tls_reject_unauthorized: true

docker compose restart
```

# update

```bash
$SSH_CHRIS -t "cd /home/chris/pangolin ; bash --login"
sudo cp -r config config_backup
docker compose down

# edit the tags manually. Or, set them all to "latest" or "ee-latest"
sudo nano docker-compose.yml

# update the version under experimental.plugins.badger.version
# https://github.com/fosrl/badger/releases
sudo nano config/traefik/traefik_config.yml

docker compose up -d --pull always
docker compose logs -f
```

traefik fix

```bash
 sudo nano config/traefik/traefik_config.yml
```
