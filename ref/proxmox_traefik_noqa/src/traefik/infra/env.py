from os import environ

from dotenv import dotenv_values


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
