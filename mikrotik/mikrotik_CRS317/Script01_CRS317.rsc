########################################################################################################################
#### GENERAL CONFIG

/interface bridge
add name=bridge

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

/interface ethernet
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

/interface list
add name=LAN
add name=WAN

/interface list member
add list=WAN interface=sfp-sfpplus1

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


########################################################################################################################
#### IPV6

## ipv6 firewall

/ipv6 firewall filter
add chain=input action=accept   protocol=icmpv6
add chain=input action=accept   connection-state=established,related
add chain=input action=accept   dst-port=546 in-interface=sfp-sfpplus1 protocol=udp src-port=547
add chain=input action=drop     connection-state=invalid
add chain=input action=drop     connection-state=new in-interface=sfp-sfpplus1

add chain=forward action=accept protocol=icmpv6
add chain=forward action=accept connection-state=established,related
add chain=forward action=accept connection-state=new                  in-interface=!sfp-sfpplus1
add chain=forward action=drop   connection-state=invalid
add chain=forward action=drop   in-interface=sfp-sfpplus1


## ipv6 config

/ipv6 dhcp-client
add interface=sfp-sfpplus1 pool-name=comcast_ipv6 prefix-hint=::/60 request=prefix add-default-route=yes use-peer-dns=no use-interface-duid=yes rapid-commit=yes

/ipv6 address
add from-pool=comcast_ipv6 interface=bridge advertise=yes

/ipv6 nd
set [ find default=yes ] interface=all
set [ find default=yes ] advertise-dns=no disabled=yes
add interface=bridge ra-delay=5s ra-interval=5s-30s advertise-mac-address=yes advertise-dns=yes



########################################################################################################################
#### IPV4

#### IPV4 | address (LAN), dhcp-server (for machines on lan), dns (LAN)

/ip address add address=192.168.1.1/24 interface=bridge network=192.168.1.0
/ip pool add name=dhcp_pool0 ranges=192.168.1.2-192.168.1.254

/ip dhcp-server network add address=192.168.1.0/24 dns-server=192.168.1.1 gateway=192.168.1.1
/ip dhcp-server add address-pool=dhcp_pool0 interface=bridge name=dhcp1

#### IPV4 | nat (internet), dhcp-client (internet),

/ip dhcp-client add interface=sfp-sfpplus1

/ip dns set allow-remote-requests=yes
/ip dns set servers=129.250.35.250,129.250.35.251,9.9.9.9,2606:4700:4700::1111,2606:4700:4700::1001


/ip firewall nat add chain=srcnat src-address=192.168.1.0/24 out-interface=sfp-sfpplus1 action=masquerade


#### IPV4 firewall

# configure l3 hw offloading
# https://help.mikrotik.com/docs/display/ROS/L3+Hardware+Offloading
# The next example enables hardware routing on all ports but the upstream port (sfp-sfpplus1).
# Packets going to/from sfp-sfpplus1 will enter the CPU and, therefore, subject to Firewall/NAT processing.

/interface/ethernet/switch set 0 l3-hw-offloading=yes
/interface/ethernet/switch set 0 qos-hw-offloading=yes
/interface/ethernet/switch/port set [find] l3-hw-offloading=yes
/interface/ethernet/switch/port set sfp-sfpplus1 l3-hw-offloading=no

/ip firewall filter
add chain=forward action=fasttrack-connection  connection-state=established,related  comment="forward: fasttrack established,related"  log=no  log-prefix="forward: fasttrack established,related"
add chain=forward action=accept                connection-state=established,related  comment="forward: accept established,related"     log=no  log-prefix="forward: accept established,related"
add chain=forward action=accept                src-address=192.168.1.0/24            comment="forward: accept from LAN"                log=no  log-prefix="forward: accept from LAN"
add chain=forward action=accept                connection-nat-state=dstnat           comment="forward: allow port forwarding"          log=no  log-prefix="forward: allow port forwarding"
add chain=forward action=drop                                                        comment="forward: drop all else"                  log=yes log-prefix="forward: drop drop all else"
add chain=input   action=accept                connection-state=established,related  comment="input: accept established,related"       log=no  log-prefix="input: accept established,related"
add chain=input   action=accept                src-address=192.168.1.0/24            comment="input: accept from LAN"                  log=no  log-prefix="input: accept from LAN"
add chain=input   action=drop                                                        comment="input: drop all else"                    log=yes log-prefix="input: drop all else"

## SSH
/ip firewall filter
add chain=input     action=drop in-interface=sfp-sfpplus1 protocol=tcp dst-port=22 comment="drop SSH default port (22) from WAN to router"
add chain=forward   action=drop in-interface=sfp-sfpplus1 protocol=tcp dst-port=22 comment="drop SSH default port (22) from WAN to LAN clients"

## OPEN GAME PORTS
/ip firewall nat

# valorant
add chain=dstnat action=dst-nat protocol=udp dst-port=7000-8000 to-port=7000-8000
add chain=dstnat action=dst-nat protocol=udp dst-port=8180-8181 to-port=8180-8181

add chain=dstnat action=dst-nat protocol=tcp dst-port=61000-61050 to-port=61000-61050
add chain=dstnat action=dst-nat protocol=tcp dst-port=8393-8400 to-port=8393-8400
add chain=dstnat action=dst-nat protocol=tcp dst-port=2099 to-port=2099
add chain=dstnat action=dst-nat protocol=tcp dst-port=5222 to-port=5222
add chain=dstnat action=dst-nat protocol=tcp dst-port=5223 to-port=5223

# steam, faceit, csgo/cs2
add chain=dstnat action=dst-nat protocol=tcp dst-port=27000-27100 to-port=27000-27100
add chain=dstnat action=dst-nat protocol=udp dst-port=27000-27100 to-port=27000-27100

add chain=dstnat action=dst-nat protocol=udp dst-port=3478 to-port=3478
add chain=dstnat action=dst-nat protocol=udp dst-port=4379 to-port=4379
add chain=dstnat action=dst-nat protocol=udp dst-port=4380 to-port=4380

add chain=dstnat action=dst-nat protocol=udp dst-port=6789 to-port=6789
add chain=dstnat action=dst-nat protocol=tcp dst-port=6789 to-port=6789


########################################################################################################################
#### user

/user add name="$USER" password="$PASS" group=full
/user remove admin
