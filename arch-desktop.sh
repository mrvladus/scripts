#!/bin/bash
# ---------- PACKAGES ---------- #
cli_programs='bash-completion man neofetch reflector flatpak'
fstools='gvfs-goa gvfs-mtp gvfs-nfs xdg-user-dirs-gtk'
devel='git android-tools'
network='networkmanager networkmanager-openvpn'
drivers='nvidia nvidia-settings'
looks='ttf-jetbrains-mono ttf-roboto papirus-icon-theme arc-solid-gtk-theme'
apps='simple-scan'
# ---------- PROFILES ---------- #
gnome='gdm gnome-shell gnome-control-center gnome-remote-desktop gnome-user-share rygel gnome-backgrounds gnome-keyring gnome-terminal nautilus gnome-tweaks gst-plugins-good simple-scan'
xfce='xorg-server lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings thunar thunar-volman thunar-archive-plugin xfce4-panel xfce4-power-manager xfce4-session xfce4-settings xfce4-terminal xfdesktop xfwm4 xfce4-notifyd pulseaudio-alsa pavucontrol xfce4-pulseaudio-plugin xfce4-screensaver xfce4-screenshooter xfce4-whiskermenu-plugin xfce4-xkb-plugin network-manager-applet'
# ---------- CREDENTIALS ---------- #
read -p "Hostname: " -ei "arch" hostname
read -p "Username: " username
read -p "Password: " password
# ---------- PROFILE SELECTION ---------- #
read -p "Type desktop enviroment (gnome, xfce): " -ei "gnome" de
if [[ "$de" == "gnome" ]]; then
	profile=$gnome
elif [[ "$de" == "xfce" ]]; then
	profile=$xfce
else
	profile=''
fi
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
reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands -p https -p http
pacman -Syy
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BASE ---------- #
pacstrap /mnt base base-devel linux linux-firmware intel-ucode nano
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
pacman -S efibootmgr grub --noconfirm
grub-install
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i -e 's/loglevel=3 quiet/loglevel=3 quiet nvidia-drm.modeset=1/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# ---------- INSTALL NETWORK MANAGER ---------- #
pacman -S $network --noconfirm
systemctl enable NetworkManager
# ---------- INSTALL DESKTOP ---------- #
pacman -S $profile $fstools $cli_programs $devel $drivers $looks $apps --noconfirm
if [[ "$de" == "gnome" ]]; then
	systemctl enable gdm
else
	systemctl enable lightdm
fi
# ---------- CREATE POST INSTALL SCRIPT ---------- #
curl https://raw.githubusercontent.com/mrvladus/scripts/main/post-install.sh > /home/$username/post-install.sh
chmod 777 /home/$username/post-install.sh
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
