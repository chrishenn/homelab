set fallback

alias f := fix
alias c := check
alias l := lint
alias s := sync

check:
    hk check --all

fix:
    hk fix --all

slow:
    hk run slow --all

lint:
    hk run slow --all
    just fix
    just check

unsafe:
    ruff check --fix --unsafe-fixes

sync message="sync":
    git commit -a -m '{{ message }}' || true && git pull && git push
