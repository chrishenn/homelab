set fallback

alias f := fix
alias c := check
alias l := lint
alias s := sync

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
ss:
    fnox sync --provider age --local-file -f

sync message="sync":
    git commit -a -m '{{ message }}' || true && git pull && git push
