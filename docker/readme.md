# docker

references for docker/podman usage from various projects. currently unused.

Deploys to platform: docker

---

# notes

Ran out of subnets according to default docker network config. Added "default-address-pools" config with more space in
daemon.json.

# daemon.json

sudo nano /etc/docker/daemon.json

```json
{
    "registry-mirrors": ["https://zot.henn.dev"],
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    },
    "log-level": "warn",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "5"
    },
    "default-address-pools": [
        {
            "base": "172.16.0.0/12",
            "size": 24
        }
    ]
}
```

# docker service unit file

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

```bash
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock -H fd:// -H tcp://192.168.1.70:2375
```

---

### fix for "permission denied" when doing file operations in a container. untested

```yml
x-configs:
    volumes:
        my-named-volume: &volume-my-named-volume 'my-named-volume:/whatever/path/i/need'
        my-other-named-volume: &volume-my-other-named-volume 'my-other-named-volume:/whatever/other/path/i/need'

services:
    myapp:
        image: myappimage
        # user: my-non-root-user
        volumes:
            - *volume-my-named-volume
            - *volume-my-other-named-volume

fix-named-volumes-permissions:
    # the image doesn't matter; easiest to use the same as the target docker service
    image: myappimage
    user: root
    command: chmod 777 /whatever/path/i/need /whatever/other/path/i/need
    volumes:
        - *volume-my-named-volume
        - *volume-my-other-named-volume

volumes:
    my-named-volume:
    my-other-named-volume:
```

---

services I tried but didn't need:

- audacity web ui
    - unneeded for me
- drawio
    - crappier excalidraw
    - network people like it for network diagrams
    - may revisit
- guacamole
    - crappy nexterm/iterm
- pihole
    - using blocky instead
- sist2 / elasticsearch
    - very heavy fuzzy search over files
    - i don't need it right now
- webcord
    - unneeded

services that were broken when I looked at them, but may have improved:

- 13 foot ladder
    - nonworking when I tried it (medium nor nyt)
    - https://github.com/wasi-master/13ft
