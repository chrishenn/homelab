# technitium

## config

todo: use pulumi/terraform technitium provider to configure these manual settings and env vars (only a few settings are
available as env vars. So sad)

- admin/$PASS
- NOTE: environment variables are only read on first boot!!
- tls (with ssl terminated by traefik) did not work until I set `DNS_SERVER_RECURSION: Allow`
- you need to manually set settings -> optional protocols -> Reverse Proxy Network ACL
  - 192.170.0.0/16,172.16.0.0/12
  - aka ${TRAEFIK_SUBNET},172.16.0.0/12  

The plan is to set up multiple technitium servers, clustering them together. The primary node in the cluster gets configuration
pushed to it, and secondaries will get that config (this is configurable). 

Then, the dhcp server (one.mikrotik.henn.dev) will hand out ips for each node in the cluster, and it's up to the client device
to detect and failover (how well does this work? unknown).

I've also installed the lancache technitium app (https://github.com/ruifung/LANCache-TDNSApp) to route DNS for lancache
services. 

With technitium, I've replaced:
- lancache_dns
- blocky
- blocky keepalived

The hope is that client-side dns failover will be as good as the keepalived setup. If this all fails, I'll probably go
straight to K8s for intelligent clustering and service failover. But I'll be sad. 

## upstream records

todo: use pulumi to set these
I've added these records to cloudflare to simplify these services:

| name           | type  | content       |
|----------------|-------|---------------|
| henn.dev       | A     | 192.168.1.4   |
| *.henn.dev     | CNAME | henn.dev      |
| dns.henn.dev   | A     | 192.168.1.142 |
| *.dns.henn.dev | CNAME | dns.henn.dev  |
| cache.henn.dev | A     | 192.168.1.143 |

## cache clear

Remember that DNS is a giant PITA. If you make a change to (eg) a cloudflare dns record, in order to see that change 
locally you may need to:

- clear the dns cache in technitium web ui 
- `sudo resolvectl flush-caches`
- clear the dns cache in your browser
- possibly clear cookies for the affected sites in browser

in rare cases:

- `sudo systemctl restart systemd-resolved`
- manually disconnect and reconnect network in network manager / nmcli

Don't forget that Zen (and probably firefox) has REALLY TERRIBLE DNS CACHING BEHAVIOR. EVEN AFTER MANUALLY CLEARING THE 
DNS CACHE, ZEN CANNOT RESOLVE A HOSTNAME THAT WAS PREVIOUSLY NS_ERROR_UNKNOWN. USE CHROME INSTEAD

## blocking

https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro-onlydomains.txt
https://big.oisd.nl/domainswild2

## clustering

once clustered, these domains will no longer resolve to the machine's ip:
- dns.henn.dev
- dash.rack4.dns.henn.dev

SO MAKE SURE YOU DON'T USE THESE DOMAINS FOR HOMELAB SERVICES AND ALSO THE INTERNAL TECHNITIUM CLUSTERING ZONE STUFF!!

cloudflare responds as expected, but technitium does not recursively query up to cloudflare to resolve these. Also, adding
102.168.1.4 manually in an A record does not work - probably some mechanism of 'dns zones' that disallows these

the node name rack4.dns.henn.dev does resolve to the expected ip

## testing

```bash
dig @dns.henn.dev +https google.com
dig @dns.henn.dev +https-get google.com

# dig automatically appends the /dns-query, but doggo does not

url="1.1.1.1"
url="dns.henn.dev"
doggo @udp://$url google.com
doggo @tcp://$url google.com
doggo @tls://$url google.com
doggo @https://$url/dns-query google.com

# not implemented
doggo @quic://$url google.com

# I don't think this will work unless I terminate SSL on technitium service, and send traffic directly to :443
doggo @https://$url/dns-query --http3 google.com

# this is a cloudflare sdns lookup
doggo @sdns://AgcAAAAAAAAABzEuMC4wLjEAEmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5 google.com

dig +tls +tls-ca +tls-hostname=one.one.one.one @1.1.1.1 google.com
dig +tls +tls-ca @dns.henn.dev google.com
doggo @tls://dns-tls.henn.dev --tls-hostname=dns-tls.henn.dev google.com
doggo @tls://dns-tls.henn.dev --skip-hostname-verification google.com

# visit https://dns.henn.dev/dns-query in the browser to see the technitium DoH help page

# generate self-signed certs - this don't work fer nuthin
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/private.key \
  -out /tmp/certificate.crt \
  -subj '/C=US/ST=State/L=City/O=Organization/CN=localhost'
sudo -E openssl pkcs12 -export -out $DATA/technitium/config/cert.p12 \
  -inkey /tmp/private.key -in /tmp/certificate.crt \
  -passout env:PASS
rm /tmp/private.key /tmp/certificate.crt
```
