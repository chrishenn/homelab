from pathlib import Path

from blocky.infra.paths import EPath, MPath


def cfgpath() -> MPath:
    # return MPath(EPath(Path(__file__).parent / "config.yml"), EPath("/opt/blocky/config.yml"))

    src = "$HOME/Projects/homelab/docker/apps/blocky/config.yml"
    dst = "$HOME/Projects/homelab/docker/apps/blocky/config.yml"
    return MPath(EPath(src), EPath(dst))


def server_ip() -> str:
    # return "192.168.1.49"
    return "rack2"


def ssh_keyfile(keyf: Path | None = None) -> str:
    keyf = keyf or Path.home() / ".ssh/id_rsa"
    return str(keyf)


def ssh_keyfile_pub(keyf: Path | None = None) -> str:
    keyf = keyf or Path.home() / ".ssh/id_rsa.pub"
    return str(keyf)


def ssh_user() -> str:
    # return "root"
    return "chris"
