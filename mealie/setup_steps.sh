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
      - /home/<username>/mealie/mealie-data:/app/data/
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
      TLS_CERTIFICATE_PATH: /app/data/cert.pem
      TLS_PRIVATE_KEY_PATH: /app/data/private_key_clean.pem

volumes:
  mealie-data:
EOF

# create the data directory that will mount to /app/data
mkdir mealie-data && cd mealie-data

# place TLS cert and key files in this directory, either by copy or using an editor to copy/paste the certificate into a file.
# I used VI to create cert.pem and private_key.pem files using the exported cert and key from AWS.
# After saving them, I used OpenSSL to remove the passphrase from the private key:
openssl rsa -in private_key.pem -out private_key_clean.pem

# Start Mealie
cd /home/<username>/mealie
docker compose up -d

# end of line