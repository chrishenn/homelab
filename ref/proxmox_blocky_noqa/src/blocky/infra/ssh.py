from getpass import getpass
from pathlib import Path

import dotenv
from pyinfra import logger

from blocky.data import ssh_keyfile_pub


def ssh_keypass() -> str:
    if dotenv.dotenv_values().get("SSH_PASS") is None:
        logger.error("tried to load SSH_PASS value from .env file and got nothing")

    logger.info(f"ssh password: {dotenv.dotenv_values().get('SSH_PASS')}")
    return dotenv.dotenv_values().get("SSH_PASS")


def ssh_keyfile_pub_content() -> str:
    with Path(ssh_keyfile_pub()).open() as f:
        return f.read().strip()


def ssh_userpass() -> str:
    return getpass("provide the server user password")
