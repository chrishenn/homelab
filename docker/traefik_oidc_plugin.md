```yml
traefik.http.middlewares.oidc.plugin.oidc.Provider.ClientId: ${OIDC_CLIENT}
traefik.http.middlewares.oidc.plugin.oidc.Provider.ClientSecret: ${OIDC_SECRET}
traefik.http.middlewares.oidc.plugin.oidc.Provider.Url: https://pocketid.henn.dev
traefik.http.middlewares.oidc.plugin.oidc.Provider.UsePkce: true
traefik.http.middlewares.oidc.plugin.oidc.Scopes[0]: openid
traefik.http.middlewares.oidc.plugin.oidc.Scopes[1]: profile
traefik.http.middlewares.oidc.plugin.oidc.Scopes[2]: email
```
