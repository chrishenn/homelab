from collections.abc import Callable, Generator
from contextlib import AbstractContextManager, contextmanager
from enum import Enum, auto
from os import environ
from pathlib import Path
from typing import Any, TypedDict

from dotenv import dotenv_values
from fabric import Connection, Result
from invoke import UnexpectedExit
from rich import print


class OsType(Enum):
    windows = auto()
    linux = auto()


class Remote(TypedDict):
    host: str
    user: str
    port: int
    keyf: Path
    passw: str
    os: OsType


class DFile:
    local: Path
    remote: Path


def _env_secret(var: str = "SSH_PASS") -> tuple[str, bool]:
    if (value := (dict(environ) | dotenv_values()).get(var)) is None:
        return f"ERROR: tried to load {var=} env and found nothing", False
    if "op://" in value:
        return f"ERROR: env var cannot be a 1password path. Got: {value=}", False
    return value, True


def env_secret(var: str) -> str:
    ssh_pass, succ = _env_secret(var)
    if not succ:
        raise KeyError(ssh_pass)
    return ssh_pass


@contextmanager
def connect(remote: Remote) -> Generator[Connection]:
    host, user, _port, _keyf, passw, _os = remote.values()
    args = {"password": passw}
    yield (ct := Connection(host, user=user, connect_kwargs=args))
    ct.close()


def connect_call(
    cnnt: Callable[[Remote], AbstractContextManager[Connection]],
    remote: Remote,
    func: Callable[[Connection], Any],
    logstr: str,
) -> None:
    print(f"[bold magenta1]Begin {logstr}[/]")
    with cnnt(remote) as c:
        func(c)
    print(f"[bold magenta1]End {logstr}[/]")


def remote_exec(cm: Callable[[Any], Result | None], /, *args: *tuple) -> Result:
    try:
        res = cm(*args)
    except UnexpectedExit as e:
        res = e.result

    if res is None:
        print(f"[bold blue]method={cm.__name__} | {args=}[/]")
        print("[bold blue]No Result Returned[/]")
        raise Exception("no result")

    if hasattr(res, "return_code"):
        code = res.return_code
        print(f"[bold blue]return code: {code}[/]")

        if hasattr(res, "stdout"):
            if code == 0:
                print(f"[bold green]{res.stdout}[/]")
            else:
                print(f"[bold red]{res.stdout}[/]")
                print(f"[bold red]{res.stderr}[/]")
    return res
