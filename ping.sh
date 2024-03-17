#!/bin/bash

output_file="output_$(date +"%Y%m%d_%H%M%S").txt"

while IFS= read -r server
do
    ping_result=$(ping -c 1 "$server" 2>/dev/null)

    ttl=$(echo "$ping_result" | grep -oP "(?<=ttl=)\d+")

    if [[ $ttl -ge 57 && $ttl -lt 100 ]]; then
        echo "Linux: $server is reachable (TTL: $ttl)" >> "$output_file"
    elif [[ $ttl -ge 115 ]]; then
        echo "Windows: $server is reachable (TTL: $ttl)" >> "$output_file"
    else
        echo "Unknown: $server is unreachable or TTL value not in range (TTL: $ttl)" >> "$output_file"
    fi
done < server_list.txt
