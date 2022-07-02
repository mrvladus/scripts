#!/bin/python3
#------------------------------------#
#     UBUNTU POST INSTALL SCRIPT     #
#------------------------------------#
from lib.utils import *
# Packages
debs = 'git neofetch alacarte simple-scan papirus-icon-theme flatpak fonts-jetbrains-mono mpv qbittorrent onlyoffice-desktopeditors code gnome-tweaks gnome-shell-extension-manager gjs libreoffice-gnome libreoffice telegram-desktop'
flatpaks = 'org.mozilla.firefox com.usebottles.bottles org.gnome.Boxes'
# Cleanup
cmd('sudo apt purge --auto-remove snapd gnome-characters gedit gnome-power-manager seahorse fonts-{beng,smc,thai-tlwg,g*,k*,la*,lk*,lo*,na*,or*,p*,s*,t*,y*} cups printer-driver-* -y')
# Update system
cmd('sudo apt update && sudo apt upgrade -y')
# Configure system
cmd('sudo systemctl disable NetworkManager-wait-online.service')
# Install and configure NVIDIA drivers
cmd('sudo apt install nvidia-driver-510 -y && sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service')
# VSCode
cmd('wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && sudo echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && rm -f packages.microsoft.gpg && sudo apt update && sudo apt install apt-transport-https -y')
# Install DEB's
cmd(f'sudo apt install {debs} -y')
# Install flatpaks
cmd(f'sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && flatpak install {flatpaks} -y')
