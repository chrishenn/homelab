# PocketID

The problem below was fixed by: https://github.com/fosrl/pangolin/pull/2843

    when logging into pangolin with pocketid, and pocketid is exposed through pangolin, there is a
    part of the oidc login that pangolin sees as coming from 172.18.0.1 instead of pocketid.chenn.dev

    Verify session: Badger sent {"sessions":{},"originalRequestURL":"https://pocketid.chenn.dev/api/oidc/token"
    "requestIp":"172.18.0.1", "X-Real-Ip":"172.18.0.1"
    Client IP: {"clientIp":"172.18.0.1"}
    Resource denied by rule

    and 172.18.0.1 will be considered by geographical matching to be "not in the US" and blocked
    This is a doozy to debug, because this ip only shows in this way when you're logging into pangolin specifically

    - pocketid will not hit this edge cause when performing OIDC for other apps exposed by pangolin
    here's what the rest of the oidc exchange would look like

    Verify session: Badger sent {"sessions":{},"originalRequestURL":"https://pocketid.chenn.dev/api/oidc/authorize"
    "requestIp":"my-home-internet-ip", "X-Real-Ip":"my-home-internet-ip"
    Client IP: {"clientIp":"my-home-internet-ip"}
    Resource allowed by rule

    also note that my base docker ip pool is larger than standard (I ran out)
    "default-address-pools": [{"base": "172.16.0.0/12","size": 24}]

I added pocketid as the preferred login method for pangolin, so now there would be a bootstrap problem if I
required pangolin sso in order to access pocketid, in order to log into pangolin...etc.

```yml
pangolin.public-resources.pocketid.auth.sso-enabled: true
pangolin.public-resources.pocketid.auth.sso-roles[0]: Member

pangolin.public-resources.pocketid.rules[0].action: allow
pangolin.public-resources.pocketid.rules[0].match: path
pangolin.public-resources.pocketid.rules[0].value: /api/*

pangolin.public-resources.pocketid.rules[1].action: allow
pangolin.public-resources.pocketid.rules[1].match: path
pangolin.public-resources.pocketid.rules[1].value: /.well-known/*

pangolin.public-resources.pocketid.rules[2].action: allow
pangolin.public-resources.pocketid.rules[2].match: path
pangolin.public-resources.pocketid.rules[2].value: /authorize/*

pangolin.public-resources.pocketid.rules[3].action: pass
pangolin.public-resources.pocketid.rules[3].match: path
pangolin.public-resources.pocketid.rules[3].value: '*'
```
