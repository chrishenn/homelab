"""Wrappers around a Connection from the 'fabric' library."""

from collections.abc import Callable, Generator
from contextlib import AbstractContextManager, contextmanager
from enum import Enum, auto
from pathlib import Path
from typing import Any, TypedDict, Unpack

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


@contextmanager
def connect(remote: Remote) -> Generator[Connection]:
    host, user, port, _, passw, _ = remote.values()
    args = {"password": passw}
    yield (ct := Connection(host, port=port, user=user, connect_kwargs=args))
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


def remote_exec(cm: Callable[[Any], Result | None], /, *args: *tuple, **kwds: Unpack[dict]) -> Result | None:
    try:
        res = cm(*args, **kwds)
    except UnexpectedExit as e:
        res = e.result

    if res is None:
        print(f"[bold blue]method={cm.__name__} | {args=}[/]")
        print("[bold blue]No Result Returned[/]")
        return None

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
