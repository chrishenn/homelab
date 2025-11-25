from __future__ import annotations

import shutil
from enum import StrEnum

from cytoolz import first, merge
from data import LocalPath, ServerPath, domain, svc_map, trustedips
from infra.env import env_secret
from more_itertools import all_unique
from rich import print
from slugify import slugify
from typer import Typer


app = Typer()


def render_unit(templ: dict) -> dict:
    templ["Service"]["ExecStart"] = f"/usr/bin/traefik --configFile={ServerPath.traefik.posix}"
    templ["Service"]["EnvironmentFile"] = ServerPath.env.posix
    return templ


def render_dyncfg(domain_addr: dict[str, str]) -> dict:
    routers, services = [], []
    for svc_domain, svc_addr in domain_addr.items():
        svc_name = slugify(svc_domain, separator="_")
        router = {
            f"{svc_name}_router": {
                "service": svc_name,
                "rule": f"Host(`{svc_domain}.{domain}`)",
                "entryPoints": "websecure",
                "tls": {"certResolver": "letsencrypt"},
            }
        }
        service = {svc_name: {"loadBalancer": {"servers": [{"url": svc_addr}]}}}

        routers.append(router)
        services.append(service)

    assert all_unique(routers, first), "spec'd non-unique router names for dynamic config"
    assert all_unique(services, first), "spec'd non-unique service names for dynamic config"

    return {"http": {"routers": merge(routers), "services": merge(services)}}


def render_statcfg(templ: dict) -> dict:
    templ["providers"]["file"]["directory"] = ServerPath.rules.posix
    templ["certificatesResolvers"]["letsencrypt"]["acme"]["storage"] = ServerPath.cert.posix
    templ["log"]["filePath"] = ServerPath.log.posix
    templ["accessLog"]["filePath"] = ServerPath.acclog.posix
    templ["entryPoints"]["web"]["forwardedHeaders"]["trustedIPs"] = trustedips()
    templ["entryPoints"]["websecure"]["forwardedHeaders"]["trustedIPs"] = trustedips()
    templ["entryPoints"]["websecure"]["http"]["tls"]["domains"] = [{"main": domain, "sans": [f"*.{domain}"]}]
    return templ


def render_env(templ: dict) -> dict:
    class SecretVars(StrEnum):
        # ruff: noqa: S105
        CF_API_EMAIL = "CF_API_EMAIL"
        CF_DNS_API_TOKEN = "CF_DNS_API_TOKEN"

    cf_email, cf_token = env_secret(SecretVars.CF_API_EMAIL), env_secret(SecretVars.CF_DNS_API_TOKEN)
    templ[SecretVars.CF_API_EMAIL.value] = cf_email
    templ[SecretVars.CF_DNS_API_TOKEN.value] = cf_token
    return templ


@app.command(name="all")
def genall() -> None:
    LocalPath.rules.path.mkdir(parents=True, exist_ok=True)
    LocalPath.traefik_out.dump(render_statcfg(LocalPath.traefik.load()))
    LocalPath.dyncfg_out.dump(render_dyncfg(svc_map()))
    LocalPath.unit_out.dump(render_unit(LocalPath.unit.load()))
    LocalPath.middleware.copy(LocalPath.middleware_out.path)
    LocalPath.proxmox_spice.copy(LocalPath.proxmox_spice_out.path)
    LocalPath.env_out.dump(render_env({}))
    print("[bold blue]Generated files[/]")


@app.command()
def clean() -> None:
    shutil.rmtree(LocalPath.out.path, ignore_errors=True)
    print("[bold blue]Cleaned generated files[/]")


@app.command()
def fresh() -> None:
    clean()
    genall()
