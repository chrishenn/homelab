########################################################################################################################
:log info "Starting Script01_CRS504.rsc";


########################################################################################################################
#### Default from defconf script

# wait for interfaces
:local count 0;
:while ([/interface ethernet find] = "") do={
    :if ($count = 30) do={
        :log warning "Script01_CRS504: Unable to find ethernet interfaces";
        /quit;
    }
    :delay 1s; :set count ($count +1);
};

# add default bridge
/interface bridge
add name=bridge disabled=no auto-mac=yes protocol-mode=rstp comment=Script01_CRS504;

# add interface ports to default bridge
:local bMACIsSet 0;
:foreach k in=[/interface find where !(slave=yes || name~"bridge")] do={
    :local tmpPortName [/interface get $k name];
    :if ($bMACIsSet = 0) do={
        :if ([/interface get $k type] = "ether") do={
            /interface bridge set "bridge" auto-mac=no admin-mac=[/interface get $tmpPortName mac-address];
            :set bMACIsSet 1;
        }
    }
    :if (([/interface get $k type] != "ppp-out") && ([/interface get $k type] != "lte")) do={
        /interface bridge port
        add bridge=bridge interface=$tmpPortName comment=defconf;
    }
}


########################################################################################################################
#### Script01_CRS504 quirks

# interface 1 is the QSFP28-to-SFP+ adapter - autonegotiation fails, set speed manually
# flow control to allow proper 100G to 10G probably needed?
/interface ethernet set [ find default-name=qsfp28-1-1 ] auto-negotiation=no speed=10G-baseCR tx-flow-control=on rx-flow-control=on


########################################################################################################################
#### Script01_CRS504 IP address

/ip address add address=192.168.1.2/24 interface=bridge comment="Script01_CRS504"
/ip route add gateway=192.168.1.1


########################################################################################################################
#### user

/user add name="$USER" password="$PASS" group=full
/user remove admin
