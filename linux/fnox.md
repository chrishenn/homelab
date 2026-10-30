# fnox

build fnox from src@branch:main on fedora atomic

```bash
toolbox create fedora
toolbox enter fedora
sudo dnf install -y openssl openssl-libs openssl-devel pkg-config perl libudev-devel
```

```toml
"cargo:https://github.com/jdx/fnox" = { version = "branch:main" }
mbx = { version = "latest" }

[wrappers.cargo]
command = "mbx"
env = { MBX_CARGO_SHIM_MODE = "1" }
```
