#!/bin/bash
# ---------- PACKAGES ---------- #
base='linux-image-amd64 nano bash-completion'
de='gnome-core flatpak'
looks='papirus-icon-theme'
cli='git neofetch'
# ---------- SU CHECK ---------- #
if [ "$(whoami)" != "root" ]; then
    echo "Run script as root!"
    exit
fi
# ---------- INSTALL DEBOOTSTRAP ---------- #
if [ -f "/bin/pacman" ]; then
	echo "Running on Arch Linux"
	pacman -Sy debootstrap arch-install-scripts --noconfirm --needed
elif [ -f "/bin/apt" ]; then
	echo "Running on Debian"
	apt install debootstrap arch-install-scripts -y
fi
# ---------- CREDENTIALS ---------- #
read -p "Username: " username
read -p "Password: " password
# ---------- PARTITIONS ---------- #
umount -R /mnt
umount /boot/efi
read -p "Use cfdisk to create partitions? (Y/n) " show_cfdisk
if [[ "$show_cfdisk" == "y" || "$show_cfdisk" == "" ]]; then
	cfdisk
fi
clear && lsblk
read -p "Root partition: " -ei "/dev/sda2" root_part
read -p "WARNING!!! Format root at $root_part? (y/N) " format_root
if [[ "$format_root" == "y" ]]; then
	mkfs.ext4 -F -F $root_part
	mount $root_part /mnt
else
	echo "Exiting installation..."
	exit
fi
read -p "Boot partition: " -ei "/dev/sda1" boot_part
read -p "Format boot partition at $boot_part? (y/N) " format_boot
if [[ "$format_boot" == "y" ]]; then
	mkfs.vfat $boot_part
	mkdir -p /mnt/boot/efi
fi
mount $boot_part /mnt/boot/efi
# ---------- DEBOOTSTRAP ---------- #
read -p "Select branch: stable, testing, unstable " -ei "testing" branch
debootstrap $branch /mnt
if [[ "$branch" == "unstable" ]]; then
	echo "deb http://deb.debian.org/debian/ unstable main contrib non-free" > /mnt/etc/apt/sources.list
elif [[ "$branch" == "testing" ]]; then
	echo "deb http://deb.debian.org/debian/ testing main contrib non-free" > /mnt/etc/apt/sources.list
else
	echo -e "deb http://deb.debian.org/debian bullseye main contrib non-free\ndeb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free\ndeb http://deb.debian.org/debian bullseye-updates main contrib non-free\ndeb http://deb.debian.org/debian bullseye-backports main contrib non-free" > /mnt/etc/apt/sources.list
fi
for dir in sys dev proc ; do
	mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir
done
# ---------- CONFIGURE FSTAB ---------- #
genfstab -U /mnt >> /mnt/etc/fstab
#echo -e "LABEL=STORE /mnt/STORE ext4 rw,relatime,x-gvfs-show 0 1" >> /mnt/etc/fstab
# ---------- CHROOT ---------- #
chroot /mnt /bin/bash <<EOF
# ---------- SET TIMEZONE AND LOCALE ---------- #
apt update
apt install locales -y
dpkg-reconfigure locales
dpkg-reconfiigure tzdata
# ---------- CONFIGURE USERS ---------- #
apt install sudo -y
echo "root:$password" | chpasswd
useradd -mG sudo $username
echo "$username:$password" | chpasswd
# ---------- INSTALL PACKAGES ---------- #
apt install $base $de $looks $cli -y --no-install-recommends
# ---------- INSTALL BOOTLOADER ---------- #
apt install grub-efi-amd64 os-prober -y
grub-install
update-grub
# ---------- ENABLE SERVICES ---------- #
systemctl enable gdm
systemctl enable NetworkManager
# ---------- CONFIGURE .bashrc ---------- #
echo -e "[[ $- != *i* ]] && return\nPS1='[\u@\h \W]\$ '\nalias ls='ls --color=auto'\n" > /home/$username/.bashrc
EOF
umount -R /mnt
echo "DONE!!!"