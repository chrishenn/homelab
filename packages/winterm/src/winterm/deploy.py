import json
from pathlib import Path

from fabric import Connection
from typer import Typer

from winterm.cnnt import OsType, Remote, connect, connect_call, env_secret, remote_exec


app = Typer()


def cct() -> Remote:
    keyf = Path.home() / ".ssh/id_rsa"
    user = env_secret("SSH_USER")
    passw = env_secret("SSH_PASS")
    return Remote(host="192.168.1.74", user=user, port=22, keyf=keyf, passw=passw, os=OsType.windows)
    # return Remote(host="192.168.1.97", user=user, port=22, keyf=keyf, passw=passw, os=OsType.windows)


def localcct() -> Remote:
    """Return a dummy local connection so that we can use the local shell api."""
    return Remote(host="localhost", user="", port=0, keyf=Path(), passw="", os=OsType.linux)


def set_powershell(c: Connection) -> None:
    """Set openssh default login shell to powershell.
    Assumes that Connection `c` is connected to ms cmd.
    """
    cmd = (
        r'New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value '
        r'"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force'
    )
    remote_exec(c.run, f'powershell -NoProfile -Command "{cmd}"')


def set_pwsh(c: Connection) -> None:
    """Set openssh default login shell to scoop-installed pwsh.
    Assumes that Connection `c` is connected to powershell or pwsh.
    """
    cmd = "(scoop shim info pwsh).path"
    pth = remote_exec(c.run, cmd).stdout.strip()
    cmd = rf"""
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
      -Name DefaultShell `
      -Value {pth} `
      -PropertyType String `
      -Force
    """
    remote_exec(c.run, cmd)


def enable_scripts(c: Connection) -> None:
    """Enable script execution.
    Assumes that Connection `c` is connected to powershell or pwsh.
    """
    cmd = "Set-ExecutionPolicy -scope LocalMachine -ExecutionPolicy Unrestricted -force"
    remote_exec(c.run, cmd)
    cmd = "Set-ExecutionPolicy -scope CurrentUser -ExecutionPolicy Unrestricted -force"
    remote_exec(c.run, cmd)


def scoop_installed(c: Connection) -> None:
    """Install scoop and baseline programs if scoop is not installed.
    Assumes that Connection `c` is connected to powershell or pwsh.
    """
    if remote_exec(c.run, "Get-Command scoop").failed:
        cmd = 'iex "& {$(irm get.scoop.sh)} -RunAsAdmin"'
        remote_exec(c.run, cmd)

        # TODO: need to disconnect and reconnect after installing scoop to find it on path?
        # TODO: maybe use full path to scoop binary here instead
        cmd = (
            "(scoop install git aria2) "
            "-and (scoop config aria2-warning-enabled false) "
            "-and (scoop bucket add extras) "
            "-and (scoop update)"
        )
        remote_exec(c.run, cmd)


def edit_wt_settings(c: Connection) -> None:
    # edit wt settings file
    settings = "$HOME/scoop/persist/windows-terminal/settings/settings.json"
    cmd = f"get-content {settings}"
    cnt = remote_exec(c.run, cmd).stdout.strip()
    cnt = json.loads(cnt)

    # add git bash profile if (arbitrary?) guid is not present
    new_guid = "{b0f5ce57-a6d6-46d8-bc20-38b0b769789a}"
    if new_guid not in {prof["guid"] for prof in cnt["profiles"]["list"]}:
        # vscode settings paths are all double-backslashed
        cmd = "scoop prefix git"
        bash = remote_exec(c.run, cmd).stdout.strip() + "\\bin\\bash.exe"

        val = {"commandline": bash, "guid": new_guid, "hidden": False, "name": "Git Bash"}
        cnt["profiles"]["list"].append(val)

    # global settings
    cnt["multiLinePasteWarning"] = False
    cnt["confirmCloseAllTabs"] = False

    cmd = f"set-content {settings} '{json.dumps(cnt)}'"
    remote_exec(c.run, cmd)


def _deploy(c: Connection) -> None:
    # TODO: we need to check if we're logged into cmd before calling set_powershell()
    # set_powershell(c)
    # TODO: if we did set_powershell(), we need to re-connect with powershell now, because subsequent funcs assume pwsh

    # enable_scripts(c)
    # scoop_installed(c)

    # cmd = 'scoop install pwsh windows-terminal vcredist2022 gow refreshenv bottom'
    # remote_exec(c.run, cmd)
    # set_pwsh(c)
    edit_wt_settings(c)


@app.command()
def deploy() -> None:
    """Deploy."""
    connect_call(connect, cct(), _deploy, "do deploy")


if __name__ == "__main__":
    deploy()
