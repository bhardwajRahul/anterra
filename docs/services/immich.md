# Immich

Immich is a self-hosted photo and video management solution with AI-powered features including facial recognition, object detection, and smart search. It provides a Google Photos-like experience for personal media management.

## Deployment Details

- **URL**: https://immich.example.com
- **Stack Location**: `opentofu/portainer/compose-files/immich.yaml.tpl`
- **Deployment Endpoint**: docker_pve
- **DNS Management**: Cloudflare (DNS-only mode)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Container Port**: 2283

**Important**: Immich uses DNS-only mode (not proxied through Cloudflare CDN) to comply with Cloudflare's Terms of Service. Media-heavy services cannot use Cloudflare's proxy.

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| immich-server | ghcr.io/immich-app/immich-server | Main application server |
| immich-machine-learning | ghcr.io/immich-app/immich-machine-learning | AI/ML processing |
| redis | docker.io/valkey/valkey:8 | Caching layer |
| database | ghcr.io/immich-app/postgres:14-vectorchord | PostgreSQL with vector extensions |

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `immich_db_password` | PostgreSQL database password |

## Volume Mounts

| Purpose | Location Variable |
|---------|-------------------|
| Photo/Video uploads | `${immich_upload_location}` |
| Database data | `${immich_db_data_location}` |
| ML model cache | Docker volume `model-cache` |

## Initial Setup

1. Add the database password to Bitwarden Secrets Manager
2. Configure secret UUID in `opentofu/portainer/tofu.auto.tfvars`
3. Deploy the stack:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
4. Access https://immich.example.com and create admin account
5. Configure mobile app with server URL

## Configuration

Version is controlled via `immich_version` variable in OpenTofu. Update this variable and run `tofu apply` to upgrade.

**Watchtower Integration**: Immich containers are labeled with `com.centurylinklabs.watchtower.monitor-only=true` to prevent automatic updates. This ensures controlled upgrades through OpenTofu.

## Machine Learning Features

The ML container provides:
- Facial recognition and grouping
- Object and scene detection
- Smart search capabilities
- CLIP-based image search

ML models are cached in a persistent Docker volume for faster startup.

## Database Notes

Immich uses a specialized PostgreSQL image with:
- Vector extensions for AI feature storage
- Data checksums enabled for integrity
- 128MB shared memory allocation

## Important Notes

- DNS-only mode is required (no Cloudflare proxy) due to media content
- Database backups are critical - consider regular pg_dump
- ML processing can be CPU-intensive; monitor resource usage
- Mobile apps available for iOS and Android
- Version upgrades should be tested before production deployment

## References

- [Immich Documentation](https://immich.app/docs/overview/introduction)
- [Immich GitHub](https://github.com/immich-app/immich)
- [Mobile Apps](https://immich.app/docs/features/mobile-app)
