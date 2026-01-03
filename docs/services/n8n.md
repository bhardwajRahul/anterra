# n8n

n8n is a workflow automation platform that allows you to connect various services and automate tasks. It provides a visual workflow builder with support for hundreds of integrations.

## Deployment Details

- **URL**: https://n8n.example.com
- **Stack Location**: `opentofu/portainer/compose-files/n8n.yaml.tpl`
- **Deployment Endpoint**: docker_pve
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Container Port**: 5678

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| n8n | docker.io/n8nio/n8n | Main workflow engine |
| n8n-postgres | postgres:16-alpine | PostgreSQL database |

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `n8n_db_password` | PostgreSQL database password |
| `n8n_encryption_key` | Encryption key for credentials storage |

**Generating Encryption Key**:
```bash
openssl rand -hex 32
```

## Initial Setup

1. Generate and store secrets in Bitwarden
2. Configure secret UUIDs in `opentofu/portainer/tofu.auto.tfvars`
3. Deploy the stack:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
4. Access https://n8n.example.com and create admin account
5. Configure integrations as needed

## Configuration

### Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `DB_TYPE` | postgresdb | Database backend |
| `N8N_HOST` | n8n.${domain_name} | Public hostname |
| `N8N_PROTOCOL` | https | Protocol for webhooks |
| `WEBHOOK_URL` | https://n8n.${domain_name}/ | Webhook base URL |
| `NODE_ENV` | production | Runtime environment |

### Version Control

Version is controlled via `n8n_version` variable in OpenTofu. Update and run `tofu apply` to upgrade.

## Volume Mounts

| Purpose | Location |
|---------|----------|
| n8n data | `${n8n_data_path}` |
| Database | `${n8n_db_data_location}` |
| Timezone | `/etc/localtime` (read-only) |

## Health Checks

Both containers include health checks:

**n8n**:
- Endpoint: `/healthz`
- Interval: 30s
- Start period: 60s (allows for startup)

**PostgreSQL**:
- Command: `pg_isready`
- Interval: 10s

## Database Dependency

The n8n container waits for PostgreSQL to be healthy before starting:
```yaml
depends_on:
  n8n-postgres:
    condition: service_healthy
```

## Important Notes

- Encryption key is critical - losing it means losing access to stored credentials
- Webhooks require the correct `WEBHOOK_URL` configuration
- Database backups recommended for workflow preservation
- Consider rate limiting for public webhook endpoints

## Common Use Cases

- API integrations and data synchronization
- Scheduled tasks and cron jobs
- Event-driven automation
- Data transformation pipelines
- Notification workflows

## References

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Integrations](https://n8n.io/integrations/)
- [n8n Community](https://community.n8n.io/)
