problem: steam appid changed because csgo was released as its own steam listing instead of a cs2 beta branch
new appid: 4465480

create a new steam account
log in as that account
add csgo to library (need the direct link)
https://store.steampowered.com/app/4465480/CounterStrike_Global_Offensive/?curator_clanid=4777282

I did the update from steamcmd, though it may be sufficient to login with steamcmd and then do the update
with `./csgoserver u`

```bash
docker compose exec -it --user linuxgsm csgo /bin/bash
steamcmd
force_install_dir /data/serverfiles/
login chrischikn_server <steam account password>
app_update 4465480 validate

app_status 4465480
# install dir should be /data/serverfiles/
```

## fixes

generate a new server login token for the new appid
https://steamcommunity.com/dev/managegameservers

token goes in:
config-lgms/csgoserver/csgoserver.cfg

add new appid to these files:
serverfiles/steam_appid.txt
serverfiles/bin/steam_appid.txt
serverfiles/csgo/steam.inf
config-lgsm/csgoserver/csgoserver.cfg
under appid="4465480"

install minimum patches to fix these issues:

- hangs forever requesting lobby id from server
- S3: Client connected with ticket for the wrong game. STEAM validation rejected

```bash
# inside container
./csgoserver mi metamodsource
./csgoserver mi sourcemod

# from local machine homelab/rack4
serverfiles="$DATA/csgo/serverfiles"
patches='apps/games/csgo/addons'
cp -rf $patches "$serverfiles/csgo"
```

## custom retakes

```bash
# retakes plugin
url="https://github.com/splewis/csgo-retakes/releases/download/v0.3.4/retakes_0.3.4.zip"
curl -Lo file.zip $url
unzip file.zip -d /data/serverfiles/csgo
rm file.zip

# autoplant https://github.com/B3none/csgo-retakes-autoplant
cp -rf apps/games/csgo/autoplant/addons $DATA/csgo/serverfiles/csgo

# instadefuse https://github.com/B3none/csgo-retakes-instadefuse
cp -rf apps/games/csgo/instadefuse/addons $DATA/csgo/serverfiles/csgo

# after launch, this config file should appear
nano /data/serverfiles/csgo/cfg/sourcemod/retakes/retakes.cfg
```

---

# todo

- add server password
- add steam workshop api key
- host in public

questions:

- is sv_lan 0 needed?
- is setting ip manually needed?
- why do I need to manually create cfg files when server logs `couldn't exec gamemode_casual_server.cfg` ?

---

plugin status

```bash
./csgoserver c

meta list

Listing 4 plugins:
  [01] SourceMod (1.13.0.7330) by AlliedModders LLC
  [02] CS Tools (1.13.0.7330) by AlliedModders LLC
  [03] SDK Tools (1.13.0.7330) by AlliedModders LLC
  [04] SDK Hooks (1.13.0.7330) by AlliedModders LLC

sm plugins list

[SM] Listing 19 plugins:
  01 "Basic Comm Control" (1.13.0.7330) by AlliedModders LLC
  02 "Fun Votes" (1.13.0.7330) by AlliedModders LLC
  03 "Client Preferences" (1.13.0.7330) by AlliedModders LLC
  04 "CS:GO Retakes" (0.3.4) by splewis
  05 "No Lobby Reservation" (0.0.2) by vanz
  06 "Reserved Slots" (1.13.0.7330) by AlliedModders LLC
  07 "Fun Commands" (1.13.0.7330) by AlliedModders LLC
  08 "Basic Votes" (1.13.0.7330) by AlliedModders LLC
  09 "Admin File Reader" (1.13.0.7330) by AlliedModders LLC
  10 "Nextmap" (1.13.0.7330) by AlliedModders LLC
  11 "Anti-Flood" (1.13.0.7330) by AlliedModders LLC
  12 "Player Commands" (1.13.0.7330) by AlliedModders LLC
  13 "Basic Chat" (1.13.0.7330) by AlliedModders LLC
  14 "Admin Help" (1.13.0.7330) by AlliedModders LLC
  15 "Sound Commands" (1.13.0.7330) by AlliedModders LLC
  16 "Admin Menu" (1.13.0.7330) by AlliedModders LLC
  17 "Basic Commands" (1.13.0.7330) by AlliedModders LLC
  18 "Basic Ban Commands" (1.13.0.7330) by AlliedModders LLC
  19 "Basic Info Triggers" (1.13.0.7330) by AlliedModders LLC
```
