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
set qsfp28-1-1 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-1-2 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-1-3 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-1-4 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep

set qsfp28-2-1 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-2-2 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-2-3 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-2-4 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep

set qsfp28-3-1 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-3-2 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-3-3 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-3-4 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep

set qsfp28-4-1 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-4-2 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-4-3 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep
set qsfp28-4-4 egress-rate-queue3=100.0Gbps pfc=pfc-tc3 trust-l3=keep

/interface ethernet switch
set switch1 qos-hw-offloading=yes

/ip neighbor discovery-settings
set lldp-dcbx=yes

# /interface ethernet
# set [find switch=switch1] l2mtu=9500
