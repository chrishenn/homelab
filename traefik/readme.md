# Traefik

Generate dynamic traefik config for non-docker services, routed by traefik in docker (Rack4).

The dynamic config file is rendered to local file: "repo/rack4/apps/traefik/cfg/dyncfg.yml"

After generating the dynamic config, sync it to the docker host by pushing to origin and pulling

Scripts are listed in the `traefik` package `pyproject.toml` under `[project.scripts]`

```bash
# generate traefik config file dyncfg.yml and replace it into docker/apps/traefik/cfg/dyncfg.yml
gen
# delete
clean
# clean, then gen
genclean
```
