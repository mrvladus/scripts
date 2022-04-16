#!/bin/bash
# ---------- CONFIGURE GNOME  ---------- #
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# ---------- INSTALL YAY ---------- #
git clone https://aur.archlinux.org/yay-bin
cd yay-bin/ && echo y | makepkg -si && cd .. && rm -rf yay-bin && yay
# ---------- INSTALL AUR PKGS ---------- #
yay -S iscan-plugin-perfection-v330 --removemake
yay -S protonvpn sublime-text-4 --removemake --noconfirm
# ---------- INSTALL FLATPAKS ---------- #
flatpak install org.mozilla.firefox org.qbittorrent.qBittorrent org.godotengine.Godot org.telegram.desktop io.mpv.Mpv org.onlyoffice.desktopeditors org.gnome.eog org.gnome.FileRoller com.github.tchx84.Flatseal org.gnome.Evince org.gnome.Calculator com.github.libresprite.LibreSprite com.mattjakeman.ExtensionManager com.github.gi_lom.dialect org.gnome.Boxes -y