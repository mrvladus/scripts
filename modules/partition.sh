# ---------- PARTITION MODULE ---------- #
umount -R /mnt
clear
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