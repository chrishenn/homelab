# services security
## have to run these after the main config script is run. else we'll be disconnected while script is running

/ip ssh
set strong-crypto=yes

/ip service
disable telnet,api,api-ssl,ftp
set winbox  address=192.168.1.2/24
set www     address=192.168.1.2/24
set ssh     address=192.168.1.2/24
set ssh     port=2200
