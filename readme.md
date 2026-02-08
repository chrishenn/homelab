# Homelab

Homelab: my configurations, snippets, and small deployments

Top-level folders contain configs/snippets that meet one of these criteria:

- deploys to a specific machine
- restricted to one OS
- requires a python env

---

Docker compose stacks for:

- rack0
    - ryzen 3600
    - GTX 1660
- rack4
    - ryzen 3975WX
    - RTX 3090

---

# dev

```bash
# mypy is not available from mise registry
# this may be on its way out; probably replace with astra/ty soon (https://docs.astral.sh/ty)
uv tool install mypy

# run `hk fix`: lint/format
just f

# run `hk check`: lint
just c
```

---

# todo

- [ ] Local container registry pull-through cache
    - [ ] harbor or nexus or docker's official registry
- [ ] test + deploy {HA DHCP, DNS, applications}
    - [ ] programmatic clustered network configuration
        - [ ] proxmox or canonical maas
        - [ ] ansible or terraform
    - [ ] programmatic cluster application {test, deployment}
        - [ ] k8s_hybrid (linux, windows, macos)
- [ ] renovate
    - https://docs.astral.sh/uv/guides/integration/dependency-bots/
    - https://github.com/renovatebot/renovate
