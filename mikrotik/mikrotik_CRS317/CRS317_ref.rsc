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


## ipv6 config

/ipv6 dhcp-client
add interface=sfp-sfpplus1 pool-name=comcast_ipv6 prefix-hint=::/60 request=prefix add-default-route=yes use-peer-dns=no use-interface-duid=yes rapid-commit=yes

/ipv6 address
add from-pool=comcast_ipv6 interface=bridge advertise=yes

/ipv6 nd
set [ find default=yes ] interface=all
set [ find default=yes ] advertise-dns=no disabled=yes
add interface=bridge ra-delay=5s ra-interval=5s-30s advertise-mac-address=yes advertise-dns=yes

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
