Push changes from the local config.yml to the config.yml running on the remote host

Note: now that there's a blocky on rack2/docker, we should use that config file as source of truth and sync to that
machine

```bash
# one-time ssh bootstrap, pushes an ssh key to remote, connecting over ssh and asking for an ssh user-pass
poe boot

# push changes from config file to remote; restart the blocky systemd service
poe push
```

Manual steps to change the remote file

```bash
ssh root@192.168.1.49
nano /opt/blocky/config.yml
systemctl restart blocky
```
