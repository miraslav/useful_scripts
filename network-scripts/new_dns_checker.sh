#!/bin/bash
# Reverse-lookup each address in ips.txt and append the result to dns_check_out.txt.
set -euo pipefail

input_file="${1:-ips.txt}"
output_file="${2:-dns_check_out.txt}"

if [[ ! -f "$input_file" ]]; then
  echo "Input file not found: $input_file"
  exit 1
fi

counter=1
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  dns_record=$(nslookup "$line" 2>/dev/null | awk '/name =/ { print $4; exit }')
  {
    echo "Record $counter: IP address - $line, DNS record - ${dns_record:-none}"
    if [[ -z "$dns_record" ]]; then
      echo "Can't find DNS record"
    else
      echo "DNS record exists"
    fi
  } >> "$output_file"
  counter=$((counter + 1))
done < "$input_file"

echo "Wrote results to $output_file"
