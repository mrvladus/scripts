flatpaks='org.mozilla.firefox org.telegram.desktop com.usebottles.bottles org.gnome.{Boxes,eog,Calculator,Evince,Logs,FileRoller} com.mattjakeman.ExtensionManager io.mpv.Mpv org.qbittorrent.qBittorrent org.onlyoffice.desktopeditors'
# ---------- CONFIGURE DESKTOP ---------- #
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
# ---------- INSTALL APPS ---------- #
flatpak install $flatpaks -y