# Posterizarr

Automated poster maker for Plex and Jellyfin that creates custom posters with ratings, overlays, and metadata from TMDB, TVDB, and Fanart.tv.

## Deployment Details

- **URL**: https://posterizarr.ketwork.in (internal only)
- **Stack Location**: `opentofu/portainer/compose-files/posterizarr.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Cloudflare (DNS-only, internal access)
- **Reverse Proxy**: Homelab Caddy (rpi)
- **Container Port**: 8219
- **Web UI**: Enabled

## Stack Components

- **posterizarr**: Main application with web interface
  - Image: `ghcr.io/fscorrupt/posterizarr:latest`
  - Volumes:
    - `/config` - Configuration and UILogs
    - `/assets` - Generated posters
    - `/assetsbackup` - Poster backups
    - `/manualassets` - Manually uploaded assets

## Directory Structure

The setup playbook (`setup_docker_portainer_server.yaml`) automatically creates required directories:

```
/mnt/docker/config/posterizarr/
├── UILogs/           # Web interface logs
├── Overlayfiles/     # Custom overlay images and fonts
├── assets/           # Generated poster assets
├── assetsbackup/     # Backup of generated posters
├── manualassets/     # Manually uploaded custom posters
└── config.json       # Main configuration file (created on first run)
```

## Required API Keys

Posterizarr requires API keys from multiple services. These are configured through the Web UI (not via environment variables):

1. **TMDB API Read Access Token**
   - Get from: https://www.themoviedb.org/settings/api
   - Use the **Read Access Token** (long token, NOT API Key v3)

2. **Fanart Personal API Key**
   - Get from: https://fanart.tv/get-an-api-key/
   - Personal API key for accessing artwork

3. **TVDB API Key**
   - Get from: https://thetvdb.com/dashboard/account/apikeys
   - Use **Project API Key** (NOT Legacy API Key)

4. **Plex Token**
   - Get from: https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
   - Authentication token for Plex server access

5. **Jellyfin API Key**
   - Get from: Jellyfin Dashboard → Settings → API Keys
   - Create new API key for Posterizarr

## Deployment

Deploy via OpenTofu:

```bash
cd opentofu/portainer
tofu apply
```

The stack will be deployed to docker_pve2. On first run, the container creates default configuration files.

## Initial Setup

### 1. Access Web Interface

Navigate to https://posterizarr.ketwork.in after deployment.

### 2. Configure API Keys

In the Posterizarr web interface:

1. Go to **Settings** or **Configuration**
2. Add all required API keys (listed above)
3. Save configuration

### 3. Configure Media Servers

Add both Plex and Jellyfin:

**Plex Configuration:**
- Server URL: `http://mediacenter:32400` (or your Plex server IP)
- Plex Token: (from API keys section)

**Jellyfin Configuration:**
- Server URL: `http://mediacenter:8096` (or your Jellyfin server IP)
- API Key: (from API keys section)

### 4. Configure Poster Settings

Customize poster generation:
- **Poster Dimensions**: Default 2000x3000 (4:6 ratio)
- **Overlay Style**: Choose from available templates
- **Text Formatting**: Font, color, size, positioning
- **Rating Sources**: TMDB, IMDB, Rotten Tomatoes
- **Language**: Preferred language for metadata

### 5. Test Poster Generation

1. Select a movie or TV show from your library
2. Click "Generate Poster"
3. Review generated poster in the preview
4. Apply to Plex/Jellyfin if satisfied

## Asset Paths

Posterizarr uses several directories for different asset types:

| Directory | Purpose | When to Use |
|-----------|---------|-------------|
| `/assets` | Auto-generated posters | Default output location |
| `/assetsbackup` | Backup copies | Automatic backups of generated posters |
| `/manualassets` | Custom uploads | Upload your own poster images |
| `/config/Overlayfiles` | Overlay templates | Custom overlays and fonts |

## Configuration File

The main configuration is stored in `/config/config.json`. This file is created on first run and contains:

- API keys and tokens (stored in `ApiPart` section)
- Server URLs for Plex and Jellyfin
- Poster generation preferences
- Overlay and text formatting settings

**Note**: Configuration is managed through the Web UI. Manual editing is possible but not recommended.

## Automation

Posterizarr supports automated poster generation:

- **RUN_TIME**: Set to `disabled` by default (manual mode)
- **Scheduled Runs**: Configure via cron (Linux) or Task Scheduler (Windows)
- **Webhook Triggers**: Can be triggered via API calls

For automated operation, update the environment variable `RUN_TIME` in the compose template.

## Integration with Media Servers

### Plex Integration

- Reads library metadata from Plex
- Generates posters based on Plex library structure
- Uploads posters directly to Plex
- Updates poster automatically without manual intervention

### Jellyfin Integration

- Reads library metadata from Jellyfin
- Generates posters based on Jellyfin library structure
- Uploads posters directly to Jellyfin
- Supports both movies and TV series

## Important Notes

- **No Radarr/Sonarr Required**: Posterizarr works directly with Plex and Jellyfin, no need for *arr integration initially
- **Storage Location**: All posters stored in Docker config volume (`/mnt/docker/config/posterizarr`)
- **Backup Strategy**: Posterizarr automatically backs up generated posters to `/assetsbackup`
- **Web UI Access**: Internal only (homelab network), not exposed externally
- **Directory Pre-creation**: Setup playbook creates all required directories automatically
- **Idempotent Setup**: Rerunning the setup playbook is safe and won't affect existing configuration

## Troubleshooting

### Container Won't Start - Missing Directories

If the container fails with `FileNotFoundError` for UILogs or Overlayfiles:

```bash
# Rerun the setup playbook to create directories
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/proxmox/setup_docker_portainer_server.yaml

# Or manually create if needed
ssh dockeruser@docker_pve2
sudo mkdir -p /mnt/docker/config/posterizarr/{UILogs,Overlayfiles}
sudo chown -R dockeruser:dockeruser /mnt/docker/config/posterizarr
```

### API Keys Not Saving

Ensure you're using the correct API key formats:
- **TMDB**: Use Read Access Token (long token), not API Key v3
- **TVDB**: Use Project API Key, not Legacy API Key
- **Plex**: Full token string from Plex settings

### Cannot Connect to Media Servers

Verify network connectivity:
```bash
# Test from docker_pve2
docker exec posterizarr curl http://mediacenter:32400
docker exec posterizarr curl http://mediacenter:8096
```

Ensure Plex and Jellyfin allow connections from the Docker network.

## References

- [Posterizarr Official Documentation](https://fscorrupt.github.io/posterizarr/)
- [Posterizarr GitHub Repository](https://github.com/fscorrupt/posterizarr)
- [Posterizarr Walkthrough](https://fscorrupt.github.io/posterizarr/walkthrough/)
- [Docker Installation Guide](https://fscorrupt.github.io/posterizarr/installation/)
