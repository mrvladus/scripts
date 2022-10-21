#!/bin/bash

# GRUB
echo GRUB_RECORDFAIL_TIMEOUT=0 | sudo tee -a /etc/default/grub
sudo update-grub

# APT
sudo apt update

# Cleanup
sudo apt purge --auto-remove snapd gnome-{characters,font-viewer,power-manager,startup-applications} eog fonts-{beng,g*,k*,la*,lk*,lo*,na*,or*,p*,s*,t*,y*} -y
rm -rf ./snap

# Install debs
sudo apt install simple-scan gnome-tweaks android-sdk-platform-tools flatpak fonts-jetbrains-mono neofetch mpv qbittorrent telegram-desktop gthumb nvidia-driver-515 -y

# Upgrade
sudo apt upgrade -y

# Flatpaks
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install org.mozilla.firefox org.onlyoffice.desktopeditors com.visualstudio.code -y

# NVIDIA DRIVER
sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit
sudo nvidia-xconfig

# SETUP
sudo systemctl disable NetworkManager-wait-online.service
