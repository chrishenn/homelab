# bonfire

sadly, still just a tech demo / experiment
why is it making so many damn db connections? there's too many already!
I can't convince the app that its being served from https, because it's behind a reverse proxy
so oidc is impossible to configure - the redirect url is wrong - becuase of their rigid justfile setup, or how they
derived the public url, or the documentation is just not good enough

```bash
git clone https://github.com/bonfire-networks/bonfire-app.git
git checkout v1.0.4

MIX_ENV=prod FLAVOUR=social WITH_DOCKER=total just config

# this just pulls the containers?
MIX_ENV=prod FLAVOUR=social WITH_DOCKER=total just setup-prod
```
