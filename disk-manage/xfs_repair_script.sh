#!/bin/bash
# Repair one unmounted XFS filesystem.
# --zero-log passes -L and can drop the last uncommitted metadata.
set -euo pipefail

device="${1:-/dev/mapper/VG_DB-lv_db}"
log_file="/root/repair_log_$(date +"%Y%m%d_%H%M%S").txt"
repair_args=()

if [[ "${2:-}" == "--zero-log" ]]; then
  repair_args+=(-L)
  echo "Zeroing the XFS log. Recent metadata may be lost." | tee -a "$log_file"
fi

if [[ ! -b "$device" ]]; then
  echo "Not a block device: $device"
  exit 1
fi

if findmnt "$device" >/dev/null 2>&1; then
  echo "Unmount $device before xfs_repair."
  exit 1
fi

if /sbin/xfs_repair "${repair_args[@]}" "$device" >>"$log_file" 2>&1; then
  echo "Success: $device" | tee -a "$log_file"
else
  echo "Error: $device. See $log_file"
  exit 1
fi
