# Traefik

Generate traefik config for bare-metal (or LXC) installation

Generate:

- Systemd unit file
- Secrets on disk (.env)
- Static traefik config
- Dynamic traefik config

Infra:

- Sync a keypair to remote
- Push generated files to remote

CLI:

- Typer commands to run various ops on remote
