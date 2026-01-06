# Jellyfin

Open-source media streaming server with support for movies, TV shows, music, and live TV. Configured with Intel Quick Sync hardware transcoding for efficient media processing.

## Deployment Details

- **URL**: https://jellyfin.ketwork.in (external), http://mediacenter:8096 (internal)
- **Deployment**: Proxmox VM (mediacenter)
- **Playbook**: `ansible/playbooks/proxmox/setup_media_server.yaml`
- **DNS Management**: Cloudflare (DNS-only mode - not proxied due to ToS restrictions on media streaming)
- **Reverse Proxy**: VPS Caddy
- **Container Port**: 8096

## Hardware Configuration

### Intel Quick Sync Hardware Transcoding

Jellyfin is configured with Intel Quick Sync Video (QSV) hardware acceleration for efficient media transcoding:

- **GPU**: Intel integrated graphics passed through from Proxmox host
- **Driver Groups**: `jellyfin` user added to `render` and `video` groups
- **Performance**: Enables multiple simultaneous transcode streams with low CPU usage
- **Supported Codecs**: H.264, H.265/HEVC, VP9, AV1 (depending on hardware generation)

### Proxmox PCI Passthrough

The mediacenter VM is configured with GPU passthrough for hardware transcoding:

```
hostpci0: 0000:00:02.0,pcie=1,rombar=0
cpu: host,hidden=1,flags=+pcid
vga: none
```

See the main README's "Proxmox VM Setup for Hardware Passthrough" section for details.

## Storage Configuration

### SMB Mount Dependencies

Jellyfin is protected from starting when network storage is unavailable:

- **Media Mount**: `/mnt/media` (movies, TV shows, music)
- **Downloads Mount**: `/mnt/downloads` (for recently added content)
- **Protection**: Systemd mount dependencies prevent Jellyfin from starting if SMB shares are down
- **Behavior**: Jellyfin service automatically stops if mounts become unavailable during runtime

This prevents Jellyfin from accessing wrong directories and corrupting metadata when network storage is offline.

## Installation

Jellyfin is installed alongside Plex on the mediacenter VM:

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/proxmox/setup_media_server.yaml
```

The playbook:
1. Installs Jellyfin from official repository
2. Configures Intel GPU drivers and hardware access
3. Sets up SMB mounts with systemd dependencies
4. Configures firewall rules (port 8096)
5. Enables and starts Jellyfin service

## Initial Setup

After installation, complete the initial setup wizard:

1. Access Jellyfin at http://mediacenter:8096
2. Create admin account
3. Add media libraries:
   - Movies: `/mnt/media/movies`
   - TV Shows: `/mnt/media/tv`
   - Music: `/mnt/media/music`
4. Enable hardware transcoding:
   - Dashboard → Playback → Transcoding
   - Hardware acceleration: Intel QuickSync (QSV)
   - Enable hardware encoding for all supported codecs
5. Configure networking:
   - Dashboard → Networking
   - Public HTTPS port: 443 (handled by reverse proxy)
   - Ensure "Allow remote connections to this server" is enabled

## DNS and Reverse Proxy Configuration

### Cloudflare DNS (DNS-only mode)

DNS record configured in `opentofu/cloudflare/dns_records.tofu`:

```hcl
"jellyfin" = {
  content = local.vps_reverse_proxy_ip
  # DNS-only mode (proxied = false) to comply with Cloudflare ToS
  # Media streaming services cannot use Cloudflare proxy
}
```

**Why DNS-only?** Cloudflare's Terms of Service prohibit proxying video streaming traffic through their free CDN. DNS-only mode provides DNS resolution without routing media through Cloudflare.

### Caddy Reverse Proxy

Reverse proxy configured in `ansible/playbooks/caddy/caddy_records.yaml`:

```yaml
- domain: jellyfin.{{ domain_name }}
  upstream: "http://{{ mediacenter_ip }}:8096"
```

Caddy automatically provides:
- HTTPS via Let's Encrypt
- HTTP/2 support
- Automatic certificate renewal

## Comparison with Plex

Both Plex and Jellyfin run on the same mediacenter VM with identical hardware transcoding support:

| Feature | Jellyfin | Plex |
|---------|----------|------|
| License | Open source (GPL) | Proprietary (freemium) |
| Hardware Transcoding | ✓ Intel Quick Sync | ✓ Intel Quick Sync |
| Client Apps | Open source | Official (better app support) |
| Live TV/DVR | ✓ Free | ✓ Plex Pass required |
| Metadata | The Movie Database | Plex's database (better quality) |
| Mobile Sync | Basic | Advanced (Plex Pass) |
| User Management | Self-hosted only | Plex accounts + managed users |

## Important Notes

- **GPU Passthrough Required**: Hardware transcoding requires PCI passthrough configuration
- **SMB Mount Dependencies**: Service will not start if network storage is unavailable
- **No Cloudflare Proxy**: Must use DNS-only mode to comply with Cloudflare ToS
- **Firewall**: Port 8096 is opened for Jellyfin access
- **Coexistence with Plex**: Both services share the same media libraries and hardware

## Troubleshooting

### Hardware Transcoding Not Working

Verify hardware access:
```bash
# SSH into mediacenter
ssh mediauser@mediacenter

# Check if Jellyfin user can access render device
groups jellyfin
# Should show: jellyfin video render

# Verify GPU is available
vainfo
# Should show available encoding/decoding profiles
```

### Service Won't Start

Check SMB mount status:
```bash
systemctl status mnt-media.mount
systemctl status mnt-downloads.mount
systemctl status jellyfin
```

If mounts are failing, see main README's SMB Mount Protection section.

## References

- [Jellyfin Official Documentation](https://jellyfin.org/docs/)
- [Jellyfin Hardware Acceleration](https://jellyfin.org/docs/general/administration/hardware-acceleration/)
- [Intel Quick Sync on Linux](https://jellyfin.org/docs/general/administration/hardware-acceleration/intel)
