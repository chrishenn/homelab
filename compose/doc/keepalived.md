# keepalived

---

#### Troubleshooting

add "ip_vs" to
/etc/modules-load.d/modules.conf

keepalived can't adapt to interface names changing
use the method in ./server.md to get stable nic names

the virtual ip is pingable but will not forward requrests to port 53 dns server
https://serverfault.com/questions/922457/keepalived-virtual-is-not-routing-my-requests-to-real-servers

---

#### Config

```bash
# this was needed for docker to bind to an ip that the system didn't have yet (the vip when not assigned)
sudo nano /etc/sysctl.d/99-keepalived.conf
net.ipv4.ip_nonlocal_bind=1

sudo sysctl -w net.ipv4.ip_nonlocal_bind=1
sudo sysctl -p /etc/sysctl.d/99-keepalived.conf

# debugging
# https://manpages.ubuntu.com/manpages/questing/en/man8/sysctl.8.html
sudo sysctl --system
sudo sysctl --all
sudo systemctl restart keepalived
sudo journalctl -xeu keepalived
ip a

# check that blocky is up and responding on port 53
dig @192.168.1.3 -p 53 healthcheck.blocky +tcp +short && echo "success"
dig @192.168.1.70 -p 53 healthcheck.blocky +tcp +short && echo "success"
dig @192.168.1.142 -p 53 healthcheck.blocky +tcp +short && echo "success"

dig @192.168.1.142 comfy.henn.dev
dig @192.168.1.70 comfy.henn.dev

# not needed
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o p2p1:0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o p2p1 -j MASQUERADE

# not needed
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 1
net.ipv4.conf.all.arp_filter = 0
net.ipv4.conf.eth0.arp_filter = 1

net.ipv4.ip_forward = 1
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 1
net.ipv4.conf.all.arp_filter = 0
net.ipv4.conf.eth0.arp_filter = 1
net.ipv4.ip_nonlocal_bind = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
# net.ipv6.conf.tun0.disable_ipv6 = 1
```

---

#### Refs

- https://medium.com/@yahyasghiouri1998/building-a-high-availability-cluster-with-haproxy-keepalived-and-docker-a-step-by-step-guide-9325f4ac8aa7
- https://github.com/shawly/docker-keepalived
- https://medium.com/@sirkirby/load-balanced-and-highly-available-local-dns-with-dnsdist-and-keepalived-ff4b8fede366
