# ---------- PARTITION MODULE ---------- #
import os

os.system('umount -R /mnt && clear')

show_cfdisk: str = input('Use cfdisk to create partitions? (Y/n) ') or 'y'
if show_cfdisk.lower() == 'y':
	os.system('cfdisk')

os.system('clear && lsblk')

boot_part = input('Boot partition (default: /dev/sda1): ') or '/dev/sda1'
root_part = input('Root partition (default: /dev/sda2): ') or '/dev/sda2'
filesystem = input('Choose filesystem ext4 (default) or btrfs: ') or 'ext4'

if filesystem == 'ext4':
	os.system(f'mkfs.ext4 -F -F {root_part}')
	os.system(f'mount {root_part} /mnt')
	os.system(f'mkdir -p /mnt/boot/efi')
	os.system('')
elif 'filesystem' == 'btrfs':
	os.system(f'mkfs.btrfs -f {root_part}')
	os.system(f'mount {root_part} /mnt')
	os.system('btrfs subvolume create /mnt/@')
	os.system('btrfs subvolume create /mnt/@home')
	os.system('btrfs subvolume create /mnt/@log')
	os.system('umount /mnt')
	os.system(f'mount -o defaults,subvol=@ {root_part} /mnt')
	os.system('mkdir -p /mnt/{boot/efi,home,var/log}')
	os.system(f'mount -o defaults,subvol=@home {root_part} /mnt/home')
	os.system(f'mount -o defaults,subvol=@log {root_part} /mnt/var/log')

os.system(f'mkfs.vfat {boot_part}')
os.system(f'mount {boot_part} /mnt/boot/efi')