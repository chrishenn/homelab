import os
from pathlib import Path

import yaml
from yaml import SafeLoader


def load_yaml(path: Path) -> dict:
    assert path.exists()
    with path.open() as f:
        return yaml.load(f, SafeLoader)


def env_valid(name: str) -> str:
    assert name in os.environ
    val = os.getenv(name)
    assert val
    return val
