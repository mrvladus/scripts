 #!/bin/bash

# GRUB
echo GRUB_RECORDFAIL_TIMEOUT=0 | sudo tee -a /etc/default/grub
sudo update-grub

# APT

# Enable backports
echo -e "Package: *\nPin: release a=jammy-backports\nPin-Priority: 500" | sudo tee -a /etc/apt/preferences

# Update cache
sudo apt update

# Cleanup
sudo apt autopurge snapd gedit gnome-{characters,power-manager,startup-applications} fonts-{beng,g*,k*,la*,lk*,lo*,na*,or*,p*,s*,t*,y*} -y
rm -rf ./snap
sudo rm -rf /root/snap

# Install nala
sudo apt install nala -y
sudo nala update

# Add VSCode repo
sudo nala install wget gpg apt-transport-https -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Firefox repo
sudo add-apt-repository ppa:mozillateam/ppa
echo -e "Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001" | sudo tee /etc/apt/preferences.d/mozilla-firefox

# Install debs
sudo nala update
sudo nala install git gnome-text-editor timeshift simple-scan android-sdk-platform-tools fonts-jetbrains-mono mpv qbittorrent ubuntu-restricted-extras code build-essential libasound2-dev mesa-common-dev libx11-dev libxrandr-dev libxi-dev xorg-dev libgl1-mesa-dev libglu1-mesa-dev nvidia-driver-525 wireguard curl flatpak resolvconf firefox -y

# NodeJS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs

# Upgrade
sudo nala upgrade -y

# nfetch
wget -qO- https://raw.githubusercontent.com/mrvladus/nfetch/master/install.sh | sh
echo nfetch >> .bashrc

# Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install org.onlyoffice.desktopeditors org.gnome.Boxes org.telegram.desktop com.mattjakeman.ExtensionManager -y

# NVIDIA DRIVER
sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit

# SETUP
sudo systemctl disable NetworkManager-wait-online.service

