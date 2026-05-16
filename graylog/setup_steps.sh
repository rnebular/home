#!/usr/env bash

# This is a catalog of steps run to setup Mealie.
# Not sure if it will be useable as a script or just copy/paste commands yet, depends on how lazy I am.

# tested running as root (sudo su -) on Ubuntu 22.04

# Setup pre-requisites if not already installed

# docker and docker compose
snap install docker
apt install docker-compose-plugin

# generate the password secret and hash to go in the .env file
# GRAYLOG_PASSWORD_SECRET:
password_secret=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-96};echo;)

# GRAYLOG_ROOT_PASSWORD_SHA2:
root_password_sha2=$(echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1)
cat > .env <<EOF
# You MUST set a secret to secure/pepper the stored user passwords here. Use at least 64 characters.
# Generate one by using for example: pwgen -N 1 -s 96
# ATTENTION: This value must be the same on all Graylog nodes in the cluster.
# Changing this value after installation will render all user sessions and encrypted values in the database invalid. (e.g. encrypted access tokens)
GRAYLOG_PASSWORD_SECRET="$password_secret"

# You MUST specify a hash password for the root user (which you only need to initially set up the
# system and in case you lose connectivity to your authentication backend)
# This password cannot be changed using the API or via the web interface. If you need to change it,
# modify it in this file.
# Create one by using for example: echo -n yourpassword | shasum -a 256
# and put the resulting hash value into the following line
# CHANGE THIS!
GRAYLOG_ROOT_PASSWORD_SHA2="$root_password_sha2"
EOF

# write the docker-compose file (may need to sudo su for this step, permissions ugh)
cat > docker-compose.yaml <<EOF
# For DataNode setup, graylog starts with a preflight UI, this is a change from just using OpenSearch/Elasticsearch.
# Please take a look at the README at the top of this repo or the regular docs for more info.

services:
  # MongoDB: https://hub.docker.com/_/mongo/
  mongodb:
    image: "mongo:7.0"
    restart: "on-failure"
    networks:
      - graylog
    volumes:
      - "mongodb_data:/home/jon/graylog/graylog-db"
      - "mongodb_config:/home/jon/graylog/graylog-config"

  # For DataNode setup, graylog starts with a preflight UI, this is a change from just using OpenSearch/Elasticsearch.
  # Please take a look at the README at the top of this repo or the regular docs for more info.
  # Graylog Data Node: https://hub.docker.com/r/graylog/graylog-datanode

  # ⚠️ Make sure this is set on the host before starting:
  # echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
  # sudo sysctl -p
  datanode:
    image: "${DATANODE_IMAGE:-graylog/graylog-datanode:7.1}"
    hostname: "datanode"
    environment:
      GRAYLOG_DATANODE_NODE_ID_FILE: "/var/lib/graylog-datanode/node-id"
      # GRAYLOG_DATANODE_PASSWORD_SECRET and GRAYLOG_PASSWORD_SECRET MUST be the same value
      GRAYLOG_DATANODE_PASSWORD_SECRET: "${GRAYLOG_PASSWORD_SECRET:?Please configure GRAYLOG_PASSWORD_SECRET in the .env file}"
      GRAYLOG_DATANODE_MONGODB_URI: "mongodb://mongodb:27017/graylog"
    ulimits:
      memlock:
        hard: -1
        soft: -1
      nofile:
        soft: 65536
        hard: 65536
    ports:
      - "127.0.0.1:8999:8999/tcp"   # DataNode API
      - "127.0.0.1:9200:9200/tcp"
      - "127.0.0.1:9300:9300/tcp"
    networks:
      - graylog  
    volumes:
      - "graylog-datanode:/home/jon/graylog/graylog-datanode"
    restart: "on-failure"

  # Graylog: https://hub.docker.com/r/graylog/graylog-enterprise
  graylog:
    hostname: "server"
    image: "${GRAYLOG_IMAGE:-graylog/graylog:7.1}"
    depends_on:
      mongodb:
        condition: "service_started"
      datanode:
        condition: "service_started"
    entrypoint: "/usr/bin/tini --  /docker-entrypoint.sh"
    environment:
      GRAYLOG_NODE_ID_FILE: "/usr/share/graylog/data/data/node-id"
      # GRAYLOG_DATANODE_PASSWORD_SECRET and GRAYLOG_PASSWORD_SECRET MUST be the same value
      GRAYLOG_PASSWORD_SECRET: "${GRAYLOG_PASSWORD_SECRET:?Please configure GRAYLOG_PASSWORD_SECRET in the .env file}"
      GRAYLOG_ROOT_PASSWORD_SHA2: "${GRAYLOG_ROOT_PASSWORD_SHA2:?Please configure GRAYLOG_ROOT_PASSWORD_SHA2 in the .env file}"
      GRAYLOG_HTTP_BIND_ADDRESS: "0.0.0.0:9000"
      GRAYLOG_HTTP_EXTERNAL_URI: "http://localhost:9000/"
      GRAYLOG_MONGODB_URI: "mongodb://mongodb:27017/graylog"
    ports:
    - "127.0.0.1:5044:5044/tcp"   # Beats
    - "127.0.0.1:5140:5140/udp"   # Syslog
    - "127.0.0.1:5140:5140/tcp"   # Syslog
    - "127.0.0.1:5555:5555/tcp"   # RAW TCP
    - "127.0.0.1:5555:5555/udp"   # RAW UDP
    - "127.0.0.1:9000:9000/tcp"   # Server API
    - "127.0.0.1:12201:12201/tcp" # GELF TCP
    - "127.0.0.1:12201:12201/udp" # GELF UDP
    #- "127.0.0.1:10000:10000/tcp" # Custom TCP port
    #- "127.0.0.1:10000:10000/udp" # Custom UDP port
    - "127.0.0.1:13301:13301/tcp" # Forwarder data
    - "127.0.0.1:13302:13302/tcp" # Forwarder config
    networks:
      - graylog
    volumes:
      # IMPORTANT: bind mounts (e.g., "./data:/usr/share/graylog/data") currently
      # don't work correctly. You have to use volume mounts.
      # See: https://github.com/Graylog2/docker-compose/issues/99#issuecomment-3800898829
      - "graylog_data:/home/jon/graylog/graylog-data"
    restart: "on-failure"

networks:
  graylog:
    driver: "bridge"

volumes:
  mongodb_data:
  mongodb_config:
  graylog-datanode:
  graylog_data:
EOF

# create the data directories
mkdir /home/job/graylog/graylog-data
mkdir /home/job/graylog/graylog-datanode
mkdir /home/job/graylog/graylog-db
mkdir /home/job/graylog/graylog-config

# # place TLS cert and key files in this directory, either by copy or using an editor to copy/paste the certificate into a file.
# # I used VI to create cert.pem and private_key.pem files using the exported cert and key from AWS.
# # After saving them, I used OpenSSL to remove the passphrase from the private key:
# openssl rsa -in private_key.pem -out private_key_clean.pem

# open port 9000 on local ubuntu firewall
sudo ufw allow 9000/tcp

# Start Graylog
cd /home/jon/graylog
docker compose up -d

# end of line