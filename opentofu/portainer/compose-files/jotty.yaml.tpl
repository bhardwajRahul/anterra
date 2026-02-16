services:
  jotty:
    image: ghcr.io/fccview/jotty:latest
    container_name: jotty
    restart: unless-stopped
    user: "${docker_user_puid}:${docker_user_pgid}"
    ports:
      - "1122:3000"
    volumes:
      - ${docker_data_path}/jotty/data:/app/data
      - ${docker_data_path}/jotty/config:/app/config
      - ${docker_data_path}/jotty/cache:/app/.next/cache
    environment:
      - NODE_ENV=production
      - TZ=${docker_timezone}
      - SSO_MODE=oidc
      - OIDC_ISSUER=${jotty_oidc_issuer}
      - OIDC_CLIENT_ID=${jotty_oidc_client_id}
      - OIDC_CLIENT_SECRET=${jotty_oidc_client_secret}
      - APP_URL=https://jotty.${domain_name}
      - INTERNAL_API_URL=http://localhost:3000
      - SSO_FALLBACK_LOCAL=no
    networks:
      - jotty

networks:
  jotty:
    name: jotty
    driver: bridge
