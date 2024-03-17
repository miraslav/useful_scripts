#!/bin/bash

#Attention! It doesn't work for older (depreciate) OS version like a 5,6 (RHEL-based)

# Get the hostname
hostname=$(hostname)

# Get the IP address
ip_address=$(ip addr | grep 'UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

# Get the uptime in a human-readable format
uptime=$(uptime --pretty)

# Get the operating system information
os_info=$(grep PRETTY_NAME /etc/*release | awk -F'=' '{print $2}' | tr -d '"')

# Define the message to display
message="
Welcome to the Linux Server!

Hostname: $hostname
    IP Address: $ip_address
        Uptime: $uptime
            Operating System: $os_info

Here are some important tips:
- Please be respectful and considerate of other users.
- Use the server resources wisely and avoid any actions that may slow down the system for others.
- If you need help, please reach out to the administrator.

Enjoy your work and have a great day!
"

# Backup the current MOTD
cp /etc/motd /root/motd.bak

# Add the message to the MOTD
echo "$message" > /etc/motd




# In this version of the script, the current MOTD is backed up using the cp /etc/motd /etc/motd.bak command. The rest of the script remains the same as in the previous version.