# sabnzbd

note that the configuration file needs to whitelist your traefik https url

/config/sabnzbd.ini is the default mount location inside the container

```bash
sh -c 'sed -i -e "s/^host_whitelist *=.*$/host_whitelist = sab, sab.henn.dev /g" /config/sabnzbd.ini'
```
