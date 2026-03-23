services:
  app:
    image: ghcr.io/iteratium/whoa-nihongo:latest
    container_name: whoa-nihongo
    restart: unless-stopped
    ports:
      - "9100:8000"
    volumes:
      - ${docker_data_path}/whoa-nihongo/data:/app/data
    environment:
      - SECRET_KEY=${secret_key}
      - DB_PATH=/app/data/nihongo.db
      - SESSION_EXPIRY_HOURS=24
    networks:
      - whoa-nihongo

networks:
  whoa-nihongo:
    name: whoa-nihongo
    driver: bridge
