from pyinfra.operations import docker, files

from blocky.data import cfgpath


cfg = cfgpath()
files.put(src=cfg.local.str, dest=cfg.remote.str)

# systemd.service(service="blocky", running=True, restarted=True, enabled=True)

docker.container(container="blocky", start=False)
docker.container(container="blocky", start=True)
