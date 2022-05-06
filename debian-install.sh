#!/bin/bash
# ---------- SU CHECK ---------- #
if [ "$(whoami)" != "root" ]; then
    echo "Run script as root!"
    exit
fi
# ---------- INSTALL DEBOOTSTRAP ---------- #
if [ -f "/bin/pacman" ]; then
	echo "Running on Arch Linux"
	pacman -Sy debootstrap arch-install-scripts --noconfirm
elif [ -f "/bin/apt" ]; then
	echo "Running on Debian"
	apt install debootstrap arch-install-scripts -y
fi
# ---------- CREDENTIALS ---------- #
read -p "Hostname: " -ei "arch" hostname
read -p "Username: " username
read -p "Password: " password
# ---------- PARTITIONS ---------- #
umount -R /mnt
read -p "Use cfdisk to create partitions? (Y/n) " show_cfdisk
if [[ "$show_cfdisk" == "y" || "$show_cfdisk" == "" ]]; then
	cfdisk
fi
clear && lsblk
read -p "Root partition: " -ei "/dev/sda2" root_part
mkfs.ext4 -F -F $root_part
mount $root_part /mnt
read -p "Boot partition: " -ei "/dev/sda1" boot_part
read -p "Format boot partition? (Y/n) " do_format
if [[ "$do_format" == "y" || "$do_format" == "" ]]; then
	mkfs.vfat $boot_part
	mkdir -p /mnt/boot/efi
fi
mount $boot_part /mnt/boot/efi
# ---------- DEBOOTSTRAP ---------- #
debootstrap testing /mnt
echo "deb http://deb.debian.org/debian/ testing main contrib non-free" > /mnt/etc/apt/sources.list
for dir in sys dev proc ; do
	mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir
done
genfstab -U /mnt >> /mnt/etc/fstab
# ---------- CHROOT ---------- #
chroot /mnt /bin/bash <<EOF
# ---------- CONFIGURE FSTAB ---------- #
echo -e "LABEL=STORE /mnt/STORE ext4 rw,relatime,x-gvfs-show 0 1" >> /etc/fstab
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
apt install linux-image-amd64 nano git neofetch bash-completion gnome-core flatpak papirus-icon-theme grub-efi-amd64 os-prober -y --no-install-recommends
# ---------- INSTALL BOOTLOADER ---------- #
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