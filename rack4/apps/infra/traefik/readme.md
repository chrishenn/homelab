# traefik

generate cloudflare trusted ips

```bash
curl https://api.cloudflare.com/client/v4/ips | sed 's/\\//g' | yq '.result.ipv4_cidrs + .result.ipv6_cidrs'
```

---

## traefik with sub-subdomains

https://community.traefik.io/t/sub-level-subdomains-not-working/23494/3

I would split it:

    domains:
      - main: "{{ domain_name }}"
        sans:
          - "*.{{ domain_name }}"
      - main: "shop.{{ domain_name }}"
        sans:
          - "*.shop.{{ domain_name }}"

And make sure `shop.` is explicitly registered as sub-domain with your DNS provider.

---

## traefik oidc plugin

```yml
traefik.http.middlewares.oidc.plugin.oidc.Provider.ClientId: ${OIDC_CLIENT}
traefik.http.middlewares.oidc.plugin.oidc.Provider.ClientSecret: ${OIDC_SECRET}
traefik.http.middlewares.oidc.plugin.oidc.Provider.Url: https://pocketid.henn.dev
traefik.http.middlewares.oidc.plugin.oidc.Provider.UsePkce: true
traefik.http.middlewares.oidc.plugin.oidc.Scopes[0]: openid
traefik.http.middlewares.oidc.plugin.oidc.Scopes[1]: profile
traefik.http.middlewares.oidc.plugin.oidc.Scopes[2]: email
```
