from typing import TYPE_CHECKING

from data import ServerPath, server_ip, ssh_keyfile, ssh_port, ssh_user
from infra.cnnt import OsType, Remote, connect, connect_call, remote_exec
from infra.env import env_secret
from typer import Typer


if TYPE_CHECKING:
    from fabric import Connection

app = Typer()


def cct() -> Remote:
    return Remote(
        host=server_ip(),
        user=ssh_user(),
        port=ssh_port(),
        keyf=ssh_keyfile(),
        passw=env_secret("SSH_PASS"),
        os=OsType.linux,
    )


def cstart(c: Connection) -> None:
    remote_exec(c.run, "systemctl start traefik")


@app.command()
def start() -> None:
    connect_call(connect, cct(), cstart, "systemctl start traefik")


def crestart(c: Connection) -> None:
    remote_exec(c.run, "systemctl restart traefik")


@app.command()
def restart() -> None:
    connect_call(connect, cct(), crestart, "systemctl restart traefik")


def cstop(c: Connection) -> None:
    remote_exec(c.run, "systemctl stop traefik")


@app.command()
def stop() -> None:
    connect_call(connect, cct(), cstop, "systemctl stop traefik")


def cstatus(c: Connection) -> None:
    remote_exec(c.run, "systemctl status traefik")


@app.command()
def status() -> None:
    connect_call(connect, cct(), cstatus, "systemctl status traefik")


def cenable(c: Connection) -> None:
    remote_exec(c.run, "systemctl enable traefik")


@app.command()
def enable() -> None:
    connect_call(connect, cct(), cenable, "systemctl enable traefik")


def creload(c: Connection) -> None:
    remote_exec(c.run, "systemctl daemon-reload")


@app.command()
def reload() -> None:
    connect_call(connect, cct(), creload, "systemctl daemon-reload")


def clog(c: Connection) -> None:
    remote_exec(c.run, f"tail -500 {ServerPath.log.posix}")


@app.command()
def log() -> None:
    connect_call(connect, cct(), clog, "cat traefik log")


def ccert(c: Connection) -> None:
    remote_exec(c.run, f"cat {ServerPath.cert.posix}")


@app.command()
def cert() -> None:
    connect_call(connect, cct(), ccert, "cat traefik certificate file")
