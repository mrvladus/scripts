#-----------------------------#
#     ARCH INSTALL SCRIPT     #
#-----------------------------#
import os
from getpass import getpass
from modules.utils import find_and_replace
# ---------- PACKAGES ---------- #
base_system = 'base base-devel intel-ucode nano'
cli_programs = 'bash-completion man git neofetch reflector android-tools'
gnome = 'gdm gnome-{shell,control-center,backgrounds,keyring,terminal} nautilus gst-plugins-good gvfs-{mtp,nfs} xdg-user-dirs-gtk ttf-{jetbrains-mono,roboto} papirus-icon-theme'
# ---------- PROFILES ---------- #
desktop = f'{cli_programs} {gnome} nvidia nvidia-settings lib32-nvidia-utils'
minimal = f'{cli_programs} open-vm-tools'
# ---------- CREDENTIALS ---------- #
username = input('Username: ')
password = getpass()
hostname = input('Hostname (default: arch): ') or 'arch'
# ---------- PROFILE ---------- #
selected_profile = input('Select profile (default: gnome, minimal): ') or 'gnome'
if selected_profile == 'gnome':
	profile = desktop
else:
	profile = minimal
# ---------- PARTITION ---------- #
from modules.partition import *
# ---------- UPDATE MIRRORS ---------- #
os.system('clear && echo "Updating mirrors..."')
os.system('reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist -c Netherlands -p https -p http')
os.system('pacman -Syy')
# ---------- CONFIGURE PACMAN ---------- #
find_and_replace('#ParallelDownloads', 'ParallelDownloads', '/etc/pacman.conf')
find_and_replace('#Color', 'Color', '/etc/pacman.conf')
# ---------- INSTALL BASE ---------- #
os.system(f'pacstrap /mnt {base_system}')
os.system('genfstab -U /mnt >> /mnt/etc/fstab')
# ---------- CHROOT ---------- #

