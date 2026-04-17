# CS2: With Retakes

install plugins

```bash
docker compose exec -it --user linuxgsm cs2 /bin/bash

# metamod
nano /data/serverfiles/game/csgo/gameinfo.gi
# underneath Game_LowViolence csgo_lv, add:
Game csgo/addons/metamod

url="https://github.com/alliedmodders/metamod-source/releases/download/2.0.0.1396/mmsource-2.0.0-git1396-linux.tar.gz"
curl -Lo file.tar.gz $url
tar -xf file.tar.gz -C /data/serverfiles/game/csgo/
rm file.tar.gz

url="https://github.com/roflmuffin/CounterStrikeSharp/releases/download/v1.0.367/counterstrikesharp-with-runtime-linux-1.0.367.zip"
curl -Lo file.zip $url
unzip file.zip -d /data/serverfiles/game/csgo/
rm file.zip

url="https://github.com/B3none/cs2-retakes/releases/download/3.0.3/RetakesPlugin-3.0.3.zip"
curl -Lo file.zip $url
unzip file.zip -d /data/serverfiles/game/csgo
rm file.zip

url="https://github.com/B3none/cs2-instadefuse/releases/download/2.0.0/cs2-instadefuse-2.0.0.zip"
curl -Lo file.zip $url
unzip file.zip -d /data/serverfiles/game/csgo/addons/counterstrikesharp/plugins
rm file.zip

url="https://github.com/B3none/cs2-instaplant/releases/download/1.0.0/cs2-instaplant-1.0.0.zip"
curl -Lo file.zip $url
unzip file.zip -d /data/serverfiles/game/csgo/addons/counterstrikesharp/plugins
rm file.zip

# weapon allocator
nano /data/serverfiles/game/csgo/addons/counterstrikesharp/configs/plugins/RetakesPlugin/RetakesPlugin.json
"EnableFallbackAllocation": false

nano /data/serverfiles/game/csgo/cfg/cs2-retakes/retakes.cfg
mp_buy_anywhere 1
mp_buytime 60000
mp_maxmoney 65535
mp_startmoney 65535
mp_afterroundmoney 65535

url="https://github.com/yonilerner/cs2-retakes-allocator/releases/download/v2.4.2/cs2-retakes-allocator-v2.4.2.zip"
curl -Lo file.zip $url
unzip file.zip -d /data/serverfiles/game/csgo/addons/counterstrikesharp/plugins
rm file.zip
```

problems

```bash
# this was a security issue in 2025 on deb 13. Not sure if still relevant
sudo apt update && sudo apt install -y patchelf
patchelf --clear-execstack /data/serverfiles/game/csgo/addons/counterstrikesharp/bin/linuxsteamrt64/counterstrikesharp.so

# is this needed for cssharp to load? will need to run on container entrypoint
sudo apt update && sudo apt install -y libicu-dev

# broken? game won't start
#url="https://github.com/B3none/cs2-clutch-announce/releases/download/1.1.0/cs2-clutch-announce-1.1.0.zip"
#curl -Lo file.zip $url
#unzip file.zip -d /data/serverfiles/game/csgo/addons/counterstrikesharp/plugins
#rm file.zip
```

server console: debug plugin loading

```bash
./cs2server console

meta list
# Listing 1 plugin:
#   [01] CounterStrikeSharp (v1.0.367 @ 60a7239) by Roflmuffin

css
# CounterStrikeSharp was created and is maintained by Michael "roflmuffin" Wilson.
# Counter-Strike Sharp uses code borrowed from SourceMod, Source.Python, FiveM, Saul Rennison, source2gen and CS2Fixes.
# See ACKNOWLEDGEMENTS.md for more information.
# Current API Version: v367 (1.0.367+Branch.main.Sha.60a7239eb70a331f8c0ee55645ad47f79635f306.60a7239)

css_plugins list
# List of all plugins currently loaded by CounterStrikeSharp: 1 plugins loaded.
# [#1:LOADED]: "Retakes Plugin" (3.0.3) by B3none
#   https://github.com/b3none/cs2-retakes
```
