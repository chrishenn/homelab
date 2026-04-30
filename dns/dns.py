import os

import pulumi_cloudflare as cf


def env_valid(name: str) -> str:
    val = os.getenv(name)
    assert val
    return val


def local_traefik_dns() -> None:
    """
    Wildcard dns for local services routed by a traefik instance hosted on rack4 and/or rack0.
    At this time, that's {*.henn.dev -> 192.168.1.4}
    At this time, 192.168.1.4 is a virtual IP that can failover from 192.168.1.142 to 192.168.1.70 via keepalived
    """
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


if __name__ == "__main__":
    local_traefik_dns()
