terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "~> 0.12"
    }
  }
}

# Use local value to extract the Bitwarden secret value
locals {
  cloudflare_api_token = data.bitwarden_secret.cloudflare_api_token.value
}

provider "cloudflare" {
  api_token = local.cloudflare_api_token
}