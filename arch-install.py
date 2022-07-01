#!/bin/python
import os, getpass, shutil, datetime
# Launch script execution timer
start_time = datetime.datetime.now()
# ---------- UTILS FUNCTIONS ---------- #
def clear():
	os.system('clear')

def pause():
	pause = input('Continue? (Y/n)') or 'y'
	if pause == 'y':
		return
	else:
		exit()

def find_and_replace(line: str, new_line: str, file_path: str):
	os.system(f"sed -i -e 's/{line}/{new_line}/g' {file_path}")

def cmd(command: str = ''):
	os.system(command)

def chroot_cmd(command: str = ''):
	os.system(f'arch-chroot /mnt /bin/bash -c "{command}"')

def create_file(text: str, path: str):
	with open(path, 'w') as f:
		f.write(text)

def append_to_file(text: str, path: str):
	with open(path, 'a') as f:
		f.write(text)
# ---------- PACKAGES ---------- #
base_system = 'linux linux-firmware base base-devel intel-ucode nano'
cli_programs = 'bash-completion man git neofetch reflector'
apps = 'qbittorrent firefox godot gnome-calculator eog file-roller simple-scan telegram-desktop code gnome-logs evince libreoffice-fresh mpv flatpak android-tools'
gnome = 'gdm gnome-{shell,control-center,backgrounds,keyring,terminal} nautilus gst-plugins-good gvfs-{mtp,nfs} xdg-user-dirs-gtk ttf-{jetbrains-mono,roboto} papirus-icon-theme'
# ---------- PROFILES ---------- #
desktop = f'{cli_programs} {gnome} {apps} nvidia nvidia-settings'
minimal = f'{cli_programs} open-vm-tools'
# ---------- BEGIN INSTALLATION ---------- #
clear()
print('''
#-----------------------------#
#     ARCH INSTALL SCRIPT     #
#-----------------------------#
''')
# ---------- CREDENTIALS ---------- #
username = input('Username: ')
password = getpass.getpass()
hostname = input('Hostname (default: arch): ') or 'arch'
# ---------- PROFILE ---------- #
selected_profile = input('''
1. gnome (default)
2. minimal
Select profile: ''') or '1'
if selected_profile == '1':
	profile = desktop
else:
	profile = minimal
# ---------- PARTITION ---------- #
cmd('umount -R /mnt && clear')
show_cfdisk: str = input('Use cfdisk to create partitions? (Y/n) ') or 'y'
if show_cfdisk.lower() == 'y':
	cmd('cfdisk')
clear()
cmd('lsblk')
boot_part = input('Boot partition (default: /dev/sda1): ') or '/dev/sda1'
root_part = input('Root partition (default: /dev/sda2): ') or '/dev/sda2'
filesystem = input('''
1. ext4 (default)
2. btrfs
Choose filesystem: ''') or '1'
if filesystem == '1':
	cmd(f'mkfs.ext4 -F -F {root_part}')
	cmd(f'mount {root_part} /mnt')
	cmd(f'mkdir -p /mnt/boot/efi')
elif 'filesystem' == '2':
	cmd(f'mkfs.btrfs -f {root_part}')
	cmd(f'mount {root_part} /mnt')
	cmd('btrfs subvolume create /mnt/@')
	cmd('btrfs subvolume create /mnt/@home')
	cmd('btrfs subvolume create /mnt/@log')
	cmd('umount /mnt')
	cmd(f'mount -o defaults,subvol=@ {root_part} /mnt')
	cmd('mkdir -p /mnt/{boot/efi,home,var/log}')
	cmd(f'mount -o defaults,subvol=@home {root_part} /mnt/home')
	cmd(f'mount -o defaults,subvol=@log {root_part} /mnt/var/log')
