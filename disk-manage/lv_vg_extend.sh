#!/bin/bash

# Function to print disk list
function print_disk_list {
    echo "Disk Name | Size | Mount Point"
    echo "-----------------------------"
    for disk in $(lsblk -d -o name,size | awk '$2~/[0-9]+G/ {printf $1 ":" $2 "\n"}')
    do
        echo $disk
    done
}

# Function to extend VG
function extend_vg {
    vg_name=$1
    pv_name=$2
    echo "You are extending VG $vg_name with PV $pv_name. This may cause data corruption, so please make sure you have a backup before proceeding."
    sudo pvcreate $pv_name
    sudo vgextend $vg_name $pv_name
}

# Function to extend LV
function extend_lv {
    lv_name=$1
    echo "You are extending LV $lv_name. This may cause data corruption, so please make sure you have a backup before proceeding."
    sudo lvextend -r -l +100%FREE /dev/mapper/$vg_name-$lv_name
    sudo resize2fs /dev/mapper/$vg_name-$lv_name
}

# Get list of VG/LV
vg_list=$(sudo vgs --noheadings -o vg_name)
lv_list=$(sudo lvs --noheadings -o lv_name)

# Prompt user for action
while true
do
    echo "Select an action:"
    echo "1. Get disk list"
    echo "2. Extend VG"
    echo "3. Extend LV"
    echo "4. Exit"
    read -p "Enter the action number: " action

    case $action in
        1)
            # Print disk list
            print_disk_list
            ;;
        2)
            # Extend VG
            read -p "Enter the name of the VG you want to extend: " vg_name
            read -p "Enter the name of the new PV you want to use: " pv_name
            if [[ $vg_list =~ (^|[[:space:]])"$vg_name"($|[[:space:]]) ]]; then
                extend_vg $vg_name $pv_name
            else
                echo "Error: $vg_name does not exist as a VG."
            fi
            ;;
        3)
            # Extend LV
            read -p "Enter the name of the LV you want to extend: " lv_name
            if [[ $lv_list =~ (^|[[:space:]])"$lv_name"($|[[:space:]]) ]]; then
                extend_lv $lv_name
            else
                echo "Error: $lv_name does not exist as an LV."
            fi
            ;;
        4)
            # Exit
            exit 0
            ;;
        *)
            # Invalid input
            echo "Error: Invalid input."
            ;;
    esac

    # Ask user if they want to continue
    read -p "Do you want to perform another action? (y/n): " continue

    # Check if user wants to continue
    if [[ $continue == "n" ]]; then
        break
    fi
done

