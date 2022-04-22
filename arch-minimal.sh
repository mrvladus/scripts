#!/bin/bash
# ---------- PACKAGES ---------- #
basic_programs='bash-completion man neofetch reflector efibootmgr grub'
network='networkmanager'
# ---------- CREDENTIALS ---------- #
read -p "Hostname: " -ei "arch" hostname
read -p "Username: " username
read -p "Password: " password
# ---------- PARTITION ---------- #
umount -R /mnt
read -p "Use cfdisk to create partitions? (Y/n) " show_cfdisk
if [[ "$show_cfdisk" == "y" || "$show_cfdisk" == "" ]]; then
	cfdisk
fi
lsblk
read -p "Boot partition: " -ei "/dev/sda1" boot_part
read -p "Root partition: " -ei "/dev/sda2" root_part
mkfs.vfat $boot_part
mkfs.ext4 -F -F $root_part
mount $root_part /mnt
mkdir -p /mnt/boot/efi
mount $boot_part /mnt/boot/efi
# ---------- UPDATE MIRRORS ---------- #
reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands -p http
pacman -Syy
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BASE ---------- #
pacstrap /mnt base base-devel linux intel-ucode nano $basic_programs
genfstab -U /mnt >> /mnt/etc/fstab
# ---------- CHROOT ---------- #
arch-chroot /mnt /bin/bash <<EOF
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
echo $hostname > /etc/hostname
echo -e '127.0.0.1 localhost\n::1\n127.0.1.1 $hostname.localdomain $hostname' >> /etc/hosts
# ---------- CONFIGURE MKINITCPIO ---------- #
mkinitcpio -p linux
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BOOTLOADER ---------- #
grub-install
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# ---------- INSTALL DESKTOP ---------- #
pacman -S $network --noconfirm
systemctl enable NetworkManager
EOF
read -p "Chroot into new system? (y/N) " do_chroot
if [[ "$do_chroot" == "y" ]]; then
	arch-chroot /mnt /bin/bash
fi
umount -R /mnt
# ---------- FINISH INSTALL ---------- #
read -p "Reboot now? (y/N) " do_reboot
if [[ "$do_reboot" == "y" ]]; then
	systemctl reboot
fi
