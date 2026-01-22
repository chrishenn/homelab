#!/bin/bash

# https://github.com/Posiplusive/pdanet-linux
# Run as root

if_default=$(ip route | grep default | awk '{print $5}')
rt_default=$(ip route show | grep "^default" | head -n 1)

cleanup() {
    echo "CTRL + C detected. Running cleanup..."

    killall tun2socks 2>/dev/null
    ip route del default via 192.168.1.1 dev tun0 metric 1 2>/dev/null
    ip route del default via 192.168.49.1 dev $if_default metric 10 2>/dev/null

    # 3. Restore your original default route dynamically
    ip route add $rt_default

    # 4. Disable (and remove) the tunnel interface
    ip link set dev tun0 down 2>/dev/null
    ip tuntap del mode tun dev tun0 2>/dev/null

    # 5. Revert rp_filter to its default (usually 1)
    sysctl -w net.ipv4.conf.all.rp_filter=1
}

# Trap SIGINT and call the cleanup function
trap cleanup SIGINT

# Tunnel interface setup
ip tuntap add mode tun dev tun0
ip addr add 192.168.1.1/24 dev tun0
ip link set dev tun0 up
ip route del default
ip route add default via 192.168.1.1 dev tun0 metric 1
ip route add default via 192.168.49.1 dev $if_default metric 10

# Disable rp_filter to receive packets from other interfaces
sysctl -w net.ipv4.conf.all.rp_filter=0

# Run tun2socks
tun2socks -device tun://tun0 -interface $if_default -proxy socks5://192.168.49.1:8000