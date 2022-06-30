#!/bin/bash
#----------------------------------#
#     ARCH POST INSTALL SCRIPT     #
#----------------------------------#
system='yay'
apps='gnome-logs gnome-boxes gnome-calculator simple-scan godot qbittorrent telegram-desktop firefox mpv file-roller evince eog code'
pkgs="$system $games $apps $aur_apps"
# ---------- SU CHECK ---------- #
if [ "$(whoami)" != "root" ]; then
    echo "Run script as root!"
    exit
fi
# ---------- INSTALL APPS ---------- #
pacman -Syy $pkgs --noconfirm --needed
# ---------- CONFIGURE DESKTOP ---------- #
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
