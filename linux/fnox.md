# fnox

build fnox from src@branch:main on fedora atomic

## toolbox

```bash
toolbox create fedora
toolbox enter fedora
sudo dnf install -y openssl openssl-libs openssl-devel pkg-config perl libudev-devel
```

```toml
"cargo:https://github.com/jdx/fnox" = { version = "branch:main" }
```

## pixi

```bash
# including gcc fixes some gnarly glibc version mismatch issues
# make sure to clear your mbx cache and pixi cache if you built some of the rust deps without gcc, then hit glibc
# errs. otherwise you'll see more problems from glibc symbol mismatches between crates
pixi init && pixi add openssl pkg-config perl libudev gcc
pixi exec mise use "cargo:https://github.com/jdx/fnox@branch:main"
```

```toml
# I think release builds of fnox usually set this FNOX_NO_PIE in its github action, so might be worth setting here
"cargo:https://github.com/jdx/fnox" = { version = "branch:main", install_env= { FNOX_NO_PIE = 1 }, bin = "fnox"}
# also works
"cargo:https://github.com/jdx/fnox" = { version = "branch:main"}
```
