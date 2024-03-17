#!/bin/bash

# I want to use great code, but I don't know, how it wrotes.
# If you can help me with my problem, please, open the issue or send me PR.
# Also, I don't understand How you can use python instead of Bash. Thank you so much.
# Remember, [[ -e $values ]] to check an existing file and [[ -z $value ]] to check an empty line

# Enable error functions via microcode set -e
set -e

# Function to check and print error message
check_error () {
    if [    $? -ne 0 ];
        then
            echo "Error: $1"
            exit 1
    fi
}

# Pre-define variables for clear code
DISK_PATH="/sys/class/block"
DISK_PREFIX="sd"
SCSI_HOST_PATH="/sys/class/scsi_host"

# Retrieve mpath values from pvs command output
mpath_values=$(pvs --noheadings -o pv_name | awk '{print $1}')
check_error "Failed to retrive mpath values, plz check your syntax"

# Check if there are no mpath values (hard check)
if [[ -z "$mpath_values"]];
    then
        echo "No mpath found. Script stopped..."
        exit 0
fi

# Iterate over each mpath and try to run pvresize command with each values
for mpath in $mpath_values; do
    if [[ -e "$mpath"]];
        then
            pvresize "$mpath"
            check_error "Failed to resize $mpath"
    else
        echo "Invalid mpath: $mpath does not exist!"
    fi
done

# Rescan disks
# Define 'disks' variable for checking anyone device
disks=($DISK_PATH/$DISK_PREFIX[a-z])

echo "Starting rescan all disks..."

for disk in "${disks[@]}"; do
    echo "Rescanning $disk"
    echo 1 > "$disk/device/rescan"
    check_error "Failed to rescan $disk"
done

echo "Rescaning completed."

# Rescan all SCSI hosts
# I use 'continue' because I'm not sure I'll get all the values from $scsi_host_path
echo "Rescaning all SCSI hosts"

for host_path in $SCSI_HOST_PATH/host*; do
    [ -e "$host_path" ] || continue
    echo "- - -" > "$host_path/scan"
    check_error "Failed to rescan $host_path"
done

echo "Rescaning completed."

# Use partprobe for hard scan of all devices
# But remember, it may be dangerous
echo "Hard scanning all devices via partprobe"
partprobe
check_error "Failed to hard scan all devices"

echo "All manipulations has been complited!"

    

