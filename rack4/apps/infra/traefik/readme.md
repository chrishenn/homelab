# traefik

generate cloudflare trusted ips

```bash
curl https://api.cloudflare.com/client/v4/ips | sed 's/\\//g' | yq '.result.ipv4_cidrs + .result.ipv6_cidrs'
```
