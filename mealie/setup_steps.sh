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

# copy/create the docker-compose.yml file into this folder ^

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