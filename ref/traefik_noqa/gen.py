"""see: https://go-acme.github.io/lego/dns/cloudflare/"""

from enum import Enum, StrEnum
from pathlib import Path
from shutil import copy2

import dotenv
from jinja2 import Environment, PackageLoader
from slugify import slugify


class EEnum(Enum):
    @property
    def v(self) -> Path:
        return self.value

    @property
    def p(self) -> str:
        """Render self (enum instance with a value Pathlib.Path) as posix path string."""
        return self.value.as_posix()


class LocalPath(EEnum):
    sync = Path(__file__).parent / "sync"
    rules = sync / "rules"

    templates = Path(__file__).parent / "templates"
    nogen = templates / "nogen"

    secrets = Path(__file__).parent / "secrets.env"


class ServerPath(EEnum):
    root = Path("/etc/traefik")

    certs = root / "ssl"
    cert = certs / "acme.json"

    sync = root / "sync"
    rules = sync / "rules"
    traefik = sync / "traefik.yml"

    logs = root / "logs"
    log = logs / "server.log"
    acclog = logs / "access.log"


prefix_srcurl = {
    "pikvm": "https://192.168.1.31",
    "blikvm": "https://192.168.1.69",
    "one.mikrotik": "http://192.168.1.1",
    "two.mikrotik": "http://192.168.1.2",
}


class SecretVars(StrEnum):
    # ruff: noqa: S105
    CF_DNS_API_TOKEN = "CF_DNS_API_TOKEN"


secrets_empty = {SecretVars.CF_DNS_API_TOKEN: None}


def render_dynamic(env: Environment) -> None:
    template = env.get_template("dynamic.yml")
    for svc_prefix, svc_url_src in prefix_srcurl.items():
        svc_name = slugify(svc_prefix, separator="_")
        outf = LocalPath.rules.v / f"{svc_name}.yml"

        var = {"svc_url_src": svc_url_src, "svc_url_rule_0": f"{svc_prefix}.henn.dev", "svc_name": svc_name}
        outf.write_text(template.render(var))

    print(f"gen.py: wrote {len(prefix_srcurl)} hot reload cfg files")


def render_static(env: Environment, _secrets: dict[str, str]) -> None:
    template = env.get_template("static.yml")
    outf = LocalPath.sync.v / "traefik.yml"

    var = {
        "server_dyncfg": ServerPath.rules.p,
        "server_cert": ServerPath.cert.p,
        "server_log": ServerPath.log.p,
        "server_acclog": ServerPath.acclog.p,
    }
    outf.write_text(template.render(var))

    print("gen.py: wrote 1 static cfg file")


def d2envsecretslist(secretsd: dict[str, str]) -> list[str]:
    def kv2str(kv: tuple) -> str:
        k, v = kv
        return f'Environment="{k}={v}"'

    return list(map(kv2str, secretsd.items()))


def render_unit(env: Environment, secrets: dict[str, str]) -> None:
    cf_dns_api_token = secrets.get(SecretVars.CF_DNS_API_TOKEN)
    assert cf_dns_api_token, f"cloudflare dns token missing. Is there a secrets.env with {list(SecretVars)} defined?"

    template = env.get_template("traefik.service")
    outf = LocalPath.sync.v / "traefik.service"
    var = {"server_staticcfg": ServerPath.traefik.p, "env_secrets": d2envsecretslist(secrets)}
    outf.write_text(template.render(var))

    print("gen.py: wrote 1 systemd unit file")


def render_nogen() -> None:
    """Files under 'templates/nogen/' are copied into the 'rules' folder for sync like other dynamic configs, but do not
    require template generation, and are copied as-is.
    """
    for f in LocalPath.nogen.v.glob("*"):
        copy2(f, LocalPath.rules.v)


def render() -> None:
    LocalPath.sync.v.mkdir(parents=True, exist_ok=True)
    LocalPath.rules.v.mkdir(parents=True, exist_ok=True)

    # env = Environment(loader=PackageLoader("gen"), autoescape=True)
    env = Environment(loader=PackageLoader("gen"), autoescape=True)
    secrets = secrets_empty | dotenv.dotenv_values(LocalPath.secrets.v)
    # render_dynamic(env)
    # render_static(env, secrets)
    render_unit(env, secrets)
    render_nogen()


if __name__ == "__main__":
    render()
