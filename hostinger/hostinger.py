import os

import pulumi_cloudflare as cf


def env_valid(name: str) -> str:
    assert name in os.environ
    val = os.environ[name]
    assert val
    return val


def pangolin_base_dns() -> None:
    zoneid = env_valid("ZONEID")
    hostip: str = env_valid("VPS0_IP")

    cf.DnsRecord(
        resource_name="pangolin_chenndev",
        type="A",
        name="@",
        content=hostip,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )
    cf.DnsRecord(
        resource_name="pangolin_chenndev_star",
        type="A",
        name="*",
        content=hostip,
        ttl=1,
        zone_id=zoneid,
        proxied=False,
    )


if __name__ == "__main__":
    pangolin_base_dns()
