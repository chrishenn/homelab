from __future__ import annotations

import shutil
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Never

import yaml
from yaml import SafeLoader


def project_pkgs() -> Path:
    trav = Path.cwd()
    while trav != Path.cwd().root:
        if (attempt := trav / "packages").exists():
            return attempt
        trav = trav.parent
    msg = "failed to find repo/packages"
    raise FileNotFoundError(msg)


@dataclass(frozen=True)
class PATHS:
    pkgs: Path = project_pkgs()
    repo: Path = pkgs.parent


class YamlPath(Enum):
    name: str
    value: Path

    @property
    def path(self) -> Path:
        return self.value

    @property
    def posix(self) -> str:
        """Render self (enum instance with a value Pathlib.Path) as posix path string."""
        return self.value.as_posix()

    def invalid_ext(self) -> Never:
        raise ValueError(f"File {self.path=} has an invalid extension: must be in .yml, .yaml")

    def dump_yaml(self, content: dict) -> None:
        with self.path.open("w") as f:
            yaml.dump(content, f, default_flow_style=False)

    def dump(self, content: dict) -> None:
        match self.path.suffix:
            case ".yml" | ".yaml":
                self.dump_yaml(content)
            case _:
                self.invalid_ext()

    def load_yaml(self) -> dict:
        with self.path.open() as f:
            return yaml.load(f, SafeLoader)

    def load(self) -> dict:
        match self.path.suffix:
            case ".yml" | ".yaml":
                return self.load_yaml()
            case _:
                return self.invalid_ext()

    def copy(self, dst: Path) -> None:
        shutil.copyfile(self.path, dst)

    def rm(self) -> None:
        self.value.unlink(missing_ok=True)
