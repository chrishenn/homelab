# mikrotik doh: use DNS over HTTPS

this is to configure the DNS server that's built into mikrotik, and can serve on the bridge IP (192.168.1.1)

```bash
# shell into the router
ssh 192.168.1.1 -p 2200

# you need a working dns upstream set for the router to fetch this file (under IP -> DNS -> servers -> 1.1.1.1)
/tool fetch url=https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem
/certificate import file-name=DigiCertGlobalRootG2.crt.pem passphrase=""

/ip dns set use-doh-server=https://one.one.one.one/dns-query verify-doh-cert=yes

# now you should be able to use the router IP as a DNS resolver
dig @192.168.1.1 msn.com

# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36545
# ;; ANSWER SECTION:
# msn.com.                1461    IN      A       204.79.197.219

# to disable "dynamic servers" from comcast, turn off "use peer dns"
# IP -> DHCP Client -> edit the client on the WAN port sfpplus-1 -> under section DHCP, untoggle "use peer DNS"
# I also toggled off "use peer NTP" but I'm not sure that matters 
```
