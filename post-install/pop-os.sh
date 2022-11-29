#!/bin/bash
# nfetch
wget -qO- https://raw.githubusercontent.com/mrvladus/nfetch/master/install.sh | sh
echo nfetch >> .bashrc

# Cleanup
sudo apt autopurge gedit geary gnome-contacts gnome-power-manager gnome-startup-applications eog gnome-characters totem -y

# Update
sudo apt update && sudo apt upgrade -y

# Install
sudo apt install timeshift simple-scan android-sdk-platform-tools fonts-jetbrains-mono mpv qbittorrent gthumb ubuntu-restricted-extras code build-essential libasound2-dev mesa-common-dev libx11-dev libxrandr-dev libxi-dev xorg-dev libgl1-mesa-dev libglu1-mesa-dev -y

# Services
sudo systemctl disable NetworkManager-wait-online.service

# NVIDIA
sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit
sudo nvidia-settings