#!/bin/bash

# ---------- CLEANUP ---------- #
sudo dnf groupremove "Fonts" "Multimedia" "LibreOffice" "Firefox Web Browser" "Container Management" "Guest Desktop Agents" -y
sudo dnf remove gnome-{classic-session,text-editor,connections,photos,characters,contacts,tour,boxes,weather,clocks,calculator,logs,terminal} abrt mediawriter eog evince yelp totem baobab rhythmbox libreoffice* -y
sudo dnf autoremove -y
sudo dnf clean all

# ---------- CONFIGURE SYSTEM ---------- #

# Set hostbame
echo fedora | sudo tee /etc/hostname

# Configure dnf
echo skip_if_unavailable=True | sudo tee -a /etc/dnf/dnf.conf
echo defaultyes=True | sudo tee -a /etc/dnf/dnf.conf
echo max_parallel_downloads=10 | sudo tee -a /etc/dnf/dnf.conf

# Install rpm's
sudo dnf install papirus-icon-theme jetbrains-mono-fonts wireguard-tools gnome-console gnome-tweaks -y

# Flathub
sudo flatpak remote-delete flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub
flatpak install flathub org.qbittorrent.qBittorrent org.mozilla.firefox org.telegram.desktop com.visualstudio.code com.mattjakeman.ExtensionManager org.gnome.TextEditor io.mpv.Mpv org.gnome.Calendar org.gnome.gThumb org.gnome.Evince com.github.johnfactotum.Foliate com.rafaelmardojai.Blanket org.onlyoffice.desktopeditors org.gnome.Calculator org.kde.krita org.kde.kdenlive com.github.tchx84.Flatseal app.drey.Dialect -y

# ---------- CONFIGURE GNOME ---------- #
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 11"

# ---------- CONFIGURE WIREGUARD ---------- #
sudo cp ./configs/warp.conf /etc/wireguard/
sudo systemctl enable wg-quick@warp.service
sudo systemctl daemon-reload
sudo systemctl start wg-quick@warp