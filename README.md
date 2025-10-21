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
│   │   ├── group_vars/all/secrets.yaml   # Encrypted group variables
│   │   └── host_vars/                    # Host-specific variables
│   ├── playbooks/                        # Ansible playbooks
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