# Home Assistant

Home Assistant is an open-source home automation platform that provides centralized control for smart home devices. It runs as a standalone VM on Proxmox, not as a Portainer-managed container.

## Deployment Details

- **URL**: https://homeassistant.example.com
- **Deployment Type**: Proxmox VM (not Portainer stack)
- **VM Location**: Proxmox homelab
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Port**: 8123 (internal)

## Architecture

Unlike other services in this repository, Home Assistant runs as a dedicated VM rather than a Docker container. This provides:
- Better hardware access for IoT integrations
- Isolation from container networking complexities
- Native add-on support via Home Assistant Supervisor

## Configuration Files

- **DNS**: `opentofu/cloudflare/dns_records.tofu`
- **Reverse Proxy**: `ansible/playbooks/caddy/caddy_records.yaml`

## Reverse Proxy Configuration

The reverse proxy includes custom headers to ensure Home Assistant receives original client information:

```yaml
- domain: homeassistant.example.com
  upstream: 192.168.1.100:8123
  extra_headers:
    - "Host {host}"
    - "X-Real-IP {remote_host}"
```

## Trusted Proxies Configuration

Home Assistant requires explicit configuration to accept requests through a reverse proxy. Add the following to `configuration.yaml`:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.1.50  # Replace with your reverse proxy IP
    - 172.16.0.0/12 # Optional: Docker network range
    - 127.0.0.1     # Optional: localhost
```

**Configuration Details**:
- `use_x_forwarded_for: true`: Enables trusting the X-Forwarded-For header
- `trusted_proxies`: IP addresses/subnets allowed to set client IP headers
- Without this configuration, Home Assistant rejects requests from the reverse proxy

## Initial Setup

1. Create VM in Proxmox (follow standard Home Assistant installation)
2. Install Home Assistant OS or Supervised
3. Configure `trusted_proxies` as shown above
4. Add DNS record in `opentofu/cloudflare/dns_records.tofu`
5. Add reverse proxy record with extra headers
6. Run Caddy playbook to update configuration

## Important Notes

- Console access via Proxmox web UI is available (unlike GPU-passthrough VMs)
- Home Assistant updates are managed through its own update mechanism
- Backups should be configured within Home Assistant
- The `trusted_proxies` configuration is essential for security

## References

- [Home Assistant Documentation](https://www.home-assistant.io/docs/)
- [Home Assistant Installation](https://www.home-assistant.io/installation/)
- [Reverse Proxy Configuration](https://www.home-assistant.io/integrations/http/#reverse-proxies)
