# pangolin

hosted on hostinger VPS

Note the non-standard smtp SSL port 465.
The standard port is 587, which didn't work for me

```bash
$SSH_CHRIS -t "cd /home/chris/pangolin ; bash --login"

# connect to proton smtp
sudo nano config/config.yml

sudo chris pass:
op read "op://homelab/nlptoaczq3qtw2fqs6nb2d6r5y/chris_pass"

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

backup and update

```bash

```
