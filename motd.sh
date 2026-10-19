#!/bin/bash
set -euo pipefail

hostname=$(hostname)
ip_address=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i == "src") { print $(i + 1); exit } }')
uptime=$(uptime --pretty)
os_info=$(awk -F= '/^PRETTY_NAME=/{ gsub(/"/, "", $2); print $2; exit }' /etc/os-release)

message="
Welcome to the Linux Server!

Hostname: ${hostname}
IP Address: ${ip_address:-unknown}
Uptime: ${uptime}
Operating System: ${os_info}

Here are some important tips:
- Please be respectful and considerate of other users.
- Use the server resources wisely and avoid any actions that may slow down the system for others.
- If you need help, please reach out to the administrator.

Enjoy your work and have a great day!
"

if [[ -f /etc/motd ]]; then
  cp /etc/motd /root/motd.bak
fi
printf '%s\n' "$message" > /etc/motd
echo "MOTD updated. Previous file, if any, is /root/motd.bak"
