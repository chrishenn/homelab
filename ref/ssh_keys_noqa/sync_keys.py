# ruff: noqa

# deprecated
# sync ssh keys with python fabric?


from cytoolz import curry


@curry
def boot_sshkey(c: Connection, *, remote: Remote) -> None:
    host, user, port, keyf, passw, os = remote.values()

    # create local keyfile if not exist
    res = remote_exec(c.local, f"test -f {keyf}", hide=False)
    if res is None or (res.exited != 0):
        remote_exec(c.local, f"ssh-keygen -t rsa -b 4096 -f {keyf} -P {passw}", hide=False)

    # copy contents of local public key into remote's authorized_keys, connecting with ssh username, password
    match os:
        case OsType.windows:
            file = "$HOME/.ssh/authorized_keys"
            cmd = f'pwsh -NoProfile -Command "touch {file} && $input >> {file}"'
        case OsType.linux:
            cmd = "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
        case _:
            raise TypeError(f"os must be in {list(OsType)=}")

    remote_exec(c.local, f"cat {keyf}.pub | ssh {user}@{host} -p {port} '{cmd}'", hide=False)
