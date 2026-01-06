services:
  posterizarr:
    image: ghcr.io/fscorrupt/posterizarr:latest
    container_name: posterizarr
    restart: unless-stopped
    user: "${docker_user_puid}:${docker_user_pgid}"
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
      - TERM=xterm
      - RUN_TIME=disabled
      - APP_PORT=8219
      - DISABLE_UI=false
    ports:
      - "8219:8219"
    volumes:
      - ${docker_config_path}/posterizarr:/config:rw
      - ${docker_config_path}/posterizarr/assets:/assets:rw
      - ${docker_config_path}/posterizarr/assetsbackup:/assetsbackup:rw
      - ${docker_config_path}/posterizarr/manualassets:/manualassets:rw
    networks:
      - posterizarr

networks:
  posterizarr:
    name: posterizarr
    driver: bridge
