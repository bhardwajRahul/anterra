# Vaultwarden

Vaultwarden is a self-hosted, Bitwarden-compatible password manager running on the GreenCloud VPS via Docker, managed by Ansible playbooks.

## Deployment Details

- **URL**: https://vault.ketwork.in
- **Compose Location**: `ansible/playbooks/vps/templates/vaultwarden-compose.yaml.j2`
- **Deployment Host**: vps (GreenCloud VPS)
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance (localhost:8080)
- **Container Port**: 8080 (maps to 80 inside container)

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| vaultwarden | vaultwarden/server:latest | Password manager server + web vault |

## Required Bitwarden Secrets

| Secret Variable | UUID | Description |
|-----------------|------|-------------|
| `vaultwarden_admin_token_uuid` | `bd8e3386-2464-42a5-8314-b41f00318550` | Argon2 PHC hash for /admin panel |
| `vaultwarden_smtp_from_uuid` | `a4489b9e-9a27-43d7-9365-b41f0031aff4` | From alias email address |
| `vaultwarden_smtp_username_uuid` | `684e0eeb-7728-40c2-a5dd-b41f0031c6fb` | Gmail address |
| `vaultwarden_smtp_password_uuid` | `7970d824-ccbb-4e36-af95-b41f003219d6` | Gmail App Password |
| `vaultwarden_push_installation_id_uuid` | `a33b09ed-bb42-49d0-9b9a-b41f0032cf40` | Bitwarden push installation ID |
| `vaultwarden_push_installation_key_uuid` | `4511e908-5225-4582-82f6-b41f0032e026` | Bitwarden push installation key |

## Initial Setup

1. Generate an admin token: `docker run --rm -it vaultwarden/server /vaultwarden hash`
2. Get push notification credentials from https://bitwarden.com/host
3. Create a Gmail App Password at https://myaccount.google.com/apppasswords
4. Store all secrets in Bitwarden Secrets Manager
5. Add secret UUIDs to `ansible/inventory/group_vars/all/secrets.yaml` (vault-encrypted)
6. Run the setup playbook:
   ```bash
   cd ansible
   ansible-playbook -i inventory/hosts.yaml playbooks/vps/setup_vaultwarden.yaml
   ```
7. Deploy Caddy reverse proxy config:
   ```bash
   ansible-playbook -i inventory/hosts.yaml playbooks/caddy/caddy_reverse_proxy.yaml --limit vps
   ```
8. Deploy DNS record:
   ```bash
   cd opentofu/cloudflare && tofu plan && tofu apply
   ```
9. Configure "Send mail as" alias in Gmail settings for the from address

## Updating

Run the update playbook to pull the latest image and recreate the container:

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/vps/update_vaultwarden.yaml
```

The playbook is idempotent -- running it when already up to date produces no changes.

## Data and Backups

Data is stored at `/opt/vaultwarden/data/` on the VPS, including:
- `db.sqlite3` -- main database
- `attachments/` -- file attachments
- `sends/` -- Bitwarden Send files
- `rsa_key.pem` / `rsa_key.pub.pem` -- RSA keys (auto-generated)

Back up the entire `data/` directory regularly. The SQLite database is the most critical file.

## Important Notes

- Signups are disabled by default. Create accounts via the /admin panel, then disable it if desired.
- The admin panel is at https://vault.ketwork.in/admin (protected by the Argon2 token).
- SMTP uses Gmail with an alias from address. The alias must be configured as "Send mail as" in Gmail settings.
- The container binds to 127.0.0.1:8080 only -- external access goes through Caddy with TLS.
- Docker is installed on the VPS solely for Vaultwarden -- no Portainer agent or Watchtower.

## References

- [Vaultwarden GitHub](https://github.com/dani-garcia/vaultwarden)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Vaultwarden Docker Hub](https://hub.docker.com/r/vaultwarden/server)
- [Bitwarden Push Relay Setup](https://github.com/dani-garcia/vaultwarden/wiki/Enabling-Mobile-Client-push-notification)
