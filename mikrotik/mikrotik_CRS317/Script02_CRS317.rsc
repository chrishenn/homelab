# services security
## have to run these after the main config script is run. else we'll be disconnected while script is running

tool mac-server set allowed-interface-list=LAN
tool mac-server mac-winbox set allowed-interface-list=LAN

/ip neighbor discovery-settings set discover-interface-list=LAN

/ip ssh
set strong-crypto=yes

/ip service
set winbox address=192.168.1.0/24
set www address=192.168.1.0/24
disable telnet,api,api-ssl,ftp
set ssh address=192.168.1.0/24
set ssh port=2200
