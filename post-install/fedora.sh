#!/bin/bash

# ---------- CLEANUP ---------- #
sudo dnf groupremove "Fonts" "Multimedia" "LibreOffice" "Firefox Web Browser" "Container Management" "Guest Desktop Agents" "Hardware Support" "Printing Support" -y
sudo dnf remove gnome-{classic-session,text-editor,software,connections,photos,characters,contacts,tour} mediawriter eog evince cheese yelp totem baobab rhythmbox libreoffice* -y
sudo dnf autoremove -y
sudo dnf clean all

# ---------- CONFIGURE SYSTEM ---------- #

# Set hostbame
echo fedora | sudo tee /etc/hostname

# Configure dnf
echo skip_if_unavailable=True | sudo tee -a /etc/dnf/dnf.conf
echo fastestmirror=True | sudo tee -a /etc/dnf/dnf.conf
echo defaultyes=True | sudo tee -a /etc/dnf/dnf.conf
echo max_parallel_downloads=10 | sudo tee -a /etc/dnf/dnf.conf
echo keepcache=True | sudo tee -a /etc/dnf/dnf.conf
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf upgrade --refresh -y

# Install rpm's
sudo dnf install simple-scan papirus-icon-theme jetbrains-mono-fonts wget nodejs -y

# Flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.qbittorrent.qBittorrent org.mozilla.firefox org.telegram.desktop com.visualstudio.code com.mattjakeman.ExtensionManager org.gnome.TextEditor io.mpv.Mpv -y

# nfetch
wget -qO- https://raw.githubusercontent.com/mrvladus/nfetch/master/install.sh | sh

# ---------- CONFIGURE GNOME ---------- #
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"

# ---------- INSTALL NVIDIA DRIVER ---------- #
#dnf install akmod-nvidia -y
# Restore Plymouth
#echo "options nvidia_drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf && echo -e "add_drivers+=\" nvidia nvidia_modeset nvidia_uvm nvidia_drm \"\ninstall_items+=\" /etc/modprobe.d/nvidia.conf \"" | sudo tee -a /etc/dracut.conf.d/nvidia.conf && dracut -f

# ---------- BASH ALIASES ---------- #
echo "" >> .bash_aliases
echo "up='sudo dnf upgrade --refresh -y && flatpak update -y'" >> .bash_aliases
