# Karakeep

Karakeep is a self-hosted bookmark manager with AI-powered automatic tagging and full-text search capabilities. It uses OpenAI for intelligent categorization and Meilisearch for fast search.

## Deployment Details

- **URL**: https://keep.example.com
- **Stack Location**: `opentofu/portainer/compose-files/karakeep.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Container Port**: 3000

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| web | ghcr.io/karakeep-app/karakeep | Main application |
| chrome | gcr.io/zenika-hub/alpine-chrome | Headless Chrome for web scraping |
| meilisearch | getmeili/meilisearch | Full-text search engine |

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `karakeep_nextauth_url_secret_id` | Application URL (https://keep.example.com) |
| `karakeep_nextauth_secret_id` | NextAuth session encryption key |
| `karakeep_meilisearch_key_secret_id` | Meilisearch master key |
| `karakeep_openai_api_key_secret_id` | OpenAI API key for AI tagging (optional) |

**Generating Keys**:
```bash
# NextAuth secret
openssl rand -base64 36

# Meilisearch master key
openssl rand -base64 36
```

## Initial Setup

1. Generate and store secrets in Bitwarden
2. Configure secret UUIDs in `opentofu/portainer/tofu.auto.tfvars`
3. Deploy the stack:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
4. Visit https://keep.example.com and create your admin account
5. After creating your account, signups are automatically disabled

## AI Configuration

The stack is configured with OpenAI integration for automatic tagging:

| Setting | Value | Description |
|---------|-------|-------------|
| `INFERENCE_TEXT_MODEL` | gpt-4o-mini | Model for text analysis |
| `INFERENCE_IMAGE_MODEL` | gpt-4o-mini | Model for image analysis |

**Alternative Models**:
- Any OpenAI model: gpt-4, gpt-4-turbo, gpt-4o, gpt-3.5-turbo
- For local AI: Replace `OPENAI_API_KEY` with `OLLAMA_BASE_URL` pointing to your Ollama instance

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/data` | `${docker_data_path}/karakeep` | Application data |
| `/meili_data` | `${docker_data_path}/karakeep-meilisearch` | Search index |

## Security Configuration

The stack includes security measures:
- `DISABLE_SIGNUPS=true`: Prevents unauthorized account creation
- Only remove temporarily if creating additional accounts, then re-enable

To temporarily enable signups:
1. Remove `DISABLE_SIGNUPS` from compose template
2. Run `tofu apply`
3. Create accounts
4. Restore `DISABLE_SIGNUPS=true`
5. Run `tofu apply` again

## Important Notes

- Chrome container is required for web page scraping and preview generation
- Meilisearch provides fast, typo-tolerant search
- OpenAI API key is optional but recommended for AI features
- All data is stored locally; no external sync

## References

- [Karakeep GitHub](https://github.com/karakeep-app/karakeep)
- [Meilisearch Documentation](https://www.meilisearch.com/docs)
- [OpenAI API](https://platform.openai.com/docs)
