#!/usr/env bash

# This is a catalog of steps run to setup Mealie.
# Not sure if it will be useable as a script or just copy/paste commands yet, depends on how lazy I am.

# tested running as root (sudo su -) on Ubuntu 22.04

# Setup pre-requisites if not already installed

# docker and docker compose
snap install docker
apt install docker-compose-plugin

# installing using SQLite for simplicity
mkdir -p /home/<username>/mealie && cd /home/<username>/mealie

# write the docker-compose file (may need to sudo su for this step, permissions ugh)
cat > docker-compose.yaml <<EOF
services:
  mealie:
    image: ghcr.io/mealie-recipes/mealie:v3.10.0 # 
    container_name: mealie
    restart: always
    ports:
        - "9925:9000" # 
    deploy:
      resources:
        limits:
          memory: 1000M # 
    volumes:
      - mealie-data:/app/data/
    environment:
      # Set Backend ENV Variables Here
      ALLOW_SIGNUP: "false"
      PUID: 1000
      PGID: 1000
      TZ: America/Anchorage
      BASE_URL: https://mealtime.8dot3.net:9925
      API_DOCS: "true"
      SMTP_HOST: smtp.gmail.com
      SMTP_FROM_NAME: Mealie
      SMTP_FROM_EMAIL: jtbyrum@gmail.com
      SMTP_USER: jtbyrum@gmail.com
      SMTP_PASSWORD: wuus grad scnv cfjz # app password

volumes:
  mealie-data:
EOF

# Start it
docker compose up -d

# end of line