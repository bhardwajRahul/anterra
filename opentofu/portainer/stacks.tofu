# Watchtower stack - automatically updates Docker containers
resource "portainer_stack" "watchtower" {
  name              = "watchtower"
  deployment_type  = "standalone"
  method            = "string"
  endpoint_id      = var.portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/watchtower.yaml.tpl", {
    docker_user_puid   = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid   = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone    = var.docker_timezone
    docker_config_path = var.docker_config_path
  })
}

# Gluetun stack - VPN container with multiple services tunneled through it
resource "portainer_stack" "gluetun" {
  name              = "gluetun"
  deployment_type  = "standalone"
  method            = "string"
  endpoint_id      = var.portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/gluetun.yaml.tpl", {
    docker_user_puid     = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid     = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone      = var.docker_timezone
    docker_config_path   = var.docker_config_path
    docker_data_path     = var.docker_data_path
    vpn_input_port       = data.bitwarden_secret.vpn_input_port.value
    outbound_subnet      = data.bitwarden_secret.outbound_subnet.value
  })
}
