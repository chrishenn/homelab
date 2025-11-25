import re

import requests
from data import LocalPath, ServerPath
from more_itertools import one
from pyinfra.operations import files, server, systemd


server.packages(packages="rsync")


def github_latest(owner_repo: str, *args: str) -> list[dict]:
    url = f"https://api.github.com/repos/{owner_repo}/releases/latest"
    assets: list[dict] = requests.get(url, timeout=10).json().get("assets")

    regex = "".join([f"(?=.*{re.escape(r)})" for r in args]) + ".*"

    def matcher(asset: dict) -> re.Match | None:
        return re.search(regex, asset.get("browser_download_url"), flags=re.IGNORECASE)

    return list(filter(matcher, assets))


def traefik_latest() -> tuple[str, str]:
    asset = one(github_latest("traefik/traefik", r"tar.gz", r"amd64", r"linux"))
    return asset.get("browser_download_url"), str(ServerPath.root.path / asset.get("name"))


latest_url, latest_file = traefik_latest()
tool_downloaded = files.download(
    name="download the latest traefik release tar if not present", src=latest_url, dest=latest_file
)

if tool_downloaded.changed:
    server.shell(
        name="unpack traefik and install",
        commands=[
            f"tar -zxvf {latest_file} --wildcards 'traefik' --one-top-level={ServerPath.root.posix}",
            f"rsync -a {ServerPath.root.posix}/traefik {ServerPath.bin.posix}",
        ],
    )

files.sync(name="sync dynamic config files", src=LocalPath.rules.posix, dest=ServerPath.rules.posix, delete=True)
files.put(src=LocalPath.traefik_out.posix, dest=ServerPath.traefik.posix)
files.put(src=LocalPath.unit_out.posix, dest=ServerPath.unit.posix)
files.put(src=LocalPath.env_out.posix, dest=ServerPath.env.posix)
systemd.service(service="traefik", running=True, restarted=True, reloaded=True, enabled=True, daemon_reload=True)
