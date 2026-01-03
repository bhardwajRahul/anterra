# FileBrowser

FileBrowser is a web-based file management interface that provides a clean UI for browsing, uploading, downloading, and managing files on the server.

## Deployment Details

- **URL**: https://files.example.com
- **Stack Location**: `opentofu/portainer/compose-files/filebrowser.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Container Port**: 9200 (mapped to internal 80)

## Stack Components

- **filebrowser**: Main application container (filebrowser/filebrowser:latest)

## Required Bitwarden Secrets

None - this service uses only standard Docker environment variables.

## Initial Setup

1. Deploy the stack via OpenTofu:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
2. Configure DNS record in `opentofu/cloudflare/dns_records.tofu`
3. Add reverse proxy record in `ansible/playbooks/caddy/caddy_records.yaml`
4. Access the web interface and create your admin account
5. Default credentials are `admin`/`admin` - change immediately on first login

## Configuration

- **Served Directory**: `/srv` in container, mapped to `${docker_documents_path}/Filebrowser`
- **Database Location**: `${docker_config_path}/filebrowser` for persistent settings
- User/group permissions set via `user: "${docker_user_puid}:${docker_user_pgid}"`

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/srv` | `${docker_documents_path}/Filebrowser` | Files to serve |
| `/database` | `${docker_config_path}/filebrowser` | Application database |

## Important Notes

- Change default admin password immediately after first login
- The container runs as the dockeruser for proper file permissions
- Consider restricting access via authentication or VPN for sensitive files

## References

- [FileBrowser Documentation](https://filebrowser.org/)
- [FileBrowser GitHub](https://github.com/filebrowser/filebrowser)
