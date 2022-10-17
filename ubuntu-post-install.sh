#!/bin/bash

# GRUB
sudo echo "GRUB_RECORDFAIL_TIMEOUT=0" >> /etc/default/grub
sudo sed -i -e 's/quiet splash/quiet splash nvidia-drm.modeset=1/g' /etc/default/grub
sudo update-grub

# APT
sudo apt update
# Cleanup
sudo apt purge --auto-remove snapd gnome-{characters,calculator,font-viewer,power-manager,startup-applications,shell-extension-ubuntu-dock,shell-extension-desktop-icons-ng,system-monitor,logs} eog evince gedit seahorse file-roller fonts-{beng,g*,k*,la*,lk*,lo*,na*,or*,p*,s*,t*,y*} -y
rm -rf ./snap
# Papirus icons
sudo add-apt-repository ppa:papirus/papirus -y
# Distrobox
sudo add-apt-repository ppa:michel-slm/distrobox -y
# Debs
sudo apt install --no-install-recommends neofetch -y
sudo apt install simple-scan gnome-tweaks android-sdk-platform-tools flatpak fonts-jetbrains-mono gjs git papirus-icon-theme distrobox -y

# Flatpaks
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install org.mozilla.firefox com.mattjakeman.ExtensionManager -y

# NVIDIA DRIVER
sudo apt install nvidia-driver-515 -y
sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit
sudo nvidia-xconfig
