#!/bin/bash
# Print whole disks that have no filesystem and no mountpoint on the disk or its partitions.
set -euo pipefail

while read -r name type; do
  [[ "$type" == "disk" ]] || continue
  used=$(lsblk -n -o FSTYPE,MOUNTPOINT "/dev/$name" | tr -d '[:space:]')
  if [[ -z "$used" ]]; then
    size=$(lsblk -dn -o SIZE "/dev/$name")
    echo "/dev/$name: $size"
  fi
done < <(lsblk -dn -o NAME,TYPE)
