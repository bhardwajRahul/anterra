services:
  papra:
    image: ghcr.io/papra-hq/papra:latest
    container_name: papra
    restart: unless-stopped
    environment:
      - TZ=${docker_timezone}
      - APP_BASE_URL=https://papra.${domain_name}
    volumes:
      - papra_data:/app/app-data
    ports:
      - "1221:1221"
    networks:
      - papra

volumes:
  papra_data:
    name: papra_data

networks:
  papra:
    name: papra
    driver: bridge
