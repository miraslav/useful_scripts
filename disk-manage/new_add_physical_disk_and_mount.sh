#!/bin/bash
# Show unused disks, then create an LVM volume, format it, and mount it by UUID.
set -euo pipefail

read -r -p "Show unused disks first? (yes/no): " display_partitions
if [[ "$display_partitions" == "yes" ]]; then
  "$(dirname "$0")/get_empty_disk.sh"
fi

read -r -p "Physical disk name without /dev (example sdb): " choice_disk
read -r -p "Mount directory: " mount_dir
read -r -p "Volume group name: " vg_name
read -r -p "Logical volume name: " lv_name
read -r -p "Filesystem (xfs or ext4): " fs_type

disk="/dev/${choice_disk}"

case "$fs_type" in
  xfs|ext4) ;;
  *) echo "Filesystem must be xfs or ext4."; exit 1 ;;
esac

if [[ ! -b "$disk" ]]; then
  echo "Not a block device: $disk"
  exit 1
fi

if lsblk -n -o MOUNTPOINT "$disk" | grep -q '[^[:space:]]'; then
  echo "Refusing $disk because it has a mounted filesystem."
  exit 1
fi

echo "This creates PV/VG/LV on $disk and formats it as $fs_type."
read -r -p "Type yes to destroy existing data on $disk: " answer
[[ "$answer" == "yes" ]] || exit 1

mkdir -p "$mount_dir"
pvcreate "$disk"
vgcreate "$vg_name" "$disk"
lvcreate -n "$lv_name" -l 100%VG "$vg_name"

device="/dev/${vg_name}/${lv_name}"
mkfs."$fs_type" "$device"

if mount "$device" "$mount_dir"; then
  uuid=$(blkid -s UUID -o value "$device")
  echo "UUID=${uuid} ${mount_dir} ${fs_type} defaults 0 2" >> /etc/fstab
  echo "Mounted $device on $mount_dir"
  df -h "$mount_dir"
else
  echo "Failed to mount $device on $mount_dir"
  exit 1
fi
