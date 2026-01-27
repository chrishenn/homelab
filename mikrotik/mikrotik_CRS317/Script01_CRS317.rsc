# interfaces

/interface bridge
add name=bridge

/interface vlan
add name=vlan10 vlan-id=10 interface=bridge

/interface bridge port
add interface=ether1 bridge=bridge
add interface=sfp-sfpplus2 bridge=bridge
add interface=sfp-sfpplus3 bridge=bridge
add interface=sfp-sfpplus4 bridge=bridge
add interface=sfp-sfpplus5 bridge=bridge
add interface=sfp-sfpplus6 bridge=bridge
add interface=sfp-sfpplus7 bridge=bridge
add interface=sfp-sfpplus8 bridge=bridge
add interface=sfp-sfpplus9 bridge=bridge
add interface=sfp-sfpplus10 bridge=bridge
add interface=sfp-sfpplus11 bridge=bridge
add interface=sfp-sfpplus12 bridge=bridge
add interface=sfp-sfpplus13 bridge=bridge
add interface=sfp-sfpplus14 bridge=bridge
add interface=sfp-sfpplus15 bridge=bridge
add interface=sfp-sfpplus16 bridge=bridge

/interface ethernet
set tx-flow-control=on sfp-sfpplus1
set tx-flow-control=on sfp-sfpplus2
set tx-flow-control=on sfp-sfpplus3
set tx-flow-control=on sfp-sfpplus4
set tx-flow-control=on sfp-sfpplus5
set tx-flow-control=on sfp-sfpplus6
set tx-flow-control=on sfp-sfpplus7
set tx-flow-control=on sfp-sfpplus8
set tx-flow-control=on sfp-sfpplus9
set tx-flow-control=on sfp-sfpplus10
set tx-flow-control=on sfp-sfpplus11
set tx-flow-control=on sfp-sfpplus12
set tx-flow-control=on sfp-sfpplus13
set tx-flow-control=on sfp-sfpplus14
set tx-flow-control=on sfp-sfpplus15
set tx-flow-control=on sfp-sfpplus16

set rx-flow-control=on sfp-sfpplus1
set rx-flow-control=on sfp-sfpplus2
set rx-flow-control=on sfp-sfpplus3
set rx-flow-control=on sfp-sfpplus4
set rx-flow-control=on sfp-sfpplus5
set rx-flow-control=on sfp-sfpplus6
set rx-flow-control=on sfp-sfpplus7
set rx-flow-control=on sfp-sfpplus8
set rx-flow-control=on sfp-sfpplus9
set rx-flow-control=on sfp-sfpplus10
set rx-flow-control=on sfp-sfpplus11
set rx-flow-control=on sfp-sfpplus12
set rx-flow-control=on sfp-sfpplus13
set rx-flow-control=on sfp-sfpplus14
set rx-flow-control=on sfp-sfpplus15
set rx-flow-control=on sfp-sfpplus16

# interface lists

/interface list
add name=WAN
add name=VLAN
add name=LAN

/interface list member
add list=WAN interface=sfp-sfpplus1

add list=VLAN interface=vlan10

add list=LAN interface=sfp-sfpplus2
add list=LAN interface=sfp-sfpplus3
add list=LAN interface=sfp-sfpplus4
add list=LAN interface=sfp-sfpplus5
add list=LAN interface=sfp-sfpplus6
add list=LAN interface=sfp-sfpplus7
add list=LAN interface=sfp-sfpplus8
add list=LAN interface=sfp-sfpplus9
add list=LAN interface=sfp-sfpplus10
add list=LAN interface=sfp-sfpplus11
add list=LAN interface=sfp-sfpplus12
add list=LAN interface=sfp-sfpplus13
add list=LAN interface=sfp-sfpplus14
add list=LAN interface=sfp-sfpplus15
add list=LAN interface=sfp-sfpplus16

# ipv4

/ip address
add address=192.168.1.1/24 network=192.168.1.0 interface=bridge
/ip pool
add name=pool1 ranges=192.168.1.2-192.168.1.254
/ip dhcp-server
network add address=192.168.1.0/24 gateway=192.168.1.1 dns-server=192.168.1.3,192.168.1.143,192.168.1.1
add name=dhcp0 address-pool=pool1 interface=bridge

/ip address
add address=192.168.10.1/24 network=192.168.10.0 interface=vlan10
/ip pool
add name=pool10 ranges=192.168.10.2-192.168.10.254
/ip dhcp-server
network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=1.1.1.1,1.0.0.1
add name=dhcp10 address-pool=pool10 interface=vlan10

# dhcp client (internet)
/ip dhcp-client add interface=sfp-sfpplus1

# nat (internet)
/ip firewall nat add chain=srcnat src-address=192.168.1.0/24  out-interface=sfp-sfpplus1 action=masquerade
/ip firewall nat add chain=srcnat src-address=192.168.10.0/24 out-interface=sfp-sfpplus1 action=masquerade

# dns
/ip dns
set allow-remote-requests=yes
# todo: turn off dynamic dns servers (from isp)
# todo: "use DOH server: https://one.one.one.one/dns-query"
# todo: forwarders {https://one.one.one.one/dns-query, https://dns.google/dns-query, https://dns.nextdns.io/74c891}

# L3HW config, necessary for firewall
/interface/ethernet/switch
set 0 l3-hw-offloading=yes
set 0 qos-hw-offloading=yes

/interface/ethernet/switch/port
set [find] l3-hw-offloading=yes
set sfp-sfpplus1 l3-hw-offloading=no

# firewall
/ip firewall filter
add chain=forward action=fasttrack-connection connection-state=established,related          comment="fw: ft est,rel"      log=no
add chain=forward action=accept               connection-state=established,related          comment="fw: acc est,rel"     log=no
add chain=forward action=accept               in-interface-list=LAN  out-interface-list=WAN comment="fw: acc LAN to WAN"  log=no
add chain=forward action=accept               in-interface-list=VLAN out-interface-list=WAN comment="fw: acc VLAN to WAN" log=no
add chain=forward action=drop                                                               comment="fw: drop all"        log=no

add chain=input   action=accept               connection-state=established,related  comment="inp: acc est,rel"          log=no
add chain=input   action=accept               src-address=192.168.1.0/24            comment="inp: acc LAN PRIV"         log=no
add chain=input   action=drop                                                       comment="inp: drop all"             log=no

# user
/user add name="$USER" password="$PASS" group=full
/user remove admin
