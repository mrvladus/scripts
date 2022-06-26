#!/bin/bash
#------------------------------------#
#     UBUNTU POST INSTALL SCRIPT     #
#------------------------------------#
debs='git neofetch mpv qbittorrent alacarte simple-scan gnome-{tweaks,text-editor,shell-extension-manager} gjs papirus-icon-theme flatpak fonts-jetbrains-mono'
flatpaks='org.mozilla.firefox org.telegram.desktop com.usebottles.bottles'
# Cleanup
sudo apt purge --auto-remove snapd gnome-characters gedit gnome-power-manager seahorse fonts-{beng,smc,thai-tlwg,g*,k*,la*,lk*,lo*,na*,or*,p*,s*,t*,y*} cups printer-driver-* -y
# Update system
sudo apt update && sudo apt upgrade -y
# Install and configure NVIDIA drivers
sudo apt install nvidia-driver-510 -y
sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service # Disable for avoiding suspend problems
# Install DEB's from Ubuntu repos
sudo apt install $debs -y
# Install VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update && sudo apt install apt-transport-https -y && sudo apt install code -y
# Install ONLYOFFICE
gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /etc/apt/trusted.gpg.d/
echo 'deb https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee -a /etc/apt/sources.list.d/onlyoffice.list
sudo apt update && sudo apt install onlyoffice-desktopeditors -y
# Install flatpaks
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install $flatpaks -y

