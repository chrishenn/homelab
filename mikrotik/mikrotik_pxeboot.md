# PXE boot

Mikrotik DHCP config to allow IPXE

try IP -> DHCP Server -> Networks -> edit the active "DHCP network" -> next server -> 192.168.1.142
try IP -> DHCP Server -> Networks -> edit the active "DHCP network" -> boot file name -> netboot.xyz.efi

---

```bash
# Note: I don't think that /ip/dhcp-server is the correct place for this
## Apply basic dhcp config to find ipxe server at "192.168.1.34", serving file "netboot.xyz.efi"

/ip/dhcp-server/option
add name="next-server" code=66 value="'192.168.1.34'"
add name="bootfile-name" code=67 value="'netboot.xyz.efi'"

/ip/dhcp-server/option/sets
add name="next-server-set" options=next-server

/ip/dhcp-server/network
set 0 next-server="192.168.1.34" boot-file-name="'netboot.xyz.efi'" dhcp-option=next-server,bootfile-name dhcp-option-set=next-server-set

# edit dhcp server -> network
# 	Next Server = 192.168.1.34
# 	Boot File Name = netboot.xyz.efi
# 	DHCP Options
# 	 -> add both next-server, bootfile-name
# 	DHCP Option Set = next-server-set
```
