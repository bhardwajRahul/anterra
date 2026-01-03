# BentoPDF

BentoPDF is a client-side PDF manipulation tool that runs entirely in the browser. It provides a simple web interface for merging, splitting, rotating, and manipulating PDF files without uploading them to a server.

## Deployment Details

- **URL**: https://bento.example.com
- **Stack Location**: `opentofu/portainer/compose-files/bentopdf.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Container Port**: 9100 (mapped to internal 8080)

## Stack Components

- **bentopdf**: Main application container (bentopdf/bentopdf-simple:latest)

## Required Bitwarden Secrets

None - this service uses only standard Docker environment variables (PUID, PGID, TZ).

## Initial Setup

1. Deploy the stack via OpenTofu:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
2. Configure DNS record in `opentofu/cloudflare/dns_records.tofu`
3. Add reverse proxy record in `ansible/playbooks/caddy/caddy_records.yaml`
4. Run the Caddy playbook to update reverse proxy configuration

## Configuration

The service runs with minimal configuration:
- `PUID`/`PGID`: Docker user/group IDs for file permissions
- `TZ`: Timezone setting

## Important Notes

- All PDF processing happens client-side in the browser
- No files are uploaded to the server, ensuring privacy
- The container serves only the static web application

## References

- [BentoPDF GitHub](https://github.com/nicholasgriffintn/BentoPDF)
