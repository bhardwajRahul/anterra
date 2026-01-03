# Gluetun VPN Stack

Gluetun is a VPN container that provides a secure tunnel for multiple services. All containers in this stack route their traffic through the Gluetun VPN connection using `network_mode: "service:gluetun"`.

## Deployment Details

- **Stack Location**: `opentofu/portainer/compose-files/gluetun.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Individual services have their own DNS records (see below)
- **VPN Provider**: AirVPN (WireGuard protocol)
- **VPN Server Location**: Netherlands

## Stack Components

| Container | Image | Port | DNS Record |
|-----------|-------|------|------------|
| gluetun | qmcgaw/gluetun:latest | - | - |
| qbittorrent | lscr.io/linuxserver/qbittorrent | 8585 | qbittorrent |
| jellyseerr | fallenbagel/jellyseerr | 5055 | seerr |
| prowlarr | lscr.io/linuxserver/prowlarr | 9696 | prowlarr |
| flaresolverr | ghcr.io/flaresolverr/flaresolverr | 8191 | flaresolverr |
| radarr | lscr.io/linuxserver/radarr | 7878 | radarr |
| sonarr | lscr.io/linuxserver/sonarr | 8989 | sonarr |
| bazarr | lscr.io/linuxserver/bazarr | 6767 | bazarr |
| librewolf | lscr.io/linuxserver/librewolf | 3080 | browser |
| profilarr | santiagosayshey/profilarr | 6868 | profilarr |

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `vpn_input_port` | AirVPN forwarded port (e.g., 53594) |
| `outbound_subnet` | Allowed outbound subnet for VPN firewall |
| `git_user_name` | Git username for Profilarr |
| `git_user_email` | Git email for Profilarr |
| `profilarr_pat` | Personal Access Token for Profilarr GitHub sync |

## AirVPN Certificate Setup

AirVPN uses certificate-based authentication. Certificates are deployed via Ansible:

1. Generate certificates from https://client.airvpn.org/
2. Download in OpenVPN 2.6 format, extract `client.crt` and `client.key`
3. Store both files in Bitwarden Secrets Manager
4. Add UUIDs to `ansible/inventory/group_vars/all/secrets.yaml`:
   - `gluetun_airvpn_crt_uuid`
   - `gluetun_airvpn_key_uuid`
5. Deploy certificates:
   ```bash
   ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/gluetun/configure_airvpn_certificates.yaml
   ```

## Initial Setup

1. Configure AirVPN certificates (see above)
2. Deploy the stack via OpenTofu:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
3. Verify VPN connection in Gluetun container logs
4. Configure individual services through their web interfaces

## Service Configuration Notes

### qBittorrent
- WebUI on port 8585
- Downloads to `${docker_downloads_path}`
- Uses AirVPN forwarded port for better connectivity

### Radarr / Sonarr
- Movie and TV show management
- Connect to qBittorrent for downloads
- Media stored in `${docker_media_path}/movies` and `${docker_media_path}/tv`

### Prowlarr
- Indexer manager for Radarr/Sonarr
- FlareSolverr integration for Cloudflare-protected sites

### Jellyseerr
- Media request management
- Accessible at `seerr.example.com`

### Bazarr
- Subtitle management for Radarr/Sonarr
- Automatic subtitle downloads

### Profilarr
- Quality profile synchronization
- Syncs profiles via GitHub repository

### LibreWolf
- Privacy-focused browser accessible via web
- Useful for accessing sites through VPN

## Important Notes

- All services share Gluetun's network stack
- If Gluetun stops, all tunneled services lose connectivity
- VPN connection verified via container logs: "VPN connected"
- Port forwarding through AirVPN improves torrent connectivity

## References

- [Gluetun Documentation](https://github.com/qdm12/gluetun-wiki)
- [AirVPN](https://airvpn.org/)
- [LinuxServer.io Containers](https://docs.linuxserver.io/)
