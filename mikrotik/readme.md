# Mikrotik Terraform Provider (use from pulumi bindings)

```bash
# there's a newer terraform provider for mikrotik, but pulumi will only pull from opentofu registry, which doesn't have it
# https://search.opentofu.org/provider/ddelnano/mikrotik/latest
pulumi package add terraform-provider ddelnano/mikrotik
```

# Todo

Implement firewall rules in pulumi code rather than mt scripts
