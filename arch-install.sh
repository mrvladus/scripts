#!/bin/bash
# ---------- PACKAGES ---------- #
apps='simple-scan godot qbittorrent telegram-desktop firefox mpv flatpak'
base_system='base base-devel linux linux-firmware intel-ucode nano'
cli_programs='bash-completion man neofetch reflector bpytop'
fstools='fuse2 gvfs-{mtp,nfs} xdg-user-dirs-gtk'
devel='git'
phone='android-tools'
sound='wireplumber pipewire-{pulse,alsa,jack}'
looks='ttf-{jetbrains-mono,roboto} papirus-icon-theme'
desktop_base="$cli_programs $fstools $devel $phone $sound $looks"
lightdm="xorg-server lightdm lightdm-gtk-{greeter,greeter-settings}"
# ---------- PROFILES ---------- #
gnome="$desktop_base gdm gnome-{shell,control-center,remote-desktop,user-share,backgrounds,keyring,terminal,tweaks,logs,boxes,calculator} rygel nautilus gst-plugins-good eog file-roller evince"
xfce="$desktop_base $lightdm thunar thunar-{volman,archive-plugin} xfce4-{panel,power-manager,session,settings,terminal,notifyd,screensaver,screenshooter,whiskermenu-plugin,xkb-plugin,pulseaudio-plugin} ristretto xfdesktop xfwm4 pavucontrol network-manager-applet arc-gtk-theme"
minimal="$cli_programs $devel"
# ---------- CREDENTIALS ---------- #
read -p "Hostname: " -ei "arch" hostname
read -p "Username: " username
read -p "Password: " password
# ---------- PROFILE SELECTION ---------- #
read -p "Select profile (gnome, xfce, minimal): " -ei "gnome" selected_profile
if [[ "$selected_profile" == "gnome" ]]; then
	profile=$gnome
elif [[ "$selected_profile" == "xfce" ]]; then
	profile=$xfce
elif [[ "$selected_profile" == "minimal" ]]; then
	profile=$minimal
else
	profile=''
fi
# ---------- VIDEO DRIVERS SELECTION ---------- #
read -p "Select video driver (nvidia, vm): " -ei "nvidia" driver
if [[ "$driver" == "nvidia" ]]; then
	drivers='nvidia nvidia-settings'
elif [[ "$driver" == "vm" ]]; then
	drivers='xf86-video-vmware xf86-input-vmmouse virtualbox-guest-utils'
else
	exit
fi
# ---------- ADDITIONAL SOFTWARE SELECTION ---------- #
read -p "Install apps? (Y/n) " install_apps
if [[ "$install_apps" == "n" ]]; then
	$apps=''
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
read -p "Choose filesystem: (ext4, btrfs) " -ei "ext4" filesystem
if [[ "$filesystem" == "ext4" ]]; then
	mkfs.ext4 -F -F $root_part
	mount $root_part /mnt
	mkdir -p /mnt/boot/efi
elif [[ "$filesystem" == "btrfs" ]]; then
	mkfs.btrfs -f $root_part
	mount $root_part /mnt
	btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
	btrfs subvolume create /mnt/@log
	umount /mnt
	mount -o defaults,subvol=@ $root_part /mnt
	mkdir -p /mnt/{boot/efi,home,var/log}
	mount -o defaults,subvol=@home $root_part /mnt/home
	mount -o defaults,subvol=@log $root_part /mnt/var/log
	base_system+=' btrfs-progs'
else
	exit
fi
mkfs.vfat $boot_part
mount $boot_part /mnt/boot/efi
# ---------- UPDATE MIRRORS ---------- #
clear && echo "Updating mirrors..."
reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands -p https -p http
pacman -Syy
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BASE ---------- #
pacstrap /mnt $base_system
genfstab -U /mnt >> /mnt/etc/fstab
# ---------- CHROOT ---------- #
arch-chroot /mnt /bin/bash <<EOF
# ---------- CONFIGURE FSTAB ---------- #
#echo -e "LABEL=STORE /mnt/STORE ext4 rw,relatime,x-gvfs-show 0 1" >> /etc/fstab
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
if [[ "$filesystem" == "btrfs" ]]; then
	sed -i -e 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
	sed -i -e 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block filesystems keyboard)/g' /etc/mkinitcpio.conf
fi
mkinitcpio -p linux
# ---------- CONFIGURE PACMAN ---------- #
sed -i -e 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
# ---------- INSTALL BOOTLOADER ---------- #
pacman -S efibootmgr grub --noconfirm
grub-install
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
if [[ "$driver" == "nvidia" ]]; then
	sed -i -e 's/loglevel=3 quiet/loglevel=3 quiet nvidia-drm.modeset=1/g' /etc/default/grub
fi
grub-mkconfig -o /boot/grub/grub.cfg
# ---------- INSTALL NETWORK MANAGER ---------- #
pacman -S networkmanager networkmanager-openvpn --noconfirm
systemctl enable NetworkManager
# ---------- INSTALL PROFILE ---------- #
pacman -S $profile $drivers $apps --noconfirm
# ---------- ENABLE DISPLAY MANAGER ---------- #
if [[ "$selected_profile" == "gnome" ]]; then
	systemctl enable gdm
elif [[ "$selected_profile" == "xfce" ]]; then
	systemctl enable lightdm
fi
EOF
# ---------- CREATE POST INSTALL SCRIPT ---------- #
if [[ "$selected_profile" != "minimal" || "$selected_profile" != "" ]]; then
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
