#!/bin/bash
# ---------- FLATPAK PACKAGES ---------- #
flatpaks='io.github.shiftey.Desktop org.gnome.Logs com.usebottles.bottles org.gnome.eog org.gnome.FileRoller org.mozilla.firefox org.godotengine.Godot org.qbittorrent.qBittorrent org.telegram.desktop org.onlyoffice.desktopeditors org.gnome.Calculator org.gnome.Boxes org.gnome.Evince io.mpv.Mpv com.mattjakeman.ExtensionManager com.github.gi_lom.dialect'
# ---------- AUR PACKAGES ---------- #
manual='iscan-plugin-perfection-v330' # Requires manual answers during installation
auto='adw-gtk3-git'
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
flatpak install $flatpaks -y 
# ---------- CONFIGURE GNOME ---------- #
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# ---------- TEST ---------- #
# for package in $packages; do
#     git clone https://aur.archlinux.org/$package
#     cd $package/ && echo y | makepkg -sir && cd .. && rm -rf $package
# done