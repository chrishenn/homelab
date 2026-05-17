# blocky

test that blocky dns is up and working. Also test DOH

```bash
# cloudflare
https://1.1.1.1/help

# dig while using the remote_srv_ip as the dns server
# dig @<remote_srv_ip> google.com
dig @192.168.1.142 google.com

# blocky format:
https://1.1.1.1/dns-query

# dig format:
dig @1.1.1.1 +https google.com
dig @192.168.1.142 +https google.com

# server ip
srv=192.168.1.142
# server vip
srv=192.168.1.3

# test UDP port 53
dig @$srv google.com
# test TCP port 53
dig @$srv +tcp google.com
# test DoT port 853
dig @$srv +tls google.com
# test DoH port 443 (this would need its own traefik instance to provide certs and routing)
dig @$srv +https google.com
# dnssec test A
dig @$srv sigok.verteiltesysteme.net
# dnssec test servfail
dig @$srv sigfail.verteiltesysteme.net
```

refer to blocklists online. bounce the service to pull fresh

```yml
# steven black's blocklists
- https://github.com/StevenBlack/hosts
- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

# peter lowe's blocklist, used by ublock origin
# note that the stevenblack list includes the peter lowe list as an upstream
- https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts

# hagezi
- https://github.com/hagezi/dns-blocklists
- https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt

# others
- https://adaway.org/hosts.txt
- https://v.firebog.net/hosts/AdguardDNS.txt
```

download blocklists. you'll need to redownload manually

```bash
lists="/mnt/k/docker/blocky/blacklists"
curl -L https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -o "$lists/hosts"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.plus.txt -o "$lists/pro.plus.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/fake.txt -o "$lists/fake.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/popupads.txt -o "$lists/popupads.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/tif.txt -o "$lists/tif.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/native.samsung.txt -o "$lists/native.samsung.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/native.winoffice.txt -o "$lists/native.winoffice.txt"
```

config

```yml
upstreams:
    init:
        # startup behavior: {blocking, failOnError, fast}
        strategy: fast
    groups:
        default:
            - https://1.1.1.1/dns-query
    #      - tcp-tls:one.one.one.one:853
    #      - https://dns.nextdns.io/74c891
    #      - tcp-tls:74c891.dns.nextdns.io:853

customDNS:
    customTTL: 1h
    filterUnmappedTypes: false
    # this is not working - I assume because our primary upstream is now https, this mapping does not happen
    # to use the lancache, manually set an individual machine to use $LANCACHE_IP as the sole dns server
    # according to https://github.com/uklans/cache-domains, {lancache.steamcontent.com} is the only domain we need to rewrite
    #  mapping:
    #    lancache.steamcontent.com: 192.168.1.143
```

https doh (downstreams)

- https://github.com/0xERR0R/blocky/discussions/576

    Regarding HTTPS: Yes, if you use traefik, it is the preferred way to use traefik as reverse proxy and do HTTPS. Blocky
    should only serve traffic on HTTP port, no need to configure https port or any certificate.

```yml
spec:
    entryPoints:
        - dot
    routes:
        - match: HostSNI(`*`)
          services:
              - name: blocky
                port: 53
                terminationDelay: 400
                weight: 10
    tls:
        passthrough: false
```
