# Bitwarden Secrets Manager access token
# This should be provided via environment variable TF_VAR_bws_access_token
# or stored in a .tfvars file (DO NOT commit to git)
variable "bws_access_token" {
  description = "Bitwarden Secrets Manager access token for authentication"
  type        = string
  sensitive   = true
}

# The Bitwarden secret ID that contains the Cloudflare API token
variable "cloudflare_api_token_secret_id" {
  description = "The Bitwarden secret ID for the Cloudflare API token"
  type        = string
  sensitive   = true
}