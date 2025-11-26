maybe we can use kube-vip with calico instead of metallb?

```yml
# image tag for kube-vip
kube_vip_tag_version: v0.8.2

# tag for kube-vip-cloud-provider manifest
kube_vip_cloud_provider_tag_version: "main"

# kube-vip ip range for load balancer
# (uncomment to use kube-vip for services instead of MetalLB)
kube_vip_lb_ip_range: "192.168.30.80-192.168.30.90"

# enable kube-vip ARP broadcasts
kube_vip_arp: true

# enable kube-vip BGP peering
kube_vip_bgp: false

# bgp parameters for kube-vip
kube_vip_bgp_routerid: "127.0.0.1" # Defines the router ID for the BGP server
kube_vip_bgp_as: "64513" # Defines the AS for the BGP server
kube_vip_bgp_peeraddress: "192.168.30.1" # Defines the address for the BGP peer
kube_vip_bgp_peeras: "64512" # Defines the AS for the BGP peer
```
