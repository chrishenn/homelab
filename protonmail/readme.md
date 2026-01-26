# Protonmail DNS Config (Cloudflare DNS, Pulumi IAC)

```bash
# edit domains.json as needed
op inject -i domains.json -o secrets.json -f
pulumi up
```
