/queue type add kind=fq-codel name=fq-codel

/queue tree add max-limit=30M name=queue-upload packet-mark=no-mark parent=sfp-sfpplus1 queue=fq-codel priority=1

/queue tree add max-limit=1100M name=queue-download packet-mark=no-mark parent=bridge queue=fq-codel priority=1

--- cake

/queue type
add cake-ack-filter=filter cake-diffserv=diffserv4 cake-mpu=84 cake-nat=yes \
 cake-overhead=42 cake-overhead-scheme=ethernet,ether-vlan cake-rtt-scheme=\
 internet kind=cake name=cake-up-simple
add cake-diffserv=diffserv4 cake-mpu=84 cake-nat=yes cake-overhead=42 \
 cake-overhead-scheme=ethernet,ether-vlan cake-rtt-scheme=internet kind=cake \
 name=cake-down-simple
/queue simple
add max-limit=1350M/35M name=cake-simple queue=cake-down-simple/cake-up-simple \
 target=sfp-sfpplus1

---

## default firewall config

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
