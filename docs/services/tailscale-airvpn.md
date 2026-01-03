# Tailscale + AirVPN Exit Node

This stack combines Gluetun VPN with Tailscale to create a secure exit node. Traffic from Tailscale clients using this exit node is routed through AirVPN, providing an additional layer of privacy.

## Deployment Details

- **Stack Location**: `opentofu/portainer/compose-files/tailscale-airvpn.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Not required (accessed via Tailscale network)
- **Tailscale Hostname**: tailscale-airvpn

## Architecture

```
Tailscale Client -> Tailscale Exit Node -> Gluetun VPN -> AirVPN -> Internet
```

- **Gluetun Container**: Handles VPN connectivity via AirVPN (WireGuard protocol)
- **Tailscale Container**: Runs in `network_mode: "service:gluetun"` to route all traffic through the VPN

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| gluetun | qmcgaw/gluetun:latest | VPN tunnel to AirVPN |
| tailscale | tailscale/tailscale:latest | Exit node for Tailscale network |

Container names use `-ts` suffix to distinguish from the regular gluetun stack:
- `gluetun-ts`
- `tailscale-ts`

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `tailscale_auth_key_uuid` | Tailscale authentication key |

## AirVPN Certificate Setup

This stack uses separate AirVPN certificates from the regular gluetun stack:

1. Generate certificates from https://client.airvpn.org/
2. Download in OpenVPN 2.6 format, extract `client.crt` and `client.key`
3. Store both files in Bitwarden Secrets Manager
4. Add UUIDs to `ansible/inventory/group_vars/all/secrets.yaml`:
   ```yaml
   tailscale_airvpn_crt_uuid: "your-uuid-here"
   tailscale_airvpn_key_uuid: "your-uuid-here"
   ```
5. Deploy certificates:
   ```bash
   ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/gluetun/configure_airvpn_certificates.yaml
   ```

## Initial Setup

1. Generate separate AirVPN certificates for this stack
2. Add certificate UUIDs to Ansible vault secrets
3. Create a reusable Tailscale auth key:
   - Go to Tailscale admin console > Settings > Keys
   - Create a reusable auth key
   - Store in Bitwarden and note the UUID
4. Update `opentofu/portainer/tofu.auto.tfvars`:
   ```hcl
   tailscale_auth_key_uuid = "your-bitwarden-uuid"
   ```
5. Deploy AirVPN certificates:
   ```bash
   ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/gluetun/configure_airvpn_certificates.yaml
   ```
6. Deploy the stack:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
7. In Portainer, restart the `gluetun-ts` container
8. Verify VPN connection in container logs ("VPN connected")
9. In Tailscale admin console:
   - Verify the exit node is visible and online
   - Enable it as an exit node (requires manual approval)
10. On Tailscale clients, select this exit node in Settings

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/gluetun` | `${docker_config_path}/tailscale-airvpn/gluetun` | VPN configuration |
| `/var/lib/tailscale` | `${docker_config_path}/tailscale-airvpn/tailscale` | Tailscale state |

## Tailscale Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| `TS_HOSTNAME` | tailscale-airvpn | Device name in Tailscale |
| `TS_EXTRA_ARGS` | --advertise-exit-node | Advertise as exit node |
| `TS_STATE_DIR` | /var/lib/tailscale | Persistent state location |

## Important Notes

- Uses **separate AirVPN certificates** from the regular gluetun stack
- Each stack can use a different AirVPN account if needed
- Exit node must be manually enabled in Tailscale admin console
- Tailscale auth keys expire separately from node keys
- If auth key expires, generate a new one and redeploy
- Container restart may be needed after certificate updates

## Troubleshooting

**Exit node not appearing in Tailscale**:
1. Check gluetun-ts logs for "VPN connected"
2. Check tailscale-ts logs for authentication errors
3. Verify auth key is valid and not expired

**VPN not connecting**:
1. Verify AirVPN certificates are deployed correctly
2. Check certificate paths in gluetun config directory
3. Review gluetun-ts container logs

## References

- [Tailscale Exit Nodes](https://tailscale.com/kb/1103/exit-nodes/)
- [Gluetun Documentation](https://github.com/qdm12/gluetun-wiki)
- [AirVPN](https://airvpn.org/)
- [Architecture Guide](https://fathi.me/unlock-secure-freedom-route-all-traffic-through-tailscale-gluetun/)
