provider "bitwarden" {
  access_token = var.bws_access_token

  experimental {
    embedded_client = true
  }
}

data "bitwarden_secret" "cloudflare_api_token" {
  id = var.cloudflare_api_token_secret_id
}
