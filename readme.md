# Homelab

Homelab: my configurations, snippets, and small deployments

Note: Python env will not build when cifs-mounted

Docker compose stacks for:

- rack0
  - ryzen 3600
  - GTX 1660
- rack4
  - ryzen 3975WX
  - RTX 3090

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
