/interface ethernet switch qos profile
add name=roce traffic-class=3
add name=cnp traffic-class=6

/interface ethernet switch qos map ip
add dscp=26 profile=roce
add dscp=48 profile=cnp

/interface ethernet switch qos tx-manager queue
set 1 schedule=high-priority-group weight=1
set 3 schedule=high-priority-group weight=1 shared-pool-index=1 ecn=yes
set 6 schedule=strict-priority

/interface ethernet switch qos priority-flow-control
add name=pfc-tc3 rx=yes traffic-class=3 tx=yes

/interface ethernet switch qos port
set  sfp-sfpplus1 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus2 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus3 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus4 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus5 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus6 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus7 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus8 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set  sfp-sfpplus9 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set sfp-sfpplus10 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set sfp-sfpplus11 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set sfp-sfpplus12 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set sfp-sfpplus13 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set sfp-sfpplus14 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set sfp-sfpplus15 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep
set sfp-sfpplus16 egress-rate-queue3=10.0Gbps pfc=pfc-tc3 trust-l3=keep

/interface ethernet switch
set switch1 qos-hw-offloading=yes

/ip neighbor discovery-settings
set lldp-dcbx=yes

# /interface ethernet
# set [find switch=switch1] l2mtu=9500
