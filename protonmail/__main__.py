from pathlib import Path

import json5
import pulumi_cloudflare as cf


def protonmail() -> None:
    pfx = "protonmail"

    with Path("secrets.json").open() as f:
        jsn = json5.load(f)

    for entry in jsn.values():
        zoneid = entry["zoneid"]
        for i, (rtype, name, cnt, priority) in enumerate(entry["records"]):
            print(zoneid, rtype, name, cnt, priority)
            cf.DnsRecord(
                resource_name=f"{pfx}_{rtype}_{i}_{zoneid[:4]}",
                name=name,
                ttl=1,
                type=rtype,
                zone_id=zoneid,
                content=cnt,
                priority=priority,
                proxied=False,
            )


if __name__ == "__main__":
    protonmail()
