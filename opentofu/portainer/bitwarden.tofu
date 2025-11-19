provider "bitwarden" {
  access_token = var.bws_access_token

  experimental {
    embedded_client = true
  }
}

# Fetch Portainer API key from Bitwarden Secrets Manager
data "bitwarden_secret" "portainer_api_key" {
  id = var.portainer_api_key_secret_id
}

# Fetch Gluetun VPN input port from Bitwarden Secrets Manager
data "bitwarden_secret" "vpn_input_port" {
  id = var.vpn_input_port_secret_id
}

# Fetch Gluetun outbound subnet from Bitwarden Secrets Manager
data "bitwarden_secret" "outbound_subnet" {
  id = var.outbound_subnet_secret_id
}

# Fetch Docker user PUID from Bitwarden Secrets Manager
data "bitwarden_secret" "docker_user_puid" {
  id = var.docker_user_puid_secret_id
}

# Fetch Docker user PGID from Bitwarden Secrets Manager
data "bitwarden_secret" "docker_user_pgid" {
  id = var.docker_user_pgid_secret_id
}