cmd(f'mkfs.vfat {boot_part}')
cmd(f'mount {boot_part} /mnt/boot/efi')
cmd('lsblk')
pause()
# ---------- UPDATE MIRRORS ---------- #
cmd('echo "Updating mirrors..."')
cmd('reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands -p https -p http')
cmd('pacman -Syy')
# ---------- CONFIGURE PACMAN ---------- #
find_and_replace('#ParallelDownloads', 'ParallelDownloads', '/etc/pacman.conf')
find_and_replace('#Color', 'Color', '/etc/pacman.conf')
# ---------- INSTALL BASE ---------- #
cmd(f'pacstrap /mnt {base_system}')
cmd('genfstab -U /mnt >> /mnt/etc/fstab')
# ---------- SET TIMEZONE AND LOCALE ---------- #
chroot_cmd('ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime')
chroot_cmd('hwclock --systohc')
find_and_replace('#ru_RU.UTF-8 UTF-8', 'ru_RU.UTF-8 UTF-8', '/mnt/etc/locale.gen')
find_and_replace('#en_US.UTF-8 UTF-8', 'en_US.UTF-8 UTF-8', '/mnt/etc/locale.gen')
chroot_cmd('locale-gen')
create_file('LANG=en_US.UTF-8', '/mnt/etc/locale.conf')
# ---------- CREATE USERS ---------- #
chroot_cmd(f"echo 'root:{password}' | chpasswd")
chroot_cmd(f'useradd -mG wheel {username}')
chroot_cmd(f"echo '{username}:{password}' | chpasswd")
find_and_replace('# %wheel ALL=(ALL:ALL) ALL', '%wheel ALL=(ALL:ALL) ALL', '/mnt/etc/sudoers')
# ---------- HOSTNAME AND HOSTS ---------- #
create_file(hostname, '/mnt/etc/hostname')
append_to_file(f'127.0.0.1 localhost\n::1\n127.0.1.1 {hostname}.localdomain {hostname}', '/mnt/etc/hosts')
# ---------- CONFIGURE MKINITCPIO ---------- #
if filesystem == '2':
	find_and_replace('MODULES=()', 'MODULES=(btrfs)', '/mnt/etc/mkinitcpio.conf')
	find_and_replace('HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)', 'HOOKS=(base udev autodetect modconf block filesystems keyboard)', '/mnt/etc/mkinitcpio.conf')
	chroot_cmd('mkinitcpio -p linux')
# ---------- CONFIGURE PACMAN ---------- #
find_and_replace('#ParallelDownloads', 'ParallelDownloads', '/mnt/etc/pacman.conf')
find_and_replace('#Color', 'Color', '/mnt/etc/pacman.conf')
# ---------- INSTALL BOOTLOADER ---------- #
chroot_cmd('pacman -Syy efibootmgr grub --noconfirm')
chroot_cmd('grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB')
pause()
find_and_replace('GRUB_TIMEOUT=5', 'GRUB_TIMEOUT=0', '/mnt/etc/default/grub')
if profile == minimal:
	find_and_replace('loglevel=3 quiet', 'loglevel=3 quiet nvidia-drm.modeset=1', '/mnt/etc/default/grub')
chroot_cmd('grub-mkconfig -o /boot/grub/grub.cfg')
# ---------- INSTALL NETWORK MANAGER ---------- #
chroot_cmd('pacman -S networkmanager networkmanager-openvpn --noconfirm')
chroot_cmd('systemctl enable NetworkManager')
# ---------- INSTALL PROFILE ---------- #
chroot_cmd(f'pacman -S {profile} --noconfirm')
# ---------- ENABLE DISPLAY MANAGER ---------- #
if selected_profile == '1':
	chroot_cmd('systemctl enable gdm')
# ---------- COPY CONFIGS ---------- #
shutil.copytree('./configs', f'/mnt/home/{username}/', dirs_exist_ok = True)
# ---------- FINISH INSTALLATION ---------- #
cmd('umount -R /mnt')
print(f'''
# --------------------- #
# Installation is done! #
# --------------------- #''')
