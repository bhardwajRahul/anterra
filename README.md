# Anterra

Infrastructure as Code (IaC) repository for managing and provisioning infrastructure using Ansible and OpenTofu.

## Overview

Anterra provides a centralized platform for:
- Configuration management and automation via Ansible
- Infrastructure provisioning for Cloudflare and Portainer via OpenTofu
- Secure secrets management using Ansible Vault

## Project Structure

```
anterra/
├── ansible/                              # Ansible configuration management
│   ├── ansible.cfg                       # Ansible configuration
│   ├── inventory/                        # Host and group definitions
│   │   ├── hosts.yaml                    # Inventory of target hosts
│   │   ├── group_vars/all/secrets.yaml   # Encrypted group variables (Ansible Vault)
│   │   └── host_vars/                    # Host-specific variables
│   ├── playbooks/                        # Ansible playbooks
│   │   └── common/                       # Common playbooks for all hosts
│   │       └── install_tailscale.yaml    # Tailscale installation and configuration
│   └── vault/                            # Ansible vault configuration
│       └── .vault_password               # Vault password file (gitignored)
└── opentofu/                             # OpenTofu infrastructure as code
    ├── cloudflare/                       # Cloudflare infrastructure
    └── portainer/                        # Portainer container orchestration
```

## Prerequisites

The following dependencies are required for this setup:

- **git** - Version control
- **tree** - Directory structure visualization
- **btop** - System resource monitoring
- **npm** - Node package manager (used for installing Claude Code)
- **pipx** - Python application installer (for installing Ansible in isolated environments)
- **ansible** - Configuration management (installed via pipx without sudo)
- **opentofu** - Infrastructure provisioning (open-source Terraform alternative)
- Access credentials for target infrastructure (Cloudflare, Portainer, etc.)

## Getting Started

### Ansible Configuration

1. Configure target hosts in `ansible/inventory/hosts.yaml`
2. Set vault password in `ansible/vault/.vault_password`
3. Create playbooks in `ansible/playbooks/`
4. Store secrets in `ansible/inventory/group_vars/all/secrets.yaml` (encrypted with Ansible Vault)

### Running Ansible Playbooks

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/<playbook-name>.yaml
```

### Available Playbooks

#### Tailscale Installation and Configuration

**File**: `ansible/playbooks/common/install_tailscale.yaml`

Installs and configures Tailscale with support for:
- Automatic updates
- Subnet routing with automatic IP forwarding
- Exit node functionality
- UDP GRO forwarding optimization for improved performance on international connections

**Prerequisites**:

Before running the playbook, generate an authentication key:
1. Visit: https://login.tailscale.com/admin/settings/keys
2. Create a new authentication key
3. Add it to your vault secrets:
   ```bash
   cd ansible
   ansible-vault edit inventory/group_vars/all/secrets.yaml
   ```
4. Add the key: `tailscale_auth_key: "tskey-your-key-here"`
5. (Optional) Add subnet routes: `tailscale_subnet_routes: "192.0.2.0/24,198.51.100.0/24"`

**Basic Usage**:

Run the playbook with default configuration:
```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/common/install_tailscale.yaml
```

Disable features as needed:
```bash
# Disable subnet router
ansible-playbook -i inventory/hosts.yaml playbooks/common/install_tailscale.yaml \
  -e "enable_subnet_router=false"

# Disable exit node
ansible-playbook -i inventory/hosts.yaml playbooks/common/install_tailscale.yaml \
  -e "enable_exit_node=false"
```

**Post-Playbook Setup**:

After running the playbook, complete these steps in the Tailscale admin console:

1. Visit: https://login.tailscale.com/admin/machines
2. Find your device and open its settings
3. Navigate to "Route settings"
4. Approve the advertised subnet routes
5. Approve the exit node setting

**For Headless/Unattended Devices**:
- In device settings, toggle OFF "Key expiry" to prevent authentication failures
- This is recommended for servers and Raspberry Pi running Tailscale unattended

**Performance Optimization**:
The playbook automatically optimizes UDP GRO forwarding for improved throughput on exit node and subnet router traffic, especially beneficial for international connections.

**Notes**:
- If running locally on the device, you may experience brief network disconnection - this is normal
- Auth keys expire separately from node keys - renew them when needed
- See detailed documentation at: [Tailscale Performance Best Practices](https://tailscale.com/kb/1320/performance-best-practices)

**Reference**: [Tailscale Documentation](https://tailscale.com/)

### OpenTofu Configuration

#### Cloudflare
```bash
cd opentofu/cloudflare
tofu init
tofu plan
tofu apply
```

#### Portainer
```bash
cd opentofu/portainer
tofu init
tofu plan
tofu apply
```

## Security

- Ansible Vault is configured for managing sensitive data
- Vault password file is excluded from version control via `.gitignore`
- Never commit unencrypted secrets to the repository

## Contributing

1. Create feature branches for new infrastructure configurations
2. Test playbooks and OpenTofu plans before applying
3. Document any new infrastructure components
4. Ensure secrets are properly encrypted before committing

## License

This repository is for internal infrastructure management.