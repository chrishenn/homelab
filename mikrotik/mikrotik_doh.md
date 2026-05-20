# mikrotik doh: use DNS over HTTPS

this is to configure the DNS server that's built into mikrotik, and can serve on the bridge IP (192.168.1.1)

```bash
# shell into the router
ssh 192.168.1.1 -p 2200

# you need a working dns upstream set for the router to fetch this file (under IP -> DNS -> servers -> 1.1.1.1)
/tool fetch url="https://ssl.com/repo/certs/SSLcomRootCertificationAuthorityECC.pem"
/certificate import file-name="SSLcomRootCertificationAuthorityECC.pem"

# once you've fetched the cert to the server, this command will remove 1.1.1.1 from the servers list
/ip dns set servers="" use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes allow-remote-requests=yes

# you can see the imported cert under system->certificates

# now you should be able to use the router IP as a DNS resolver
dig @192.168.1.1 google.com

# to disable "dynamic servers" from comcast, turn off "use peer dns"
# IP -> DHCP Client -> edit the client on the WAN port sfpplus-1 -> under section DHCP, untoggle "use peer DNS"
# I also toggled off "use peer NTP" but I'm not sure that matters
```
