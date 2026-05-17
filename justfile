set fallback

alias f := fix
alias c := check
alias l := lint

check:
    hk check --all

fix:
    hk fix --all

lint:
    ruff format
    ruff check --fix

unsafe:
    ruff check --fix --unsafe-fixes

# sync secrets from fnox.toml (1password provider) to fnox.local.toml (age provider)
ssync:
    fnox sync --provider age --config fnox.local.toml -f
