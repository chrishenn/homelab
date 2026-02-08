from cytoolz import first, merge
from more_itertools import all_unique
from rich import print
from slugify import slugify

from .data import LocalPaths, certresolver, https_entrypoint, root_domains, svc_map


def render_dyncfg(domain_addr: dict[str, str]) -> dict:
    resolver = certresolver()
    entryp = https_entrypoint()

    routers, services = [], []
    for svc_domain, svc_addr in domain_addr.items():
        for domain in root_domains():
            svc_name = slugify(svc_domain)
            router = {
                f"{svc_name}_router": {
                    "service": svc_name,
                    "rule": f"Host(`{svc_domain}.{domain}`)",
                    "entryPoints": entryp,
                    "tls": {"certResolver": resolver},
                }
            }
            service = {svc_name: {"loadBalancer": {"servers": [{"url": svc_addr}]}}}

            routers.append(router)
            services.append(service)

    assert all_unique(routers, first), "spec'd non-unique router names for dynamic config"
    assert all_unique(services, first), "spec'd non-unique service names for dynamic config"

    return {"http": {"routers": merge(routers), "services": merge(services)}}


def gen() -> None:
    LocalPaths.dyncfg.dump(render_dyncfg(svc_map()))
    print("[bold blue]Generated files[/]")


def clean() -> None:
    LocalPaths.dyncfg.rm()
    print("[bold blue]Cleaned generated files[/]")


def genclean() -> None:
    clean()
    gen()
