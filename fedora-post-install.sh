#!/bin/bash
if [ $(whoami) != 'root' ]; then
	echo 'RUN AS ROOT!!!'
	exit 0
fi
pkgs='firefox simple-scan mpv telegram-desktop code qbittorrent godot onlyoffice-desktopeditors bottles papirus-icon-theme neofetch gnome-{extensions-app,shell-extension-appindicator,shell-extension-dash-to-dock,tweaks} jetbrains-mono-fonts'
# Cleanup
dnf groupremove "Fonts" "Multimedia" "LibreOffice" "Firefox Web Browser" "Container Management" "Guest Desktop Agents" "Hardware Support" "Printing Support" -y
dnf remove gnome-{classic-session,text-editor,software,connections,photos,characters,contacts,tour} mediawriter cheese yelp totem baobab rhythmbox libreoffice* -y
# ---------- CONFIGURE SYSTEM ---------- #
# Set hostbame
echo fedora > /etc/hostname
# Configure dnf
echo fastestmirror=True >> /etc/dnf/dnf.conf
echo defaultyes=True >> /etc/dnf/dnf.conf
echo max_parallel_downloads=10 >> /etc/dnf/dnf.conf
# Flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# RPM Fusion and ONLYOFFICE repo
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm -y
# VSCode repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
# Install software
dnf upgrade -y
dnf install $pkgs -y
# ---------- CONFIGURE GNOME ---------- #
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
# ---------- INSTALL NVIDIA DRIVER ---------- #
#dnf install akmod-nvidia -y
# Restore Plymouth
#echo "options nvidia_drm modeset=1" >> /etc/modprobe.d/nvidia.conf && echo -e "add_drivers+=\" nvidia nvidia_modeset nvidia_uvm nvidia_drm \"\ninstall_items+=\" /etc/modprobe.d/nvidia.conf \"" > /etc/dracut.conf.d/nvidia.conf && dracut -f
