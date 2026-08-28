import os
from enum import StrEnum, auto

import pulumi
import pulumi_cloudflare as cf
import pulumi_hostinger as hs
from pydantic.dataclasses import dataclass


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


class Proto(StrEnum):
    udp = "UDP"
    tcp = "TCP"
    icmp = "ICMP"
    icmpv6 = "ICMPv6"
    gre = "GRE"
    esp = "ESP"
    ah = "AH"
    ssh = "SSH"
    http = "HTTP"
    https = "HTTPS"
    mysql = "MySQL"
    postgresql = "PostgreSQL"


class Src(StrEnum):
    any = auto()
    custom = auto()


@dataclass
class Rule:
    proto: Proto
    port: str
    source: Src = Src.any
    source_detail: str = Src.any

    def __str__(self) -> str:
        return f"{self.proto}_{self.port}_{self.source}_{self.source_detail or 'na'}"


def hostinger_firewall() -> None:
    env_valid("HOSTINGER_API_TOKEN")
    home_ip: str = env_valid("HOME_IP")

    fw = hs.VpsFirewall(resource_name="vps0_firewall_default", name="default")
    fwid = fw.vps_firewall_id

    pulumi.export("vps0_firewall_default_id", fwid)

    rules: list[Rule] = [
        # ssh
        Rule(Proto.tcp, "2200", Src.custom, home_ip),
        Rule(Proto.tcp, "2424"),
        Rule(Proto.tcp, "2525"),
        Rule(Proto.tcp, "2626"),
        # email
        Rule(Proto.tcp, "25"),
        Rule(Proto.tcp, "465"),
        Rule(Proto.tcp, "993"),
        # rustdesk
        Rule(Proto.tcp, "21115"),
        Rule(Proto.tcp, "21116"),
        Rule(Proto.udp, "21116"),
        Rule(Proto.tcp, "21117"),
        # pangolin, gerbil/wireguard
        Rule(Proto.tcp, "443"),
        Rule(Proto.https, "443"),
        Rule(Proto.http, "80"),
        Rule(Proto.udp, "21820"),
        Rule(Proto.udp, "51820"),
        # wireguard
        Rule(Proto.udp, "51821"),
        # livekit
        Rule(Proto.udp, "3478"),
        Rule(Proto.tcp, "7881"),
        Rule(Proto.udp, "7882"),
        Rule(Proto.udp, "10000"),
        Rule(Proto.udp, "40000:40100"),
        Rule(Proto.tcp, "40000:40100"),
        Rule(Proto.udp, "50000:50100"),
    ]

    for rule in rules:
        hs.VpsFirewallRule(
            resource_name=f"fw_default_{rule}",
            firewall_id=fwid,
            port=rule.port,
            protocol=rule.proto,
            source=rule.source,
            source_detail=rule.source_detail,
        )

    # Unfortunately, the terraform provider only inclues an "action" to sync or activate a firewall (aka group of
    # firewall rules), which do not appear to translate into pulumi's state-management model - or at least, the auto-gen
    # that ports the terraform module into pulumi doesn't. Also, the data source to check the firewall's state
    # (fw.is_synced) does not appear to work.
    pulumi.log.warn("If firewall rules changed you will need to manually activate and/or sync them")


if __name__ == "__main__":
    pangolin_base_dns()
    archivebox_dns()
    hostinger_firewall()
