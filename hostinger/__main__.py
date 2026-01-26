import os

import pulumi_cloudflare as cf


def env_valid(name: str) -> str:
    assert name in os.environ
    val = os.environ[name]
    assert val
    return val


def pangolin_public_resources() -> None:
    """
    Pangolin Public Resources are proxied by the pangolin server at HOSTINGERIP.
    They are dns-queryable via name.domain, where the domain is tied to clouflare's zone id (given by DOMAIN_ZONEID)
    """
    pfx = "dns"
    hostip: str = env_valid("HOSTINGERIP")
    zoneid: str = env_valid("DOMAIN_ZONEID")

    rsc_names = [
        "backrest",
        "comfy",
        "gist",
        "immich",
        "jellyfin",
        "jellyseerr",
        "kuma",
        "ollama",
        "pangolin",
        "stirling",
    ]
    for name in rsc_names:
        # ttl=1 means "auto" ttl
        cf.DnsRecord(
            resource_name=f"{pfx}_{name}",
            name=name,
            ttl=1,
            type="A",
            zone_id=zoneid,
            content=hostip,
            proxied=False,
        )


if __name__ == "__main__":
    pangolin_public_resources()
