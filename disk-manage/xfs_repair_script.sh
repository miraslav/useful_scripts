#!/bin/bash

current_date=$(date +"%Y%m%d_%H%M%S")
log_file="/root/repair_log_$current_date.txt"
partition_to_repair="/dev/mapper/VG_DB-lv_db"
xfs_repair_command="/sbin/xfs_repair"

# Функция для выполнения xfs_repair
run_xfs_repair() {
    partition=$1
    $xfs_repair_command -L "$partition" >> "$log_file" 2>&1
    return $?
}

# Запуск xfs_repair только для указанного раздела
run_xfs_repair "$partition_to_repair"
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "Success: $partition_to_repair" >> "$log_file"
else
    echo "Error: $partition_to_repair" >> "$log_file"
fi

if grep -q "Error" "$log_file"; then
    echo "Errors found. Check $log_file for details."
    exit 1
else
    echo "Repair process completed successfully. Check $log_file for details."
    exit 0
fi


