#!/bin/bash

# ---------- CONFIGURE DESKTOP ---------- #
if [[ $XDG_SESSION_DESKTOP == 'gnome' ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
    gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
    gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
    gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
fi