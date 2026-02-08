# Mikrotik Config

Configuration scripts for my 10GBe backbone and 100GBe subnet

Deploys to platform: mikrotik

---

# Shelved: Mikrotik Terraform Provider used from pulumi bindings

```bash
# there's a newer terraform provider for mikrotik, but pulumi will only pull from opentofu registry, which doesn't have it
# https://search.opentofu.org/provider/ddelnano/mikrotik/latest
pulumi package add terraform-provider ddelnano/mikrotik
```

- Implement firewall rules in pulumi code rather than mt scripts

While there are two existing Mikrotik pulumi providers, and one Terraform provider that could be wrapped into a pulumi
provider, none of these include all the config types that I typically use in even my baseline router config.

At the moment, I'd have to split configuration between mikrotik scripts and pulumi code - and not in logical chunks of
functionality. I don't think it's worth the effort (yet) to translate some of the scripts and juggle both config
sources.
