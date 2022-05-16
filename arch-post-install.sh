#!/bin/bash
aur_apps='sublime-text-4 onlyoffice-bin github-desktop bottles icon-library pixelorama timeshift-bin cloudflare-warp-bin'
# --- ADD CHAOTIC AUR --- #
sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC880C036
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" >> /etc/pacman.conf
sudo pacman -Syy
# ---------- CONFIGURE DESKTOP ---------- #
if [[ $XDG_SESSION_DESKTOP == 'gnome' ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
    gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
    gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
    gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    aur_apps+=" extension-manager-git adw-gtk3-git"
elif [[ $XDG_SESSION_DESKTOP == 'xfce' ]]; then
    aur_apps+=" xfce4-docklike-plugin"
fi
sudo pacman -S $aur_apps