# lancache

Prefill the lancache

- it did auto-detect the lancache server at LANCACHE_IP
- selected apps: [730,4465480,1079800,400,620,2012840]
- you have to do an interactive login to give your steam creds
- you can only download games you own in that steam acct (duh)

```bash
dc run --rm -it lancache_prefill select-apps
dc run --rm -it lancache_prefill prefill
```

Test the lancache dns setup. Dig/nslookup should find LANCACHE_IP from .env

```bash
sudo resolvectl flush-caches
sudo systemctl restart systemd-resolved

dig steam.cache.lancache.net
dig lancache.steamcontent.com

sudo apt install -y bind9-dnsutils
nslookup steam.cache.lancache.net
nslookup lancache.steamcontent.com

# windows
ipconfig /flushdns
nslookup steam.cache.lancache.net
nslookup lancache.steamcontent.com
```
