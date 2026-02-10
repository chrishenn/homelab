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

_ssh usr ip dir="/home" port="22":
    ssh {{ usr }}@{{ ip }} -p {{ port }} -t "$(op read op://homelab/svc/bash) && cd {{ dir }} && exec bash -l"

rack0: (_ssh "$RACK0_USR" "$RACK0_IP" "$RACK0_REPO" "$RACK0_PORT")

rack4: (_ssh "$RACK4_USR" "$RACK4_IP" "$RACK4_REPO" "$RACK4_PORT")

vps0: (_ssh "$VPS0_USR" "$VPS0_IP" "$VPS0_REPO" "$VPS0_PORT")
