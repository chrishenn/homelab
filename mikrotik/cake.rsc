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

