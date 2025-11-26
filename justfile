alias l := fix
alias lint := fix
alias f := fix
alias c := check

check:
    hk check --all

fix:
    hk fix --all

unsafe:
    ruff check --fix --unsafe-fixes
