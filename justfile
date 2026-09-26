set fallback

alias l := lint

slow:
    hk run slow --all

lint:
    hk run slow --all
    just fix
    just check

unsafe:
    ruff check --fix --unsafe-fixes
