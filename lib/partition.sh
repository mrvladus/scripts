# --- PARTITION MODULE --- #
# UNMOUNT ALL
umount -R /mnt && clear

# CFDISK
read -e -p "Use cfdisk to create partitions? [Y/n] " use_cfdisk
if [[ "$use_cfdisk" == "y" || "$use_cfdisk" == "" ]]; then
	cfdisk
fi

# SELECT PARTITIONS
lsblk
# ROOT
read -e -p "Root partition: " -i "/dev/sda2" root
read -e -p "Select filesystem for root: btrfs, ext4. " -i "btrfs" fs_type
if [[ "$fs_type" == "btrfs" ]]; then
	mkfs.btrfs -f $root
	mount $root /mnt
	btrfs su cr /mnt/@
	btrfs su cr /mnt/@home
	btrfs su cr /mnt/@var
	btrfs su cr /mnt/@tmp 
	umount /mnt
	mount -o space_cache=v2,autodefrag,noatime,commit=120,compress=zstd,subvol=@ $root /mnt
	mkdir -p /mnt/{boot/efi,home,var,tmp}
	mount -o space_cache=v2,autodefrag,noatime,commit=120,compress=zstd,subvol=@home $root /mnt/home
	mount -o space_cache=v2,autodefrag,noatime,commit=120,compress=zstd,subvol=@tmp $root /mnt/tmp
	mount -o space_cache=v2,autodefrag,noatime,commit=120,compress=zstd,subvol=@var $root /mnt/var
elif [[ "$fs_type" == "ext4" ]]; then
	mkfs.ext4 -F -F $root
	mount $root /mnt
	mkdir -p /mnt/boot/efi
fi
# BOOT
read -e -p "Boot partition: " -i "/dev/sda1" boot
mkfs.vfat $boot
mount $boot /mnt/boot/efi
