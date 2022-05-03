#!/bin/bash
packages='neofetch sublime-text flatpak simple-scan papirus-icon-theme gnome-tweaks onlyoffice-desktopeditors github-desktop telegram-desktop'
flatpaks='com.usebottles.bottles org.mozilla.firefox org.godotengine.Godot com.mattjakeman.ExtensionManager org.gnome.design.IconLibrary org.gnome.design.Palette'
# ---------- SETUP SYSTEM ---------- #
sudo systemctl disable NetworkManager-wait-online.service
# ---------- CLEANUP SYSTEM ---------- #
sudo apt purge snapd gnome-{power-manager,font-viewer,characters,shell-extension-ubuntu-dock} gedit yelp fonts-{t*,s*,b*,g*,k*,lo*,or*,pa*,lk*,la*} brltty cups* seahorse printer* bluez* --auto-remove
# ---------- ADD SUBLIME TEXT REPO ---------- #
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt install apt-transport-https -y
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
# ---------- ADD ONLYOFFICE REPO ---------- #
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
echo 'deb https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee -a /etc/apt/sources.list.d/onlyoffice.list
# ---------- ADD GITHUB DESKTOP REPO ---------- #
wget -qO - https://mirror.mwt.me/ghd/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list'
# ---------- INSTALL PACKAGES ---------- #
sudo apt update
sudo apt install $packages -y
# ---------- INSTALL FLATPAKS ---------- #
flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install $flatpaks -y
