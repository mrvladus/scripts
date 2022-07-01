#!/bin/python
import os
# ---------- FLATPAK APPS ---------- #
apps = 'org.gnome.Boxes com.usebottles.bottles com.mattjakeman.ExtensionManager'
# ---------- CONFIGURE DESKTOP ---------- #
os.system(f'gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"')
os.system(f'gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"')
os.system(f'gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"')
os.system(f'gsettings set org.gnome.desktop.interface icon-theme "Papirus"')
os.system(f'gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"')
# ---------- INSTALL FLATPAK APPS ---------- #
os.system(f'flatpak install {apps} -y')