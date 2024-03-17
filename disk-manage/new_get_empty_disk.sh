#!/bin/bash

# This script uses the lsblk command to get information about the available block devices in the system, and the awk command to extract the relevant columns. If a partition is unformatted and unused, its name is printed.

# This script will give you the names of the unformatted and unused partitions that you can use for your purposes. Note that you should be careful when working with disk partitions, as you can easily destroy data and cause other issues if you make a mistake.

# Get a list of all disk partitions
partitions=$(lsblk | awk '$6 == "disk" {print $1}')

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

