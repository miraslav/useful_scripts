#!/bin/bash

disks=$(ls /sys/class/block | grep -E '^(sd[a-z]|nvme[0-9]+n[0-9]+)$')

for disk in $disks; do
  echo "Rescanning $disk"
  echo 1 > "/sys/class/block/$disk/device/rescan"
done

