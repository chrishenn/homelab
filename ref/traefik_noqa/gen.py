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
    "zyxel": "https://192.168.1.12",
    "brother": "https://192.168.1.9",
    "proxmox": "https://192.168.1.42:8006",
    "netdata.proxmox": "http://192.168.1.42:19999",
    "nginx": "http://192.168.1.51:81",
    "traefik": "http://192.168.1.92:8080",
    "lldap": "http://192.168.1.90:17170",
    "iventoy": "http://192.168.1.7:26000",
    "aptcache": "http://192.168.1.47:3142",
    "speedtest": "http://192.168.1.18:3000",
    "stirling": "http://192.168.1.53:8080",
    "whoogle": "http://192.168.1.52:5000",
    "wastebin": "http://192.168.1.54:8088",
    "metube": "http://192.168.1.45:8081",
    "homarr": "http://192.168.1.28:3000",
    "dashy": "http://192.168.1.20:4000",
    "wallos": "http://192.168.1.80",
    "kuma": "http://192.168.1.25:3001",
    "novpn.qbittorrent": "http://192.168.1.72:8090",
    "vpn.qbittorrent": "http://192.168.1.38:8090",
    "nzbget": "http://192.168.1.29:6789",
    "sab": "http://192.168.1.86:7777",
    "flaresolverr": "http://192.168.1.46:8191",
    "audiobookshelf": "http://192.168.1.57:13378",
    "jellyfin": "http://192.168.1.32:8096",
    "jellyseer": "http://192.168.1.37:5055",
    "radarr": "http://192.168.1.26:7878",
    "sonarr": "http://192.168.1.33:8989",
    "lidarr": "http://192.168.1.43:8686",
    "readarr": "http://192.168.1.35:8787",
    "whisparr": "http://192.168.1.34:6969",
    "bazarr": "http://192.168.1.41:6767",
    "prowlarr": "http://192.168.1.27:9696",
    "lazylibrarian": "http://192.168.1.36:5299",
    "photoprism": "http://192.168.1.88:2342",
    "owncast": "http://192.168.1.87:8080",
    "forgejo": "http://192.168.1.100:3000",
    "gist": "http://192.168.1.113:6157",
    "file": "http://192.168.1.42:8080",
}


class SecretVars(StrEnum):
    # ruff: noqa: S105
    CF_API_EMAIL = "CF_API_EMAIL"
    CF_DNS_API_TOKEN = "CF_DNS_API_TOKEN"


secrets_empty = {SecretVars.CF_API_EMAIL: None, SecretVars.CF_DNS_API_TOKEN: None}


def render_dynamic(env: Environment) -> None:
    template = env.get_template("dynamic.yml")
    for svc_prefix, svc_url_src in prefix_srcurl.items():
        svc_name = slugify(svc_prefix, separator="_")
        outf = LocalPath.rules.v / f"{svc_name}.yml"

        var = {"svc_url_src": svc_url_src, "svc_url_rule_0": f"{svc_prefix}.henn.dev", "svc_name": svc_name}
        outf.write_text(template.render(var))

    print(f"gen.py: wrote {len(prefix_srcurl)} hot reload cfg files")


def render_static(env: Environment, secrets: dict[str, str]) -> None:
    template = env.get_template("static.yml")
    outf = LocalPath.sync.v / "traefik.yml"

    cf_email = secrets.get(SecretVars.CF_API_EMAIL)
    assert cf_email, "cloudflare email missing. Is there a secrets.env with CF_API_EMAIL defined?"

    var = {
        "server_dyncfg": ServerPath.rules.p,
        "cf_email": cf_email,
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
    cf_email, cf_dns_api_token = secrets.get(SecretVars.CF_API_EMAIL), secrets.get(SecretVars.CF_DNS_API_TOKEN)

    assert cf_email, f"cloudflare email missing. Is there a secrets.env with {list(SecretVars)} defined?"
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
