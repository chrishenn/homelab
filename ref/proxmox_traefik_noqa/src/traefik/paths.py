import shutil
from enum import Enum
from pathlib import Path
from typing import Never

import yaml
from SystemdUnitParser import SystemdUnitParser
from yaml import SafeLoader


# from dataclasses import dataclass
# from pathlib import Path
#
#
# class EPath:
#     _val: Path
#
#     def __init__(self, val: Path | str) -> None:
#         match val:
#             case str():
#                 self._val = Path(val).resolve()
#             case Path():
#                 self._val = val.resolve()
#             case _:
#                 msg = "param `val` passed to EPath() must have type in {Path, str}"
#                 raise TypeError(msg)
#
#     @property
#     def pth(self) -> Path:
#         return self._val
#
#     @property
#     def str(self) -> str:
#         return str(self._val)
#
#
# @dataclass()
# class MPath:
#     local: EPath
#     remote: EPath


class PathEnum(Enum):
    @property
    def path(self) -> Path:
        return self.value

    @property
    def posix(self) -> str:
        """Render self (enum instance with a value Pathlib.Path) as posix path string."""
        return self.value.as_posix()

    def invalid_ext(self) -> Never:
        raise ValueError(f"File {self.path=} has an invalid extension: must be in .env, .yml, .yaml, .service")

    def dump_yaml(self, content: dict | SystemdUnitParser) -> None:
        with self.path.open("w") as f:
            yaml.dump(content, f, indent=3, default_flow_style=False)

    def dump_unit(self, content: dict | SystemdUnitParser) -> None:
        msg = f"dump_unit: content must have type SystemdUnitParser, got: {type(content)=}"
        assert isinstance(content, SystemdUnitParser), msg

        with self.path.open("w") as f:
            content.write(f)

    def dump_env(self, content: dict) -> None:
        msg = f"dump_env: content must have type dict, got: {type(content)=}"
        assert isinstance(content, dict), msg

        with self.path.open("w") as f:
            for k, v in content.items():
                f.write(f"{k}={v}\n")

    def dump(self, content: dict | SystemdUnitParser) -> None:
        match self.path.suffix:
            case ".yml" | ".yaml":
                self.dump_yaml(content)
            case ".service":
                self.dump_unit(content)
            # TODO: file name ".env" has empty path suffix
            case "":
                self.dump_env(content)
            case _:
                self.invalid_ext()

    def load_yaml(self) -> dict:
        with self.path.open() as f:
            return yaml.load(f, SafeLoader)

    def load_unit(self) -> SystemdUnitParser:
        with self.path.open() as f:
            config = SystemdUnitParser()
            config.read_file(f)
            return config

    def load(self) -> dict | SystemdUnitParser:
        match self.path.suffix:
            case ".yml" | ".yaml":
                return self.load_yaml()
            case ".service":
                return self.load_unit()
            case _:
                return self.invalid_ext()

    def copy(self, dst: Path) -> None:
        shutil.copyfile(self.path, dst)
