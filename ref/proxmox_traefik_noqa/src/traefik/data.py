from __future__ import annotations

from pathlib import Path

from paths import PathEnum


domain = "henn.dev"


class LocalPath(PathEnum):
    keyf = Path.home() / ".ssh/id_rsa"
    pub_keyf = Path.home() / ".ssh/id_rsa.pub"

    root = Path(__file__).parent
    out = root / "out"

    rules = root / "out/rules"
    middleware = root / "templates/middleware.yml"
    middleware_out = root / "out/rules/middleware.yml"
    proxmox_spice = root / "templates/proxmox_spice.yml"
    proxmox_spice_out = root / "out/rules/proxmox_spice.yml"
    traefik = root / "templates/traefik.yml"
    traefik_out = root / "out/traefik.yml"
    unit = root / "templates/traefik.service"
    unit_out = root / "out/traefik.service"
    dyncfg_out = root / "out/rules/dyncfg.yml"
    env_out = root / "out/.env"


class ServerPath(PathEnum):
    bin = Path("/usr/bin/traefik")
    unit = Path("/etc/systemd/system/traefik.service")
    root = Path("/etc/traefik")

    env = root / ".env"
    traefik = root / "traefik.yml"
    rules = root / "rules"
    dyncfg = root / "rules/dyncfg.yml"
    ssl = root / "ssl"
    cert = root / "ssl/acme.json"
    log = root / "logs/server.log"
    acclog = root / "logs/access.log"


def svc_map() -> dict:
    """Return the map from service domain to service hardware ip."""
    return {
        "pikvm": "https://192.168.1.31",
        "one.mikrotik": "http://192.168.1.1",
        "two.mikrotik": "http://192.168.1.2",
        "zyxel": "https://192.168.1.12",
        "brother": "https://192.168.1.9",
        "proxmox": "https://192.168.1.42:8006",
        "traefik": "http://192.168.1.92:8080",
        "iventoy": "http://192.168.1.7:26000",
        "file": "http://192.168.1.42:8080",
        "kvm0": "http://192.168.1.22:80",
    }


def trustedips() -> list[str]:
    return [
        "103.21.244.0/22",
        "103.22.200.0/22",
        "103.31.4.0/22",
        "104.16.0.0/13",
        "104.24.0.0/14",
        "108.162.192.0/18",
        "131.0.72.0/22",
        "141.101.64.0/18",
        "162.158.0.0/15",
        "172.64.0.0/13",
        "173.245.48.0/20",
        "188.114.96.0/20",
        "190.93.240.0/20",
        "197.234.240.0/22",
        "198.41.128.0/17",
        "2400:cb00::/32",
        "2606:4700::/32",
        "2803:f800::/32",
        "2405:b500::/32",
        "2405:8100::/32",
        "2a06:98c0::/29",
        "2c0f:f248::/32",
    ]


def server_ip() -> str:
    return "192.168.1.92"


def ssh_user() -> str:
    return "root"


def ssh_port() -> int:
    return 2200


def ssh_keyfile() -> Path:
    return Path.home() / ".ssh/id_rsa"
