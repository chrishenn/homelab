import os

import pulumi_cloudflare as cf


def env_valid(name: str) -> str:
    val = os.getenv(name)
    assert val
    return val


def local_dns() -> None:
    zoneid = env_valid("ZONEID")
    domain = env_valid("DOMAIN")
    localip = env_valid("LOCALIP")

    cf.DnsRecord(
        resource_name=domain,
        type="A",
        name=domain,
        content=localip,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )
    cf.DnsRecord(
        resource_name=f"{domain}_star",
        type="CNAME",
        name="*",
        content=domain,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )


def local_arecords():
    """
    Subdomain {A, wildcard} entries for services.

    Often required for CORS. Remember to update traefik staticcfg so that letsyncrypt will use CF for certs for the
    subdomains for svcs
    """
    svcs = ["plane"]

    zoneid = env_valid("ZONEID")
    domain = env_valid("DOMAIN")
    localip = env_valid("LOCALIP")

    for svc in svcs:
        cf.DnsRecord(
            resource_name=f"{domain}_{svc}",
            type="A",
            name=svc,
            content=localip,
            ttl=1,
            zone_id=zoneid,
            proxied=False,
        )
        cf.DnsRecord(
            resource_name=f"{domain}_{svc}_star",
            type="CNAME",
            name=f"*.{svc}",
            content=f"{svc}.{domain}",
            ttl=1,
            zone_id=zoneid,
            proxied=False,
        )


if __name__ == "__main__":
    local_dns()
    local_arecords()
