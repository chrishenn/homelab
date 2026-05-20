# docker

references for docker/podman usage from various projects

Deploys to platform: docker

---

# notes

Ran out of subnets according to default docker network config. Added "default-address-pools" config with more space in
daemon.json.

---

You can't have both the "hosts" key and also the -H directives in the systemd unit and also daemon.json.
I think we usually pick the systemd unit, but YMMV

```bash
sudo systemctl edit docker

[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375

sudo systemctl daemon-reload
sudo systemctl restart docker
```

```bash
sudo nano /etc/docker/daemon.json

"hosts": ["unix:///var/run/docker.sock", "tcp://127.0.0.1:2375"],
```
