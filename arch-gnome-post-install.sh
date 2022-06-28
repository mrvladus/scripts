flatpaks='org.mozilla.firefox org.telegram.desktop com.usebottles.bottles org.gnome.{Boxes,eog,Calculator,Evince,Logs,FileRoller} com.mattjakeman.ExtensionManager io.mpv.Mpv org.qbittorrent.qBittorrent org.onlyoffice.desktopeditors org.godotengine.Godot'
# ---------- CONFIGURE DESKTOP ---------- #
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"
gsettings set org.gnome.desktop.interface font-name "Roboto Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Regular 11"
# ---------- INSTALL YAY ---------- #
git clone https://aur.archlinux.org/yay-bin
cd yay-bin/
makepkg -si
cd ..
rm -rf yay-bin
# ---------- INSTALL VSCODE ---------- #
yay && yay -S visual-studio-code-bin --noconfirm
# ---------- INSTALL FLATPAKS ---------- #
flatpak install $flatpaks -y