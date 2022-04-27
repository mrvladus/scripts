#!/bin/bash
# ---------- CLEANUP SYSTEM ---------- #
sudo apt purge snapd gnome-{logs,power-manager,fonts,characters,calculator} eog evince gedit yelp file-roller fonts-{t*,s*,b*,g*,k*,lo*,or*,pa*,lk*,la*} brltty cups* seahorse printer* bluez* --auto-remove
# ---------- UPDATE SYSTEM ---------- #
sudo apt update && sudo apt upgrade -y
# ---------- INSTALL SUBLIME TEXT ---------- #
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt install apt-transport-https -y
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install sublime-text -y
# ---------- INSTALL FLATPAKS ---------- #
sudo apt install flatpak -y
bash ./flatpak-apps-install.sh