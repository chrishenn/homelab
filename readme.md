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

K8s talos pulumi stacks for:

- rack2
    - ryzen 5800X
- rack3
    - ryzen 5950X
    - GTX 1080

---

# dev

```bash
# mypy is not available from mise registry
# this may be on its way out; probably replace with astra/ty soon (https://docs.astral.sh/ty)
uv tool install mypy

# run `hk fix --all`: lint/format
just f

# run `hk check --all`: lint
just c
```

---

# todo

- [ ] application {dev, test, deploy}: {gpu compute, gpu gui, cli, tui, server, web}
    - [ ] general compute
        - [x] k8s linux nodes: talos + pulumi
        - [ ] k8s windows nodes
    - [ ] gui desktop
        - [ ] kubevirt
    - rejected for now
        - proxmox
        - canonical maas
        - ansible
        - terraform (kinda. pulumi can use terraform providers)
    - [ ] gitops solution
