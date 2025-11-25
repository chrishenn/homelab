from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from traefik_lxc.cnnt import _crun, _mcall
from traefik_lxc.data import LocalPath, ServerPath, cct, localcct
from traefik_lxc.gen import clean, genall
from traefik_lxc.sys import creload, cstop
from typer import Typer


if TYPE_CHECKING:
    from fabric import Connection


app = Typer()


def _creds(c: Connection, *, host: str = "192.168.1.92", user: str = "root", port: int = 2200) -> None:
    # fabric requires that there be no password on the key
    _mcall(c.local, "rm -f ~/.ssh/id_rsa", hide=True)
    _mcall(c.local, "ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -P ''", hide=True)
    cmd = "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
    _mcall(c.local, f'cat {LocalPath.pub_keyf.posix} | ssh {user}@{host} -p {port} "{cmd}"', hide=True)


@app.command()
def creds() -> None:
    """Create, overwrite, and push ssh credentials in order to later connect to remote using fabric."""
    _crun(_creds, "Server SSH Credential Refresh", localcct(), **cct())


def _push(c: Connection) -> None:
    # otherwise, sftp transfer to rules/dyncfg.yml will fail
    _mcall(c.run, f"mkdir -p {ServerPath.rules.posix}", hide=True)
    # otherwise, traefik will silently fail to create the acme.json file
    _mcall(c.run, f"mkdir -p {ServerPath.ssl.posix}", hide=True)

    _mcall(c.put, LocalPath.traefik_out.path, ServerPath.traefik.posix)
    _mcall(c.put, LocalPath.unit_out.path, ServerPath.unit.posix)
    _mcall(c.put, LocalPath.dyncfg.path, ServerPath.rules.posix)
    _mcall(c.put, LocalPath.secret.path, ServerPath.secret.posix)
    _mcall(c.put, LocalPath.middleware_out.path, ServerPath.rules.posix)
    _mcall(c.put, LocalPath.proxmox_spice_out.path, ServerPath.rules.posix)
    _mcall(c.run, "systemctl daemon-reload", hide=True)


@app.command()
def push() -> None:
    """Push files from local directory to remote."""
    _crun(_push, "Push", cct())


def _install(c: Connection, *, ver: str = "v3.4.0", dst: Path = ServerPath.bin.posix) -> None:
    # https://github.com/traefik/whoami/releases/latest
    url = f"https://github.com/traefik/traefik/releases/download/{ver}/traefik_{ver}_linux_amd64.tar.gz"
    _mcall(c.local, "mkdir -p tmp", hide=True)
    _mcall(c.local, f"wget -O tmp/traefik.tar.gz {url}", hide=True)
    _mcall(c.local, "tar -zxvf tmp/traefik.tar.gz --wildcards 'traefik' --one-top-level=tmp", hide=True)
    _mcall(c.put, "tmp/traefik", dst)
    _mcall(c.run, "traefik version", hide=True)
    _mcall(c.local, "rm -rf tmp", hide=True)


@app.command()
def install() -> None:
    """Download the traefik binary locally and install it to the target system at /usr/bin/."""
    _crun(_install, "Traefik Install on Remote", cct())


def _uninstall(c: Connection) -> None:
    cstop(c)
    _mcall(c.run, f"rm -rf {ServerPath.root.posix}*", hide=True)
    _mcall(c.run, f"rm {ServerPath.unit.posix}", hide=True)
    _mcall(c.run, f"rm {ServerPath.bin.posix}", hide=True)
    creload(c)


@app.command()
def uninstall() -> None:
    _crun(_uninstall, "Traefik Uninstall on Remote", cct())


@app.command()
def cleanpush() -> None:
    clean()
    genall()
    push()
