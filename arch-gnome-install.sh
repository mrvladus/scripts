#!/bin/bash
# ---------- PACKAGES ---------- #
cli_programs='bash-completion man neofetch reflector nano git flatpak'
fstools='fuse2 gvfs-{mtp,nfs,afc}'
phone='android-tools'
looks='ttf-{jetbrains-mono,roboto} papirus-icon-theme'
drivers='nvidia nvidia-settings'
gnome="$cli_programs $fstools $phone $looks $drivers gdm gnome-{shell,control-center,backgrounds,keyring,terminal} nautilus gst-plugins-good xdg-user-dirs-gtk simple-scan"
# ---------- CREDENTIALS ---------- #
read -p "Username: " username
read -p "Password: " password
# ---------- PARTITION ---------- #
umount -R /mnt
read -p "Use cfdisk to create partitions? (Y/n) " show_cfdisk
if [[ "$show_cfdisk" == "y" || "$show_cfdisk" == "" ]]; then
	cfdisk
fi
clear && lsblk
read -p "Boot partition: " -ei "/dev/sda1" boot_part
read -p "Root partition: " -ei "/dev/sda2" root_part
mkfs.ext4 -F -F $root_part
mount $root_part /mnt
mkdir -p /mnt/boot/efi
mkfs.vfat $boot_part
mount $boot_part /mnt/boot/efi
# ---------- UPDATE MIRRORS ---------- #
echo "Updating mirrors..."
reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands -p https -p http
pacman -Syy
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BASE ---------- #
pacstrap /mnt linux linux-firmware base base-devel intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
# ---------- CHROOT ---------- #
arch-chroot /mnt /bin/bash <<EOF
# ---------- CONFIGURE FSTAB ---------- #
echo -e "LABEL=STORE /mnt/STORE ext4 rw,relatime,x-gvfs-show 0 1" >> /etc/fstab
# ---------- SET TIMEZONE AND LOCALE ---------- #
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
sed -i -e 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
# ---------- CREATE USERS ---------- #
echo "root:$password" | chpasswd
useradd -mG wheel $username
echo "$username:$password" | chpasswd
sed -i -e 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
# ---------- HOSTNAME AND HOSTS ---------- #
echo arch > /etc/hostname
echo -e '127.0.0.1 localhost\n::1\n127.0.1.1 arch.localdomain arch' >> /etc/hosts
# ---------- CONFIGURE MKINITCPIO ---------- #
mkinitcpio -p linux
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BOOTLOADER ---------- #
pacman -Syy efibootmgr grub --noconfirm
grub-install
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i -e 's/loglevel=3 quiet/loglevel=3 quiet nvidia-drm.modeset=1/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# ---------- INSTALL NETWORK MANAGER ---------- #
pacman -S networkmanager networkmanager-openvpn --noconfirm
systemctl enable NetworkManager
# ---------- INSTALL PROFILE ---------- #
pacman -S $gnome --noconfirm
systemctl enable gdm
EOF
# ---------- CREATE POST INSTALL SCRIPT ---------- #
echo "Creating post-install script..."
cp ./arch-gnome-post-install.sh /mnt/home/$username/post_install.sh
chmod 777 /mnt/home/$username/post_install.sh
umount -R /mnt
echo "DONE"
