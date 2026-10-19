#!/bin/bash
set -euo pipefail

print_disk_list() {
  lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINT
}

extend_vg() {
  local vg_name=$1
  local pv_name=$2
  echo "Extending VG ${vg_name} with ${pv_name}. Take a backup before continuing."
  sudo pvcreate "$pv_name"
  sudo vgextend "$vg_name" "$pv_name"
}

extend_lv() {
  local vg_name=$1
  local lv_name=$2
  echo "Extending LV ${vg_name}/${lv_name}. lvextend -r grows the filesystem (xfs and ext)."
  sudo lvextend -r -l +100%FREE "/dev/${vg_name}/${lv_name}"
}

while true; do
  echo "1. Disk list"
  echo "2. Extend VG"
  echo "3. Extend LV"
  echo "4. Exit"
  read -r -p "Action: " action

  case "$action" in
    1)
      print_disk_list
      ;;
    2)
      read -r -p "Volume group: " vg_name
      read -r -p "New physical volume (example /dev/sdc): " pv_name
      if sudo vgs --noheadings -o vg_name | awk '{print $1}' | grep -qx "$vg_name"; then
        extend_vg "$vg_name" "$pv_name"
      else
        echo "Volume group does not exist: $vg_name"
      fi
      ;;
    3)
      read -r -p "Volume group: " vg_name
      read -r -p "Logical volume: " lv_name
      if sudo lvs --noheadings -o lv_name,vg_name | awk '{print $1, $2}' | grep -qx "${lv_name} ${vg_name}"; then
        extend_lv "$vg_name" "$lv_name"
      else
        echo "Logical volume does not exist: ${vg_name}/${lv_name}"
      fi
      ;;
    4)
      exit 0
      ;;
    *)
      echo "Unknown action."
      ;;
  esac

  read -r -p "Another action? (y/n): " again
  [[ "$again" == "n" ]] && break
done
