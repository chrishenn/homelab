from getpass import getpass
from pathlib import Path

from data import ssh_keyfile
from infra.env import env_secret


def ssh_keypass() -> str:
    return env_secret("SSH_PASS")


def ssh_keyfile_pub() -> Path:
    return Path(f"{ssh_keyfile()}.pub")


def ssh_keyfile_pub_content() -> str:
    with ssh_keyfile_pub().open() as f:
        return f.read().strip()


def ssh_userpass() -> str:
    return getpass("provide the server user password")
