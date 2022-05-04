#!/bin/bash
# ---------- AUR PACKAGES ---------- #
manual='iscan-plugin-perfection-v330' # Requires manual answers during installation
auto='adw-gtk3-git sublime-text-4'
# ---------- INSTALL YAY ---------- #
if [ -f "/bin/yay" ]; then
    echo "YAY already installed. Skipping..."
else 
    git clone https://aur.archlinux.org/yay-bin
    cd yay-bin/ && echo y | makepkg -sir && cd .. && rm -rf yay-bin && yay
fi
# ---------- INSTALL AUR PKGS ---------- #
yay -S $manual --removemake --needed
yay -S $auto --removemake --noconfirm --needed
# ---------- CONFIGURE GNOME ---------- #
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# ---------- INSTALL FLATPAKS ---------- #
flatpaks='org.gnome.{Logs,eog,FileRoller,Calculator,Boxes,Evince,design.Palette,design.IconLibrary} io.github.shiftey.Desktop com.usebottles.bottles org.mozilla.firefox org.godotengine.Godot org.qbittorrent.qBittorrent org.telegram.desktop org.onlyoffice.desktopeditors io.mpv.Mpv com.mattjakeman.ExtensionManager com.github.gi_lom.dialect'
flatpak install $flatpaks -y