#!/bin/bash
# Rescan SCSI disks and grow existing LVM physical volumes to the new device size.
set -euo pipefail

if ! command -v pvs >/dev/null 2>&1; then
  echo "pvs is not installed."
  exit 1
fi

mapfile -t pv_names < <(pvs --noheadings -o pv_name | awk 'NF { print $1 }')

if ((${#pv_names[@]} == 0)); then
  echo "No physical volumes found. Skipping pvresize."
else
  for pv in "${pv_names[@]}"; do
    if [[ -e "$pv" ]]; then
      echo "pvresize $pv"
      pvresize "$pv"
    else
      echo "Skipping missing PV: $pv"
    fi
  done
fi

shopt -s nullglob
for disk in /sys/class/block/sd[a-z] /sys/class/block/nvme[0-9]n[0-9]; do
  if [[ -w "$disk/device/rescan" ]]; then
    echo "Rescanning $disk"
    echo 1 > "$disk/device/rescan"
  fi
done

for host in /sys/class/scsi_host/host*; do
  if [[ -w "$host/scan" ]]; then
    echo "Scanning $host"
    echo "- - -" > "$host/scan"
  fi
done

if command -v partprobe >/dev/null 2>&1; then
  partprobe
fi

echo "Rescan finished."
