# Karakeep

Karakeep is a self-hosted bookmark manager running on the GreenCloud VPS via Docker, managed by Ansible playbooks. Meilisearch runs on the homelab (docker_pve2 via Portainer) and is accessed over the public URL `meilisearch.ketwork.in`. Chrome (crawling) and AI tagging are not enabled.

## Deployment Details

- **URL**: https://keep.ketwork.in
- **Compose Location**: `ansible/playbooks/vps/templates/karakeep-compose.yaml.j2`
- **Deployment Host**: vps (GreenCloud VPS)
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance (localhost:9721)
- **Container Port**: 9721 (maps to 3000 inside container)

## Stack Components

| Container | Image | Host | Purpose |
|-----------|-------|------|---------|
| karakeep | ghcr.io/karakeep-app/karakeep:release | VPS | Bookmark manager |
| meilisearch | getmeili/meilisearch:latest | docker_pve2 (Portainer) | Full-text search engine |

## Required Bitwarden Secrets

| Secret Variable | UUID | Description |
|-----------------|------|-------------|
| `karakeep_nextauth_secret_uuid` | `33da07f9-acf3-435c-b126-b39a00da782d` | NextAuth session encryption key |
| `karakeep_meili_master_key_uuid` | `bf431938-c35c-4f45-afe8-b4280093c764` | Meilisearch master key (shared with Portainer stack) |

The `NEXTAUTH_URL` is hardcoded in the compose template as `https://keep.ketwork.in`.

## Initial Setup

1. Generate a NextAuth secret: `openssl rand -hex 32`
2. Store the secret in Bitwarden Secrets Manager (or update the existing entry)
3. Add the UUID to `ansible/inventory/group_vars/all/secrets.yaml` (vault-encrypted)
4. Run the setup playbook:
   ```bash
   cd ansible
   ansible-playbook -i inventory/hosts.yaml playbooks/vps/setup_karakeep.yaml
   ```
5. Deploy Caddy reverse proxy config:
   ```bash
   ansible-playbook -i inventory/hosts.yaml playbooks/caddy/caddy_reverse_proxy.yaml
   ```
6. Create an account at https://keep.ketwork.in (signups are disabled after first run)
7. Restore bookmarks from backup

## Updating

Run the update playbook to pull the latest image and recreate the container:

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/vps/update_karakeep.yaml
```

The playbook is idempotent -- running it when already up to date produces no changes.

## Data and Backups

Data is stored at `/opt/karakeep/data/` on the VPS, including the SQLite database and any uploaded assets.

## Search (Meilisearch)

Meilisearch runs on the homelab (docker_pve2) and is exposed at `https://meilisearch.ketwork.in` via VPS Caddy reverse proxy over Tailscale, with Cloudflare proxy enabled. The Karakeep container connects to it using `MEILI_ADDR` and `MEILI_MASTER_KEY`.

When the homelab is down, Karakeep continues to function for bookmarking but full-text search is unavailable. Indexing resumes when Meilisearch becomes reachable again.

The Meilisearch stack is managed via Portainer OpenTofu (`opentofu/portainer/stacks.tofu`). The same master key is used in both the Portainer stack and the Karakeep Ansible deployment.

## Disabled Features

This installation does not include:
- **Crawling/Screenshots** (no Chrome) -- website previews and JavaScript rendering are unavailable
- **AI Tagging** (no OpenAI/Ollama) -- automatic tagging is unavailable

To enable any of these features, add the relevant containers and environment variables per the [Karakeep documentation](https://docs.karakeep.app/configuration/environment-variables/).

## Important Notes

- Signups are disabled by default (`DISABLE_SIGNUPS=true`). To add users, temporarily remove the variable, redeploy, create accounts, then restore it.
- The container binds to 127.0.0.1:9721 only -- external access goes through Caddy with TLS.
- Docker was already installed on the VPS for previous services.

## References

- [Karakeep Documentation](https://docs.karakeep.app/)
- [Karakeep GitHub](https://github.com/karakeep-app/karakeep)
- [Minimal Install Guide](https://docs.karakeep.app/installation/minimal-install)
