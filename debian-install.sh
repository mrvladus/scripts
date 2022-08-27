#!/bin/bash

# START
clear
echo '#-------------------------------#'
echo '#     DEBIAN INSTALL SCRIPT     #'
echo '#-------------------------------#'

# PACKAGES
pkgs="linux-image-amd64 firmware-linux gnome-shell nautilus gnome-console flatpak simple-scan xdg-user-dirs-gtk gdm3 nvidia-driver bash-completion android-tools-adb android-tools-fastboot neofetch"

# USER
read -p "Username: " username
read -p "Password: " password
read -e -p "Hostname: " -i "debian" hostname

# INSTALL DEPS
if command -v pacman &> /dev/null; then
	pacman -S arch-install-scripts debootstrap debian-archive-keyring debian-ports-archive-keyring --needed --noconfirm
elif command -v apt &> /dev/null; then
	apt install arch-install-scripts debootstrap -y
fi

# PARTITION
bash ./lib/partition.sh

# SELECT BRANCH
read -e -p "Select branch: stable, testing, unstable." -i "testing" branch

# DEBOOTSTRAP
debootstrap --arch amd64 $branch /mnt https://deb.debian.org/debian

# FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

# APT
sources="deb https://deb.debian.org/debian/ $branch main contrib non-free"
if [ "$branch" == "stable" ]; then
	sources+="\ndeb https://security.debian.org/debian-security $branch-security main contrib non-free\ndeb https://deb.debian.org/debian/ $branch-updates main contrib non-free\ndeb http://deb.debian.org/debian $branch-backports main contrib non-free"
elif [ "$branch" == "testing" ]; then
	sources+="\ndeb https://security.debian.org/debian-security $branch-security main contrib non-free"
fi
echo -e $sources > /mnt/apt/sources.list

# CHROOT
mount --make-rslave --rbind /proc /mnt/proc
mount --make-rslave --rbind /sys /mnt/sys
mount --make-rslave --rbind /dev /mnt/dev
mount --make-rslave --rbind /run /mnt/run
chroot /mnt /bin/bash <<EOF

# UPDATE REPOS
apt update

# TIMEZONE
dpkg-reconfigure tzdata

# LOCALE
apt install locales -y
dpkg-reconfigure locales

# HOSTNAME
echo $hostname > /etc/hostname

# HOSTS
cat > /etc/hosts << HEREDOC
127.0.0.1 localhost
127.0.1.1 $hostname	
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
HEREDOC

# USERS AND PASSWORDS
apt install sudo -y
echo "root:$password" | chpasswd
useradd -mG sudo $username
echo "$username:$password" | chpasswd
chsh -s /bin/bash $username

# GRUB
apt install grub-efi-amd64 -y
grub-install /dev/sda
update-grub

# NETWORK MANAGER
apt install network-manager -y

# INSTALL PACKAGES
apt install $pkgs -y
EOF

# UNMOUNT
umount -R /mnt

# FINISH
echo '#--------------#'
echo '#     DONE     #'
echo '#--------------#'