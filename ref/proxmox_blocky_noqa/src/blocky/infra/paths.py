from dataclasses import dataclass
from pathlib import Path


class EPath:
    _val: Path

    def __init__(self, val: Path | str) -> None:
        match val:
            case str():
                self._val = Path(val).resolve()
            case Path():
                self._val = val.resolve()
            case _:
                msg = "param `val` passed to EPath() must have type in {Path, str}"
                raise TypeError(msg)

    @property
    def pth(self) -> Path:
        return self._val

    @property
    def str(self) -> str:
        return str(self._val)


@dataclass()
class MPath:
    local: EPath
    remote: EPath
