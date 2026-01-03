# Zerobyte

Zerobyte is a backup and snapshot solution that integrates with rclone for cloud storage. It uses FUSE to mount and manage backups efficiently, supporting multiple cloud providers including Google Drive and OneDrive.

## Deployment Details

- **URL**: https://zerobyte.example.com
- **Stack Location**: `opentofu/portainer/compose-files/zerobyte.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Cloudflare (internal, not proxied)
- **Reverse Proxy**: Homelab Caddy instance
- **Container Port**: 4096

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| zerobyte | ghcr.io/nicotsx/zerobyte:latest | Backup application |

## Special Requirements

This container requires elevated privileges for FUSE operations:

```yaml
cap_add:
  - SYS_ADMIN
  - SYS_PTRACE
devices:
  - /dev/fuse:/dev/fuse
security_opt:
  - apparmor:unconfined
  - seccomp:unconfined
```

## Required Bitwarden Secrets

Secrets are managed through the rclone configuration playbook:

### Google Drive
| Secret Variable | Description |
|-----------------|-------------|
| `gdrive_client_id_secret_id` | OAuth client ID from Google Cloud Console |
| `gdrive_client_secret_secret_id` | OAuth client secret |
| `gdrive_token_secret_id` | OAuth token (from `rclone authorize "drive"`) |

### OneDrive
| Secret Variable | Description |
|-----------------|-------------|
| `onedrive_client_id_secret_id` | Azure AD client ID |
| `onedrive_client_secret_secret_id` | Azure AD client secret |
| `onedrive_token_secret_id` | OAuth token (from `rclone authorize "onedrive"`) |

## USB Backup Drive

The docker_pve2 host has a USB backup drive for local backup storage:

| Setting | Value |
|---------|-------|
| Mount Point | `/mnt/backup` |
| Filesystem | ext4 |
| Label | backup |
| Ownership | dockeruser:dockeruser |

**Why ext4**: Universal compatibility for disaster recovery. The drive can be read on any Linux system without special tools, unlike ZFS which requires zfsutils-linux.

Configuration in `ansible/inventory/host_vars/docker_pve2.yaml`:
```yaml
backup_drive_uuid: "your-drive-uuid-here"
```

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/var/lib/zerobyte` | `/var/lib/zerobyte` | Application data |
| `/root/.config/rclone` | `/home/dockeruser/.config/rclone` | rclone config (read-only) |
| `/mnt/documents` | `${docker_documents_path}` | Source documents (read-only) |
| `/mnt/backup` | `/mnt/backup` | USB backup drive |

## Prerequisites

1. **rclone**: Must be installed and configured on docker_pve2
2. **FUSE**: Docker host must have `/dev/fuse` device
3. **Bitwarden secrets**: OAuth credentials for cloud providers
4. **USB drive**: Optional but recommended for local backups

## OAuth Credential Setup

### Google Drive

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project and enable Google Drive API
3. Create OAuth credentials (Desktop app type)
4. Generate token: `rclone authorize "drive" "CLIENT_ID" "CLIENT_SECRET"`
5. Store credentials in Bitwarden

### OneDrive

1. Go to [Azure Portal App Registrations](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps)
2. Create new registration with personal account support
3. Create client secret
4. Set manifest `signInAudience` to `AzureADandPersonalMicrosoftAccount`
5. Generate token: `rclone authorize "onedrive" "CLIENT_ID" "CLIENT_SECRET"`
6. Store credentials in Bitwarden

## Initial Setup

1. Configure OAuth credentials (see above)
2. Add secret UUIDs to Ansible vault
3. Configure rclone:
   ```bash
   ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/common/configure_rclone.yaml
   ```
4. Deploy the stack:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
5. Access web interface and configure backup jobs

## Important Notes

- Container has elevated capabilities for FUSE operations
- AppArmor and seccomp are disabled for this container
- OAuth tokens are automatically refreshed by rclone
- rclone configuration is mounted read-only
- USB backup drive provides offline disaster recovery option

## References

- [Zerobyte GitHub](https://github.com/nicotsx/zerobyte)
- [rclone Documentation](https://rclone.org/docs/)
- [Google Drive API Setup](https://rclone.org/drive/)
- [OneDrive Setup](https://rclone.org/onedrive/)
