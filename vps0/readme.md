# Hostinger Pangolin: Server Setup, CloudFlare DNS (Pulumi)

```bash
# preview the resource plan
pulumi preview --save-plan=plan.json

# apply
pulumi up
```

verify open ports

```bash
# when the batch size -b is too big, no open ports are found, even though there are several
rustscan -a pangolin.chenn.dev -b 10
```

---

## todo

pulumi has a hostinger provider - use that to configure the VPS, rather than the bash snippets used here
