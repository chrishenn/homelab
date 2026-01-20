# mikrotik configuration notes

Bugfix: update packages using the GUI, and DNS times out

- ip -> DNS -> use doh server -> delete the doh server
- ip -> DNS -> servers -> add 1.1.1.1
- upgrade packages
- restore doh server (https://one.one.one.one/dns-query)

---

make sure you have winbox! Otherwise you'll have to download it over mobile data hotspot
manually set your machine ip to be valid on the default subnet (192.168.88.0/24) reset with no default script applied

```rsc
/system reset-configuration no-defaults=yes
```

connect using winbox

```bash
/ip firewall address-list { for input chain rule access to router }
add address=192.168.1.X list=ADMIN comment=admin-desktop
add address=192.168.1.Y list=ADMIN comment=admin-laptop
add address=192.168.1.XY list=ADMIN comment=admin-ipad/iphone

/ip firewall address-list
add list=unexpected-src-address-hitting-ISP address=10.0.0.0/8
add list=unexpected-src-address-hitting-ISP address=127.0.0.0/8
add list=unexpected-src-address-hitting-ISP address=169.254.0.0/16
add list=unexpected-src-address-hitting-ISP address=172.16.0.0/12
add list=unexpected-src-address-hitting-ISP address=192.0.0.0/24
add list=unexpected-src-address-hitting-ISP address=192.0.2.0/24
add list=unexpected-src-address-hitting-ISP address=192.88.99.0/24
add list=unexpected-src-address-hitting-ISP address=192.168.0.0/16
add list=unexpected-src-address-hitting-ISP address=198.18.0.0/15
add list=unexpected-src-address-hitting-ISP address=198.51.100.0/24
add list=unexpected-src-address-hitting-ISP address=203.0.113.0/24
add list=unexpected-src-address-hitting-ISP address=233.252.0.0/24
add list=unexpected-src-address-hitting-ISP address=240.0.0.0/5
add list=unexpected-src-address-hitting-ISP address=248.0.0.0/6
add list=unexpected-src-address-hitting-ISP address=252.0.0.0/7
add list=unexpected-src-address-hitting-ISP address=254.0.0.0/8

/ip firewall address-list { valid internal LAN traffic }
add ip-address=localSubnet1     list=expected-address-from-LAN
add ip-address=localSubnet2     list=expected-address-from-LAN
add ip-address=remoteSubnet1    list=expected-address-from-LAN { remote Wireguard subnet1 exits tunnel locally }
add ip-address=remoteSubnet2    list=expected-address-from-LAN { remote Wireguard subnet2  exits tunnel locally }

add list=expected-address-from-LAN address=0.0.0.0 comment="Current network"
add list=expected-address-from-LAN address=224.0.0.0/4 comment="Multicast"
add list=expected-address-from-LAN address=255.255.255.255 comment="Local"

/ip firewall address-list   { valid WAN IPs }
add list=expected-dst-address-to-my-ISP address=my.public.wan.ip
add list=expected-dst-address-to-my-ISP address=pool.of.my.internal.public.ips

/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related" connection-state=established,related,untracked
add action=drop chain=input connection-state=invalid
add action=accept chain=input protocol=ICMP { essential for networking ignore the bad advice everywhere!! }
add action=accept chain=input comment="admin access" in-interface-list=LAN src-address-list=ADMIN
add action=accept chain=input comment="DNS allow TCP from br-local" dst-port=53 in-interface=br-local protocol=tcp
add action=drop chain=input comment="Drop all else"

add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=forward comment="internet access" in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="port forwarding" connection-nat-state=dstnat { disable if not using port forwarding }
add action=drop chain=forward comment="drop all else"

/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN    { if a dynamic WANIP }
add action=src-nat chain=srcnat dst-address=static-WANIP  out-interface=etherX-WAN   { if a static/fixed WANIP }

/ip firewall raw
add action=drop chain=prerouting  in-interface-list=WAN src-address-list=unexpected-src-address-hitting-ISP \
     comment="drop non-legit src-addresses hitting WAN side"  \
add action=drop chain=prerouting in-interface-list=WAN dst-address-list=!expected-dst-address-to-my-ISP \
     comment="drop  non-legit dst-addresses hitting WAN side"
add action=drop chain=prerouting in-interface-list=LAN src-address-list=!expected-address-from-LAN  \
     comment="drop non-legit traffic coming from LAN"

# NOTE: For Dynamic WANIP There are  two possible solutions.
# A.  Add the following rule:
# add chain=output action=add-src-to-address-list src-address-type=local out-interface-list=WAN address-list=expected-dst-address-to-my-ISP address-list-timeout=1m
# B. [u](Preferred[/u]) Add the following rules:  ( replace DNS with those of your choice )
# /ip firewall address-list
# add address=1.1.1.1 list=allowed_DNS
# add address=8.8.8.8 list=allowed_DNS

/ip firewall raw
add action=accept chain=prerouting src-address-list=allowed_DNS
add action=accept chain=output dst-address-list=allowed_DNS

# [b]Note1[/b]: First RAW rule blocks all incoming WAN traffic with invalid source addresses (before it hits connection tracking aka raw filtering)
# [b]Note2[/b]: Second RAW rule blocks all incoming WAN traffic with invalid destination addresses.
# [b]Note3[/b]: Third RAW rule block all LAN side originated traffic that is not Local  { LAN users/devices or remote subnets entering the router through VPN  }.
# [b]Note4[/b]:  If you have two different ISP providers you may wish to allow  access from one to the other on the WAN side, if this is the case you will need to create additional rules for each WAN to be a valid source address for the other WAN.  Ensure you put these additional RAW rules before rule 1.
#
# The last edition to the Apprentice Firewall setup is the use of unreachable.  These drop any outgoing traffic to addresses that local users should not have as a destination address.
# While in the third RAW rule above, we stop any traffic from the LAN, other than LOCAL heading outbound,  the Unreachable rules will stop any local traffic or otherwise heading outbound to the addresses below.

/ip routing rule
add action=unreachable dst-address=10.0.0.0/8    { common on LANs  disable if local to you }
add action=unreachable dst-address=169.254.0.0/16
add action=unreachable dst-address=172.16.0.0/12     { common on LANs  disable if local to you }
add action=unreachable dst-address=192.0.0.0/24
add action=unreachable dst-address=192.0.2.0/24
add action=unreachable dst-address=192.88.99.0/24
add action=unreachable dst-address=192.168.0.0/16   { common on LANs  disable if local to you }
add action=unreachable dst-address=198.18.0.0/15
add action=unreachable dst-address=198.51.100.0/24
add action=unreachable dst-address=203.0.113.0/24
add action=unreachable dst-address=233.252.0.0/24
add action=unreachable dst-address=240.0.0.0/5
add action=unreachable dst-address=248.0.0.0/6
add action=unreachable dst-address=252.0.0.0/7
add action=unreachable dst-address=254.0.0.0/8

# { Unreachable Exception:   If you have unused public IPs,  use "[i][u]unreachable[/u][/i]"  to prevent their inadvertent use! }

add action=unreachable dst-address=my.unused.public.ip1
add action=unreachable dst-address=my.unused.public.ip2

# Note1:  All of these rules should be placed before any other routing rules.
# Note2:  [color=#FF8000][b]CAUTION, [/b][/color]do not include any subnets you actually have on the LAN.
```

---

## default firewall config

```bash
/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN"in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy"ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy"ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack"connection-state=established,related disabled=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid"connection-state=invalid
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnatconnection-state=new in-interface-list=WAN
```
