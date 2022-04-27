#!/bin/bash
sudo apt purge snapd gnome-logs gnome-power-manager gnome-fonts gnome-characters --auto-remove
sudo apt install flatpak -y
bash ./flatpak-apps-install.sh