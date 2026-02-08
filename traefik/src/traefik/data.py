from __future__ import annotations

from .paths import PATHS, YamlPath


class LocalPaths(YamlPath):
    dyncfg = PATHS.repo / "rack4/apps/traefik/cfg/dyncfg.yml"


def svc_map() -> dict:
    """Return the map from service domain prefix to service hardware ip."""
    return {
        "kvm0": "http://192.168.1.22:80",
        "pikvm": "https://192.168.1.31",
        "one.mikrotik": "http://192.168.1.1",
        "two.mikrotik": "http://192.168.1.2",
        "zyxel": "https://192.168.1.12",
        "brother": "https://192.168.1.9",
        "proxmox": "https://192.168.1.42:8006",
        "kube-traefik": "http://192.168.30.80:8080",
        "netalert": "http://192.168.1.142:20211",
        "speedtest": "http://192.168.1.142:3030",
        "librespeed": "http://192.168.1.142:3040",
    }


def root_domains() -> list[str]:
    """Return the root domains to prefix local service domains."""
    return ["henn.dev"]


def certresolver() -> str:
    return "cf"


def https_entrypoint() -> str:
    return "websecure"
