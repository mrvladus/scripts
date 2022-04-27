#!/bin/bash
# ---------- PACKAGES ---------- #
cli_programs='bash-completion man neofetch reflector git'
fstools='fuse2 gvfs-{mtp,nfs} xdg-user-dirs-gtk'
devel=''
phone='android-tools'
drivers='nvidia nvidia-settings'
looks='ttf-{jetbrains-mono,roboto} papirus-icon-theme arc-gtk-theme'
apps='simple-scan'
desktop_base="$cli_programs $fstools $devel $phone $drivers $looks $apps"
lightdm="xorg-server lightdm lightdm-gtk-{greeter,greeter-settings}"
# ---------- PROFILES ---------- #
gnome="$desktop_base gdm gnome-{shell,control-center,remote-desktop,user-share,backgrounds,keyring,terminal,tweaks} rygel nautilus gst-plugins-good"
xfce="$desktop_base $lightdm thunar thunar-{volman,archive-plugin} xfce4-{panel,power-manager,session,settings,terminal,notifyd,screensaver,screenshooter,whiskermenu-plugin,xkb-plugin,pulseaudio-plugin} xfdesktop xfwm4 pavucontrol network-manager-applet"
cinnamon="$desktop_base $lightdm cinnamon cinnamon-translations gnome-{keyring,terminal}"
minimal="$cli_programs
# ---------- CREDENTIALS ---------- #
read -p "Hostname: " -ei "arch" hostname
read -p "Username: " username
read -p "Password: " password
# ---------- PROFILE SELECTION ---------- #
read -p "Select profile (gnome, xfce, cinnamon, minimal): " -ei "gnome" de
if [[ "$de" == "gnome" ]]; then
	profile=$gnome
elif [[ "$de" == "xfce" ]]; then
	profile=$xfce
elif [[ "$de" == "cinnamon" ]]; then
	profile=$cinnamon
elif [[ "$de" == "minimal" ]]; then
	profile=$minimal
else
	profile=''
fi
# ---------- PARTITION ---------- #
umount -R /mnt
read -p "Use cfdisk to create partitions? (Y/n) " show_cfdisk
if [[ "$show_cfdisk" == "y" || "$show_cfdisk" == "" ]]; then
	cfdisk
fi
clear && lsblk
read -p "Boot partition: " -ei "/dev/sda1" boot_part
read -p "Root partition: " -ei "/dev/sda2" root_part
mkfs.vfat $boot_part
mkfs.ext4 -F -F $root_part
mount $root_part /mnt
mkdir -p /mnt/boot/efi
mount $boot_part /mnt/boot/efi
# ---------- UPDATE MIRRORS ---------- #
clear && echo "Updating mirrors..."
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
pacman -S networkmanager networkmanager-openvpn --noconfirm
systemctl enable NetworkManager
# ---------- INSTALL PROFILE ---------- #
pacman -S $profile --noconfirm
if [[ "$de" == "gnome" ]]; then
	systemctl enable gdm
elif [[ "$de" == "xfce" ]]; then
	systemctl enable lightdm
fi
# ---------- INSTALL SUBLIME TEXT ---------- #
if [[ "$de" != "minimal" ]]; then
	curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
	echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | tee -a /etc/pacman.conf
	pacman -Syu sublime-text --noconfirm
fi
EOF
# ---------- CREATE POST INSTALL SCRIPT ---------- #
if [[ "$de" != "minimal" ]]; then
	clear && echo "Creating post-install script..."
	cp ./arch-post-install.sh /mnt/home/$username/
	chmod 777 /mnt/home/$username/arch-post-install.sh
fi
# ---------- CHROOT ---------- #
read -p "Chroot into new system? (y/N) " do_chroot
if [[ "$do_chroot" == "y" ]]; then
	arch-chroot /mnt /bin/bash
fi
umount -R /mnt
# ---------- REBOOT ---------- #
read -p "Reboot now? (y/N) " do_reboot
if [[ "$do_reboot" == "y" ]]; then
	systemctl reboot
fi
