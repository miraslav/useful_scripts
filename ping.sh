#!/bin/bash
# Read hosts from server_list.txt and record which ones answer ping.
set -euo pipefail

input_file="${1:-server_list.txt}"
output_file="output_$(date +"%Y%m%d_%H%M%S").txt"

if [[ ! -f "$input_file" ]]; then
  echo "Host list not found: $input_file"
  exit 1
fi

while IFS= read -r server || [[ -n "$server" ]]; do
  [[ -z "$server" || "$server" =~ ^# ]] && continue
  if ping -c 1 -W 2 "$server" >/dev/null 2>&1; then
    echo "reachable: $server" | tee -a "$output_file"
  else
    echo "unreachable: $server" | tee -a "$output_file"
  fi
done < "$input_file"
