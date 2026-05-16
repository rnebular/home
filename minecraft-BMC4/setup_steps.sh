#!/usr/env bash

# This is a catalog of steps run to setup Mealie.
# Not sure if it will be useable as a script or just copy/paste commands yet, depends on how lazy I am.

# tested running as root (sudo su -) on Ubuntu 22.04

# Setup pre-requisites if not already installed

# docker and docker compose
snap install docker
apt install docker-compose-plugin

# make data folders
mkdir /home/jon/minecraft && mkdir /home/jon/minecraft/data

# copy docker-compose.yml to /home/jon/minecraft
