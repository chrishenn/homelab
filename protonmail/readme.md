# Protonmail DNS Config (Cloudflare DNS, Pulumi IAC)

Add DNS records to cloudflare dns in order to add those domains to my protonmail account.

supporting:

- protonmail's DNS verification (txt records)
- MX, SPF, SKIM, DMARC

active domains:

- henn.dev
- chenn.dev

using:

- pulumi state for project "protonmail" (default; pulumi cloud)
- pulumi cloudflare provider
    - implicitly reads CLOUDFLARE_API_TOKEN from env, provided by fnox's 1pass provider

Note: Cloudflare requires txt records to have explicitly-quoted content

---

## Todo:

I render domains.json with secrets from 1pass, then consume the resulting json directly from protonmail.py, declaring
pulumi resources. It would be more idiomatic to embed domains.json into the pulumi stack configuration - I think pulumi
even has a secrets provider for 1pass.

Rendering a json file full of secrets directly to disk is also not ideal from a security prospective, nor is it scalable
to a team

We could also obviate fnox embedding CLOUDFLARE_API_TOKEN into the runtime env, by using the 1pass provider in pulumi.

---

## Dev

```bash
# edit domains.json as needed
op inject -i domains.json -o secrets.json -f
pulumi up
```
