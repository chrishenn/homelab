set fallback

alias f := fix
alias c := check
alias l := lint
alias s := sync

slow:
    hk run slow --all

lint:
    hk run slow --all
    just fix
    just check

unsafe:
    ruff check --fix --unsafe-fixes
