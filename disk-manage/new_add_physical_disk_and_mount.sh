#!/bin/bash

# Get a list of all disk partitions
partitions=$(lsblk | awk '$6 == "disk" {print $1}')

# Prompt the user to display the available partitions
read -p "Do you want to display the available partitions? (yes/no): " display_partitions

# If the user wants to display the available partitions
if [[ "$display_partitions" == "yes" ]]; then
  echo "Empty/Unused partitions:"
  # Loop through each partition
  for partition in $partitions; do
    # Check if the partition is formatted
    format=$(lsblk -o FSTYPE /dev/$partition | awk 'NR > 1 {print $1}')

    # Check if the partition is mounted
    mount=$(lsblk -o MOUNTPOINT /dev/$partition | awk 'NR > 1 {print $1}')

    # If the partition is unformatted and unused, output its name and size
    if [ -z "$format" ] && [ -z "$mount" ]; then
      size=$(lsblk -o SIZE /dev/$partition | awk 'NR > 1 {print $1}')
      echo "/dev/$partition: $size"
    fi
  done
fi

# Prompt the user to specify disk,  the directory path, volume group name, logical group name, and file system type
read -p "Enter the name of the physical disk to add (e.g. sdb): " choice_disk
read -p "Enter the mount directory path: " mount_dir
read -p "Enter the volume group name: " vg_name
read -p "Enter the logical group name: " lg_name
read -p "Enter the file system name (e.g. xfs): " fs_type

# Check if the specified mount directory exists, and create it if it doesn't
if [[ ! -d "$mount_dir" ]]; then
  mkdir -p "$mount_dir"
fi

# Add the new disk to the system
echo "Adding new disk to the system..."
pvcreate /dev/$choice_disk
vgcreate $vg_name /dev/$choice_disk
lvcreate -n $lg_name -l 100%VG $vg_name

# Format the logical volume with the specific file system
echo "Formatting logical volume with specific file system..."
mkfs.$fs_type /dev/mapper/$vg_name-$lg_name

# Mount the logical volume to the specified directory
echo "Mounting logical volume to $mount_dir..."
mount /dev/mapper/$vg_name-$lg_name $mount_dir

# Check if the logical volume was successfully mounted
if [[ ! -z $(mount | grep "$mount_dir") ]]; then
  echo "Disk successfully added and mounted at $mount_dir"

# Add an entry to /etc/fstab to mount the logical volume at boot
echo "/dev/$vg_name/$lg_name $mount_dir $fs_type defaults 0 0" >> /etc/fstab

# Display the available space on the mounted logical volume
echo "Available space on logical volume:"
 df -h $mount_dir
else
  echo "Failed to mount disk at $mount_dir"
fi
