# music servers, managers

## servers
- https://airsonic.github.io/
- navidrome
- juuz
- jellyfin
- tocata

---


## clients

- https://www.navidrome.org/apps/

none of the web ui's support mtls to the server
of the desktop apps so far, only navibeat supports mtls (and custom headers)


### web

web (and possibly other platforms)

- https://github.com/jeffvli/feishin
- https://github.com/victoralvesf/aonsoku
- https://github.com/perminder-klair/subwave

less popular

- https://github.com/tamland/airsonic-refix
- https://github.com/JPGuillemin/Airdrome
- https://github.com/Kusefiru/Mist

### android

symfonium
- best by far for android (rock solid)
- supports mtls, basic auth, api keys, custom headers - the works

namida
- holy crap. This this is a damn spaceship compared to these other amateurs
- no mtls

castafiore
- https://github.com/sawyerf/Castafiore
- high jank

### desktop

psysonic
- https://github.com/Psysonic/psysonic
- custom headers
- not sure about "blazingly fast"

navibeat desktop
- https://github.com/nenadjokic/navibeat-linux
- probably the best so far
- mtls, custom headers, api key, the works

jellybox
- https://github.com/avdept/JellyBoxPlayer
- p good on both desktop and android

---

# Nah

ferrosonic (tui)
- https://github.com/jaidaken/ferrosonic

musly (android, desktop)
- https://github.com/dddevid/musly
- appimage has memory leak?
- android app is a buggy mess

solound (android)
- https://solound.com/
- using your own server requires paid version

firmium
- https://github.com/fossisawesome/firmium
- no wayland support

sonicfast
- https://github.com/1800alex/sonicfast
- crunchy

sonawave
- https://music.http5.cn/
- chinese, crunchy

sonora
- https://github.com/sonorahq/sonora
- failed to auth to juuz server

supersonic
- https://github.com/supersonic-app/supersonic
- failed to auth to juuz server

navic
- https://github.com/ssalggnikool/Navic
- failed to auth to juuz server

```yml
# [packages.sonora]
# github = "sonorahq/sonora"
# asset_pattern = "sonora-*-x86_64.AppImage"
# version = "0.44.2"

# [packages.sonicfast]
# github = "1800alex/sonicfast"
# asset_pattern = "sonicfast-*-x86_64.AppImage"
# version = "0.16.0"
```
