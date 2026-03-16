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

---

# auth

This config is for compose services on the same host as your pangolin+traefik+gerbil

pangolin's traefik must trust headers from the pangolin container. I locked the pangolin ip via docker-compose
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pangolin
172.18.0.2

sudo nano docker-compose.yml
the default network {name: "pangolin", reference: "default"} is defined by pangolin's docker compose

```yml
networks:
    default:
        ipv4_address: 172.18.0.2
```

sudo nano config/traefik/traefik_config.yml

```yml
entryPoints:
    websecure:
        address: :443
        forwardedHeaders:
            trustedIPs:
                - 172.18.0.2/16
```

Any docker svcs managed by the same traefik instance as this tinyauth one just need to attach the tinyauth middleware
and traefik will redirect them to the tinyauth middleware for auth:
traefik.http.routers.[your-svc-router].middlewares: tinyauth

This means that my services on a remote site (NOT on the same docker network as pangolin+traefik+gerbil on my vps)
will not be able to advertise that traefik router label to the correct traefik instance

We need to run the tinyauth traefik middleware on the docker compose stack with pangolin, and attach pangolin services
to the same middleware. Pangolin's interface (and blueprints) don't currently expose a way to attach arbitrary
middleware

The project would like to add this:
https://github.com/orgs/fosrl/discussions/215

There is an existing solution, with a somewhat complicated setup:
https://docs.pangolin.net/self-host/community-guides/middlewaremanager
https://forum.hhf.technology/t/implementing-external-authentication-in-pangolin-using-tinyauth-and-the-middleware-manager/1417
https://forum.hhf.technology/t/enhancing-your-pangolin-deployment-with-middleware-manager/1324

Someone added exactly what I'd want in a pangolin fork. Odd that it's been a year now and they haven't merged this:
https://github.com/fosrl/pangolin/compare/main...sippeangelo:pangolin:middlewares

There's a traefik plugin that provides and OIDC middleware, which I assume falls under the same issue as pangolin+tinyauth:
https://plugins.traefik.io/plugins/66b63d12d29fd1c421b503f5/oidc-authentication
https://traefik-oidc-auth.sevensolutions.cc/docs/getting-started

---

```yml
---
services:
    tinyauth:
        image: ghcr.io/steveiliop56/tinyauth:v4
        container_name: tinyauth
        restart: unless-stopped
        environment:
            APP_URL: https://auth.chenn.dev
            USERS: your-username-password-hash
        labels:
            traefik.enable: true
            traefik.http.routers.tinyauth.rule: Host(`auth.chenn.dev`)
            traefik.http.middlewares.tinyauth.forwardauth.address: http://tinyauth:3000/api/auth/traefik
```
