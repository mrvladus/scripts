#!/bin/bash
echo '#-----------------------------#'
echo '#     ARCH INSTALL SCRIPT     #'
echo '#-----------------------------#'
# APPS
base_system='linux linux-firmware base base-devel intel-ucode nano btrfs-progs'
cli_programs='bash-completion man neofetch reflector android-tools flatpak'
dev='meson git'
audio='wireplumber pipewire-alsa pipewire-pulse pipewire-jack'
drivers='nvidia nvidia-settings'
gnome='gdm gnome-{shell,control-center,backgrounds,keyring,tweaks,console,text-editor} nautilus gst-plugin-pipewire gst-plugins-good gvfs-mtp xdg-user-dirs-gtk ttf-jetbrains-mono ttf-ubuntu-font-family papirus-icon-theme'
apps='visual-studio-code-bin simple-scan simple-scan firefox qbittorrent telegram-desktop gthumb file-roller extension-manager-git adw-gtk3-git dialect krita inkscape godot pitivi'
# USER
read -p "Username: " username
read -p "Password: " password
read -p "Hostname: " hostname
# PARTITION
umount -R /mnt && clear
cfdisk
lsblk
read -p "Boot partition: " boot
mkfs.vfat $boot
read -p "Root partition: " root
mkfs.btrfs -f $root
mount $root /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp 
umount /mnt
mount -o noatime,commit=120,compress=zstd,subvol=@ $root /mnt
mkdir -p /mnt/{boot/efi,home,var,opt,tmp}
mount -o noatime,commit=120,compress=zstd,subvol=@home $root /mnt/home
mount -o noatime,commit=120,compress=zstd,subvol=@opt $root /mnt/opt
mount -o noatime,commit=120,compress=zstd,subvol=@tmp $root /mnt/tmp
mount -o subvol=@var $root /mnt/var
mount $boot /mnt/boot/efi
# MIRRORS
reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands -p https -p http
pacman -Syy
# PACMAN
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# PACSTRAP
pacstrap /mnt $base_system
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
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' >> /etc/pacman.conf
# ---------- INSTALL BOOTLOADER ---------- #
pacman -Syy efibootmgr grub --noconfirm
grub-install
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i -e 's/loglevel=3 quiet/loglevel=3 quiet nvidia-drm.modeset=1/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# ---------- INSTALL NETWORK MANAGER ---------- #
pacman -S networkmanager networkmanager-openvpn --noconfirm
systemctl enable NetworkManager
# ---------- INSTALL PACKAGES ---------- #
pacman -S "$cli_programs $dev $drivers $audio $gnome $apps" --noconfirm
systemctl enable gdm
EOF
echo "#-------------#"
echo "#     DONE    #"
echo "#-------------#"
