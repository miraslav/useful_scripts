#!/bin/bash
# Create one Linux LVM partition on each disk passed as an argument.
# Refuses a disk that already has a mounted filesystem.
set -euo pipefail

if (($# == 0)); then
  echo "Usage: $0 /dev/sdb [/dev/sdc ...]"
  echo "Writes a new GPT label and one LVM partition. This destroys existing data on those disks."
  exit 1
fi

for disk in "$@"; do
  if [[ ! -b "$disk" ]]; then
    echo "Not a block device: $disk"
    exit 1
  fi

  if lsblk -n -o MOUNTPOINT "$disk" | grep -q '[^[:space:]]'; then
    echo "Refusing $disk because it has a mounted filesystem."
    exit 1
  fi
done

echo "About to repartition: $*"
read -r -p "Type yes to continue: " answer
[[ "$answer" == "yes" ]] || exit 1

for disk in "$@"; do
  echo "Partitioning $disk"
  printf 'g\nn\n\n\n\nt\n8e\nw\n' | fdisk "$disk"
done
