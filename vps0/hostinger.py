import os

import pulumi_cloudflare as cf


def env_valid(name: str) -> str:
    assert name in os.environ
    val = os.environ[name]
    assert val
    return val


def pangolin_base_dns() -> None:
    env_valid("CLOUDFLARE_API_TOKEN")

    zoneid: str = env_valid("ZONEID")
    hostip: str = env_valid("VPS0_IP")

    domain_base = "chenn.dev"
    domain_base_star = "*.chenn.dev"

    cf.DnsRecord(
        resource_name="pangolin_chenndev",
        type="A",
        name=domain_base,
        content=hostip,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )
    cf.DnsRecord(
        resource_name="pangolin_chenndev_star",
        type="CNAME",
        name=domain_base_star,
        content=domain_base,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )


def archivebox_dns() -> None:
    env_valid("CLOUDFLARE_API_TOKEN")

    zoneid: str = env_valid("ZONEID")
    hostip: str = env_valid("VPS0_IP")

    archivebox_domain = "archive.chenn.dev"
    archivebox_domain_star = "*.archive.chenn.dev"

    cf.DnsRecord(
        resource_name="archivebox_chenndev",
        type="A",
        name=archivebox_domain,
        content=hostip,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )
    cf.DnsRecord(
        resource_name="archivebox_chenndev_star",
        type="CNAME",
        name=archivebox_domain_star,
        content=archivebox_domain,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )


if __name__ == "__main__":
    pangolin_base_dns()
    archivebox_dns()
