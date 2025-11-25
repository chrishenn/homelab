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
