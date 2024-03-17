#!/bin/bash

# Prompt user for physical disk name
echo "Enter the name of the physical disk to add (e.g. /dev/sdb):"
read disk

# Prompt user for volume group name
echo "Enter the name of the volume group:"
read vg_name

# Prompt user for logical group name
echo "Enter the name of the logical group:"
read lv_name

# Prompt user for directory to mount the logical volume on
echo "Enter the directory to mount the logical volume on (e.g. /mnt/data):"
read mount_dir

# Check if the mount directory exists, and create it if it doesn't
if [ ! -d $mount_dir ]; then
  mkdir $mount_dir
fi

# Create physical volume on the disk
pvcreate $disk

# Create volume group from physical volume
vgcreate $vg_name $disk

# Create logical volume from volume group
lvcreate -n $lv_name -l 100%VG $vg_name

# Create XFS file system on logical volume
mkfs.xfs /dev/$vg_name/$lv_name

# Mount the logical volume at the specified directory
mount /dev/$vg_name/$lv_name $mount_dir

# Add an entry to /etc/fstab to mount the logical volume at boot
echo "/dev/$vg_name/$lv_name $mount_dir xfs defaults 0 0" >> /etc/fstab

# Confirm that the disk has been successfully added, VG and LV created, and specified directory mounted
echo "Physical disk $disk has been added to volume group $vg_name and logical group $lv_name, with $mount_dir specified as the mount point."