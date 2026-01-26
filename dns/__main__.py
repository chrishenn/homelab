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
        resource_name="localdns",
        name=domain,
        ttl=1,
        type="A",
        zone_id=zoneid,
        content=localip,
        proxied=False,
    )
    cf.DnsRecord(
        resource_name="localdns_wildcard",
        name="*",
        ttl=1,
        type="CNAME",
        zone_id=zoneid,
        content=domain,
        proxied=False,
    )


if __name__ == "__main__":
    local_dns()
