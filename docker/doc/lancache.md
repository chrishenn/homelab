# lancache

## Prefill the lancache

- it did auto-detect the lancache server at LANCACHE_IP
- selected apps: [730,4465480,1079800,400,620,2012840]
- you have to do an interactive login to give your steam creds
- you can only download games you own in that steam acct (duh)

```bash
dc run --rm -it lancache_prefill select-apps
dc run --rm -it lancache_prefill prefill
```

## Test the lancache dns setup. Dig/nslookup should find LANCACHE_IP from .env

deprecated?
steam.cache.lancache.net

```bash
sudo resolvectl flush-caches
sudo systemctl restart systemd-resolved

sudo apt install -y bind9-dnsutils

nslookup lancache.steamcontent.com
nslookup worldwide.l3cdn.riotgames.com

dig lancache.steamcontent.com
dig worldwide.l3cdn.riotgames.com


# windows
ipconfig /flushdns
nslookup lancache.steamcontent.com
```

## Technitium lancache plugin

I added cache.henn.dev as $LANCACHE_IP in cloudflare dns (manually) - 192.168.1.143 right now
todo: use the homelab/dns or homelab/protonmail pulumi stack to set this

```json
{
  "lanCacheEnabled": true,
  "appPreference": 50,
  "operatingMode": "Authoritative",
  "enableDebugLogging": false,
  "domainsDataUrl": "https://github.com/uklans/cache-domains/archive/refs/heads/master.zip",
  "domainsDataPathPrefix": "cache-domains-master/",
  "domainsUpdatePeriodHours": 24,
  "ignoreClientAddresses": [],
  "globalCacheAddresses": ["cache.henn.dev"],
  "cacheAddresses": {},
  "enabledCaches": [],
  "disabledCaches": [],
  "recordTtl": 3600
}
```

## replaced with technitium: lancache_dns

```yml
lancache_dns:
  profiles: [lancache]
  image: lancachenet/lancache-dns:latest
  container_name: lancache_dns
  restart: unless-stopped
  environment:
    <<: *lancache_env
  ports:
    - '${LANCACHE_DNS}:53:53/udp'
    - '${LANCACHE_DNS}:53:53/tcp'
```

## replaced with lancache_manager

```yml
# dc run --rm -it --entrypoint /bin/bash --workdir /app lancache_prefill
# dc run --rm -it lancache_prefill select-apps
# dc run --rm -it lancache_prefill prefill
lancache_prefill:
    profiles: [lancache]
    image: tpill90/steam-lancache-prefill:latest
    container_name: lancache_prefill
    restart: no
    network_mode: host
    volumes:
      - $DATA/lancache/prefill:/Config
```