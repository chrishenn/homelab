# technitium

reverse proxy network acl: 192.170.0.0/16 (this is the traefik subnet, where traefik lives)

- admin/$PASS
- environment variables are only read on first boot
- tls (with ssl terminated by traefik) did not work until I set `DNS_SERVER_RECURSION: Allow`
- serving dns-over-http means resolving dns.henn.dev -> rack4's TRAEFIK_VIP (192.168.1.4)

```bash
dig @dns.henn.dev +https google.com
dig @dns.henn.dev +https-get google.com

# dig automatically appends the /dns-query, but doggo does not

url="1.1.1.1"
url="dns.henn.dev"
doggo @udp://$url google.com
doggo @tcp://$url google.com
doggo @https://$url/dns-query google.com
doggo @tls://$url google.com
doggo @quic://$url google.com

# I don't think this will work unless I terminate SSL on technitium service, and send traffic directly to :443
doggo @https://$url/dns-query --http3 google.com

# this is a cloudflare sdns lookup
doggo @sdns://AgcAAAAAAAAABzEuMC4wLjEAEmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5 google.com

dig +tls +tls-ca +tls-hostname=one.one.one.one @1.1.1.1 google.com
dig +tls +tls-ca @dns-tls.henn.dev google.com
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
