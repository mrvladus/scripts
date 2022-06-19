cli='bash-completion android-tools neofetch flatpak'
devel='git python3-pip'
gnome='gnome-{shell,shell-extension-appindicator,terminal,terminal-nautilus,backgrounds,tweaks,shell-extension-app,calculator,boxes,logs,disk-utility,keyring} nautilus file-roller gvfs-{mtp,nfs} eog evince evince-djvu chrome-gnome-shell'
looks='papirus-icon-theme jetbrains-mono-fonts'
apps='firefox simple-scan mpv bottles steam telegram-desktop code qbittorrent godot onlyoffice-desktopeditors protonvpn'
pkgs="$cli $gnome $looks $apps"
# ---------- CONFIGURE SYSTEM ---------- #
# Set hostbame
sudo echo fedora > /etc/hostname
# Configure dnf
sudo echo assumeyes=True >> /etc/dnf/dnf.conf
sudo echo install_weak_deps=False >> /etc/dnf/dnf.conf
sudo echo fastestmirror=True >> /etc/dnf/dnf.conf
sudo echo max_parallel_downloads=10 >> /etc/dnf/dnf.conf
# Flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# RPM Fusion
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# ONLYOFFICE
sudo dnf install https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm -y
# VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
# ProtonVPN
sudo echo -e '[protonvpn-fedora-stable]\nname = ProtonVPN Fedora Stable repository\nbaseurl = https://repo.protonvpn.com/fedora-$releasever-stable\nenabled = 1\ngpgcheck = 1\nrepo_gpgcheck=1n\gpgkey = https://repo.protonvpn.com/fedora-$releasever-stable/public_key.asc' > /etc/yum.repos.d/protonvpn-stable.repo
# Update repos
sudo dnf update -y
# Install software
sudo dnf install $apps -y
# Cleanup
sudo dnf autoremove -y
# ---------- CONFIGURE GNOME ---------- #
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono Regular 10"