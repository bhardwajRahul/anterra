# Watchtower

Watchtower automatically updates Docker containers when new images are available. It monitors running containers and pulls new images on a configurable schedule.

## Deployment Details

- **Stack Location**: `opentofu/portainer/compose-files/watchtower.yaml.tpl`
- **Deployment Endpoints**: Both docker_pve and docker_pve2
- **DNS Management**: Not required (background service)
- **Network Mode**: Host

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| watchtower | nickfedor/watchtower | Container auto-updater |

**Note**: Uses the `nickfedor/watchtower` fork, which is actively maintained and compatible with Docker 28+. The original `containrrr/watchtower` is no longer maintained.

## Required Bitwarden Secrets

None - this service uses only standard Docker environment variables.

## Deployment Schedule

Watchtower runs on staggered schedules to avoid simultaneous updates:

| Endpoint | Schedule | Time |
|----------|----------|------|
| docker_pve2 | `0 30 1 * * *` | 1:30 AM |
| docker_pve | `0 30 3 * * *` | 3:30 AM |

Schedule format is cron with 6 fields (seconds included).

## Configuration

| Variable | Value | Description |
|----------|-------|-------------|
| `WATCHTOWER_CLEANUP` | true | Remove old images after update |
| `WATCHTOWER_INCLUDE_STOPPED` | true | Check stopped containers too |
| `WATCHTOWER_REVIVE_STOPPED` | false | Don't start stopped containers |
| `WATCHTOWER_SCHEDULE` | cron expression | Update check schedule |

## Initial Setup

1. Deploy via OpenTofu (deployed automatically with other stacks):
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
2. Verify container is running in Portainer
3. Check logs for update activity

## Monitor-Only Mode

Some containers are configured to be monitored but not auto-updated. This is done via container labels:

```yaml
labels:
  - "com.centurylinklabs.watchtower.monitor-only=true"
```

Currently, Immich containers use monitor-only mode to ensure controlled upgrades through OpenTofu.

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker API access |

## Important Notes

- Host network mode is used for Docker socket access
- Staggered schedules prevent resource contention
- Monitor-only labels allow selective update control
- Old images are automatically cleaned up
- Check container logs for update history

## Excluding Containers

To exclude a container from Watchtower updates:

```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=false"
```

Or use monitor-only for notifications without updates:
```yaml
labels:
  - "com.centurylinklabs.watchtower.monitor-only=true"
```

## References

- [Watchtower Documentation](https://containrrr.dev/watchtower/)
- [nickfedor/watchtower Fork](https://github.com/nickfedor/watchtower)
- [Container Labels](https://containrrr.dev/watchtower/arguments/#filter_by_label)
