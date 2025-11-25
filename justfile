alias l := lint
alias c := check

lint: fix

check:
    hk check --all

fix:
    hk fix --all

unsafe:
    ruff check --fix --unsafe-fixes
