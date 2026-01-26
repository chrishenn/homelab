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
