# Homelab

Homelab: my configurations, snippets, and small deployments

Top-level folders contain configs/snippets that meet one of these criteria:

- deploys to a specific machine/machines
- deploys to one OS
- requires a python env

---

Docker compose stacks for:

- rack0
    - ryzen 3600
    - GTX 1660
- rack4
    - ryzen 3975WX
    - RTX 3090
- vps0
    - 8 vcpus (hostinger)

K8s talos pulumi stacks for:

- rack2
    - ryzen 5800X
- rack3
    - ryzen 5950X
    - GTX 2080

---

# dev

```bash
# fix: run `hk fix --all`: lint/format
just f

# check: run `hk check --all`: lint
just c

# make sure the env is synced with the lockfile
uv lock --upgrade
uv sync

# type-check with ty, using the repo ty.toml for now. Override by adding one in a subfolder, or from cli
mise x -C vps0 -c 'ty check . --config-file ../ty.toml'
mise x -C traefik -c 'ty check . --config-file ../ty.toml'
mise x -C dns -c 'ty check . --config-file ../ty.toml'
mise x -C k3s -c 'ty check . --config-file ../ty.toml'
mise x -C protonmail -c 'ty check . --config-file ../ty.toml'

# todo
mise x -C rack3 -c 'ty check . --config-file ../ty.toml'
```

---

# public home ip

when moving, your public home ip will need to change in the following places:

- hostinger dashboard, whitelisting the ips that can ssh into the vps
- nzbgeek ip whitelist

---

# todo

- application
    - x {dev, test, deploy, monitor}
    - x {gpu compute, gpu gui, cli, tui, web server, web client}
    - x {bare metal, docker container, k8s container}
    - x {linux, windows, macos, ios, android}

- [ ] general compute
    - [x] k8s linux nodes: talos + pulumi
    - [ ] k8s windows nodes
- [ ] gui desktop
    - [ ] kubevirt?
- [ ] gitops
    - flux
    - argo
- rejected for now
    - proxmox
    - canonical maas
    - ansible
    - terraform (kinda. pulumi can use terraform providers)

- [x] netbootxyz
- [x] stoat chat
- [x] fluxer
- [x] zot
    - [ ] enable mTLS
- [ ] PXE boot windows
    - [ ] iventoy?
    - [ ] netbootxyz?
- [ ] grafana + loki
