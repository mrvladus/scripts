#!/bin/bash
# ---------- AUR PACKAGES ---------- #
manual='iscan-plugin-perfection-v330' # Requires manual answers during installation 
auto='sublime-text-4 onlyoffice-bin extension-manager pixelorama-bin'
# ---------- CONFIGURE GNOME  ---------- #
echo "Configuring GNOME..."
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# ---------- INSTALL YAY ---------- #
if [ -f "/bin/yay" ]; then
    echo "YAY already installed. Skipping..."
else 
    git clone https://aur.archlinux.org/yay-bin
    cd yay-bin/ && echo y | makepkg -si && cd .. && rm -rf yay-bin && yay
fi
# ---------- INSTALL AUR PKGS ---------- #
yay -S $manual --removemake --needed
yay -S $auto --removemake --noconfirm --needed
