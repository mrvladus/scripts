#!/bin/bash
# !!! RUN UNDER THE SUPERUSER (SUDO) !!!
# ---------- HOSTNAME ---------- #
read -p "Hostname: " hostname
# ---------- USER ---------- #
read -p "Username: " username
read -p "Password: " password
# ---------- PARTITION ---------- #
lsblk
read -p "Use cfdisk to create partitions? (Y/n) " show_cfdisk
if [[ "$show_cfdisk" == "y" || "$show_cfdisk" == "" ]]; then
	cfdisk
fi
lsblk
read -p "Boot partition: " -ei "/dev/sda1" boot_part
read -p "Root partition: " -ei "/dev/sda2" root_part
mkfs.vfat -n BOOT $boot_part
mkfs.ext4 -F -F -L ROOT $root_part
mount $root_part /mnt
mkdir -p /mnt/boot/efi
mount $boot_part /mnt/boot/efi
# ---------- DEBOOTSTRAP ---------- #
apt update && apt install debootstrap -y
debootstrap --include=linux-image-amd64,linux-headers-amd64,intel-microcode,nano,git,bash-completion,man-db,flatpak,grub-efi-amd64,locales --arch=amd64 testing /mnt
# ---------- PRE-CONFIGURE ---------- #
echo -e "deb http://deb.debian.org/debian testing main contrib non-free\ndeb-src http://deb.debian.org/debian testing main contrib non-free\ndeb http://deb.debian.org/debian-security/ testing-security main contrib non-free\ndeb-src http://deb.debian.org/debian-security/ testing-security main contrib non-free" > /mnt/etc/apt/sources.list
for dir in sys dev proc ; do mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir ; done
cp /etc/resolv.conf /mnt/etc/
# ---------- CHROOT ---------- #
chroot /mnt /bin/bash <<EOF
apt update
# ---------- FSTAB ---------- #
echo "LABEL=BOOT /boot/efi vfat rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 0" > /etc/fstab
echo "LABEL=ROOT / ext4 rw,relatime 0 1" >> /etc/fstab
echo "LABEL=STORE /mnt/STORE ext4 rw,relatime,x-gvfs-show 0 2" >> /etc/fstab
# ---------- SET TIMEZONE AND LOCALE ---------- #
dpkg-reconfigure locales
dpkg-reconfigure tzdata
# ---------- CREATE USERS ---------- #
echo "root:$password" | chpasswd
useradd -mG sudo $username
echo "$username:$password" | chpasswd
# ---------- HOSTNAME ---------- #
echo $hostname > /etc/hostname
echo -e '127.0.0.1 localhost\n::1\n127.0.1.1 $hostname.localdomain $hostname' > /etc/hosts
# ---------- INSTALL BOOTLOADER ---------- #
grub-install && update-grub
# ---------- INSTALL DESKTOP ---------- #
apt install gnome-core nvidia-driver firmware-misc-nonfree papirus-icon-theme fonts-jetbrains-mono fonts-roboto -y
systemctl enable gdm
systemctl enable NetworkManager
# ---------- ADD FLATHUB REPO ---------- #
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
EOF
read -p "Chroot into new system? (y/N) " do_chroot
if [[ "$do_chroot" == "y" ]]; then
	chroot /mnt /bin/bash
fi
umount -R /mnt
read -p "Reboot now? (y/N) " do_reboot
if [[ "$do_reboot" == "y" ]]; then
	systemctl reboot
fi
# ---------- FINISH INSTALL ---------- #
