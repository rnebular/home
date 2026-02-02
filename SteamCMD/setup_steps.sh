#!/usr/env bash

# setup for SteamCMD on Ubuntu 24.x
sudo apt update
sudo apt upgrade

# add steam user
sudo useradd -m steam
sudo passwd steam # will prompt for a new password
sudo usermod -aG sudo steam
sudo -u steam -s
cd /home/steam

# install SteamCMD
sudo apt install wget screen
sudo add-apt-repository multiverse; sudo dpkg --add-architecture i386; sudo apt update
sudo apt install steamcmd
sudo ln -s /usr/games/steamcmd /home/steam/steamcmd
