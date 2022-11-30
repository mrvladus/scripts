#!/bin/bash

# GRUB
echo GRUB_RECORDFAIL_TIMEOUT=0 | sudo tee -a /etc/default/grub
sudo update-grub

# APT
sudo apt update

# Cleanup
sudo apt purge --auto-remove snapd gnome-{characters,power-manager,startup-applications} eog fonts-{beng,g*,k*,la*,lk*,lo*,na*,or*,p*,s*,t*,y*} -y
rm -rf ./snap

# Upgrade
sudo apt upgrade -y

# Install debs
sudo apt install timeshift simple-scan android-sdk-platform-tools fonts-jetbrains-mono mpv qbittorrent gthumb ubuntu-restricted-extras code build-essential libasound2-dev mesa-common-dev libx11-dev libxrandr-dev libxi-dev xorg-dev libgl1-mesa-dev libglu1-mesa-dev nvidia-driver-520 -y


# Flatpaks
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# NVIDIA DRIVER
sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit
sudo nvidia-xconfig

# SETUP
sudo systemctl disable NetworkManager-wait-online.service
