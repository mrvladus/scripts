#!/bin/bash

# START
clear
echo '#-------------------------------#'
echo '#     DEBIAN INSTALL SCRIPT     #'
echo '#-------------------------------#'

# PACKAGES
pkgs="linux-image-amd64 firmware-linux gnome-shell nautilus gnome-console flatpak simple-scan xdg-user-dirs-gtk nvidia-driver firmware-misc-nonfree bash-completion android-tools-adb android-tools-fastboot neofetch fonts-ubuntu fonts-jetbrains-mono"

# USER
read -p "Username: " username
read -p "Password: " password
read -e -p "Hostname: " -i "debian" hostname

# INSTALL DEPS
if command -v pacman &> /dev/null; then
	pacman -Sy arch-install-scripts debootstrap debian-archive-keyring debian-ports-archive-keyring --needed --noconfirm
fi
if command -v apt &> /dev/null; then
	apt update && apt install arch-install-scripts debootstrap btrfs-progs dosfstools -y
fi

# PARTITION
bash ./lib/partition.sh

# SELECT BRANCH
read -e -p "Select branch: stable, testing, unstable. " -i "testing" branch

# DEBOOTSTRAP
debootstrap --arch=amd64 --variant=minbase $branch /mnt https://deb.debian.org/debian

# FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

# APT SOURCES
sources="deb https://deb.debian.org/debian/ $branch main contrib non-free"
if [ "$branch" == "stable" ]; then
	sources+="\ndeb https://security.debian.org/debian-security $branch-security main contrib non-free\ndeb https://deb.debian.org/debian/ $branch-updates main contrib non-free\ndeb http://deb.debian.org/debian $branch-backports main contrib non-free"
elif [ "$branch" == "testing" ]; then
	sources+="\ndeb https://security.debian.org/debian-security $branch-security main contrib non-free"
fi
echo -e $sources > /mnt/etc/apt/sources.list

# HOSTNAME
echo $hostname > /mnt/etc/hostname;

# HOSTS
cat > /mnt/etc/hosts << HEREDOC
127.0.0.1 localhost
127.0.1.1 $hostname	
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
HEREDOC

# CHROOT COMMANDS (separate by ;)
post_install="
# UPDATE REPOS
apt update;

# TIMEZONE
dpkg-reconfigure tzdata;

# LOCALE
apt install locales -y;
dpkg-reconfigure locales;

# USERS AND PASSWORDS
apt install sudo -y;
echo root:$password | chpasswd;
useradd -mG sudo $username;
echo $username:$password | chpasswd;
chsh -s /bin/bash $username;

# GRUB
apt install grub-efi-amd64 -y;
grub-install /dev/sda;
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub;
sed -i -e 's/quiet/loglevel=3 quiet vt.global_cursor_default=0 nvidia-drm.modeset=1/g' /etc/default/grub;
update-grub;

# INSTALL PACKAGES
apt install $pkgs -y;
"

# CHROOT
mount --make-rslave --rbind /proc /mnt/proc
mount --make-rslave --rbind /sys /mnt/sys
mount --make-rslave --rbind /dev /mnt/dev
mount --make-rslave --rbind /run /mnt/run
chroot /mnt su - -c "$post_install"

# UNMOUNT
umount -R /mnt

# FINISH
echo '#--------------#'
echo '#     DONE     #'
echo '#--------------#'