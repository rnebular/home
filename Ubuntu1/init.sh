#!/usr/env bash

# This is a catalog of steps run to setup the base Ubuntu system.
# Not sure if it will be useable as a script or just copy/paste commands yet, depends on how lazy I am.

# Upgrade the O/S
sudo apt update && sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y

# verify the O/S version
lsb_release -a

# docker and docker compose
sudo snap install docker
sudo apt install docker-compose-plugin

