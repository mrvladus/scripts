#!/bin/bash
system='yay'
games='gamemode lib32-gamemode steam steam-native-runtime'
apps='gnome-logs gnome-boxes gnome-calculator simple-scan godot qbittorrent telegram-desktop firefox mpv file-roller evince eog'
aur_apps='onlyoffice-bin visual-studio-code-bin bottles extension-manager-git adw-gtk3-git protonvpn-gui'
pkgs="$system $games $apps $aur_apps"
# ---------- SU CHECK ---------- #
if [ "$(whoami)" != "root" ]; then
    echo "Run script as root!"
    exit
fi
# ---------- ADD CHAOTIC AUR ---------- #
read -p "Add Chaotic AUR? (Y/n) " add_aur
if [[ "$add_aur" == "y" || "$add_aur" == "" ]]; then
	pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
	pacman-key --lsign-key FBA220DFC880C036
	pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm --needed
	echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" >> /etc/pacman.conf
fi
# ---------- INSTALL APPS ---------- #
pacman -Syy $pkgs --noconfirm --needed
# ---------- CONFIGURE DESKTOP ---------- #
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
