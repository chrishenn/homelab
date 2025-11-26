function nat_k3s {
	# Add an "address" and corresponding "network" under /ip addresses
	/ip address
	add address=192.168.30.0/24 network=192.168.30.0 interface=bridge

	# added dstnat rules under /ip firewall nat
	/ip firewall nat
	add chain=dstnat src-address=192.168.30.0/24 dst-address=192.168.1.0/24 action=passthrough
	add chain=dstnat src-address=192.168.1.0/24 dst-address=192.168.30.0/24 action=passthrough
}

function nat_k8s {
	# nat machine network 192.168.1.0/24 to and from pod_cidr 192.168.2.0/24

	/ip address
	add address=192.168.2.1/24 network=192.168.2.0 interface=bridge

	# add dhcp server? use as gateway?

	/ip firewall nat
	add chain=dstnat src-address=192.168.2.0/24 dst-address=192.168.1.0/24 action=passthrough
	add chain=dstnat src-address=192.168.1.0/24 dst-address=192.168.2.0/24 action=passthrough
	add chain=srcnat src-address=192.168.2.0/24 out-interface=sfp-sfpplus1 action=masquerade

	/ip firewall filter
	add chain=forward src-address=192.168.2.0/24 action=accept
}
