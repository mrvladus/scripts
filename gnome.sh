#!/bin/bash
# ---------- HOSTNAME ---------- #
read -p "Hostname: " hostname
# ---------- USER ---------- #
read -p "Username: " username
read -p "Password: " password
# ---------- PACKAGES ---------- #
basic_programs='bash-completion man neofetch reflector efibootmgr grub flatpak'
devel='python-gobject git android-tools gtk4-demos libadwaita-demos gtksourceview5'
gnome='gdm gnome-shell gnome-control-center gnome-remote-desktop gnome-user-share rygel gnome-backgrounds gnome-keyring gnome-terminal nautilus gvfs-goa gvfs-mtp gvfs-nfs simple-scan xdg-user-dirs-gtk gnome-tweaks gst-plugins-good'
network='networkmanager networkmanager-openvpn'
drivers='nvidia nvidia-settings'
looks='ttf-jetbrains-mono ttf-roboto papirus-icon-theme'
# ---------- PARTITION ---------- #
umount -R /mnt
mkfs.fat -F 32 /dev/sda1 
mkfs.ext4 -F -F /dev/sda2
mount /dev/sda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
# ---------- UPDATE MIRRORS ---------- #
reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands
pacman -Syy
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BASE ---------- #
pacstrap /mnt base base-devel linux linux-firmware intel-ucode nano $basic_programs
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
sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# ---------- INSTALL DESKTOP ---------- #
pacman -S $gnome $devel $network $drivers $looks --noconfirm
systemctl enable gdm
systemctl enable NetworkManager
EOF
umount -R /mnt
