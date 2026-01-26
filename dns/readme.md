# Internal Homelab DNS (Pulumi Cloudflare)

Pulumi cloudflare IAC to configure cloudflare dns to a local ip for letsencrypt SSL on local services.
Traefik at a local IP uses LetsEncrypt's DNS challenge to sign domains under henn.dev.
Requires an A record and a wildcard CNAME record.
