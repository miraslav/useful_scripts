#!/bin/bash
# Read names or addresses from urls.txt, one per line.
set -euo pipefail

input_file="${1:-urls.txt}"

if [[ ! -f "$input_file" ]]; then
  echo "Input file not found: $input_file"
  exit 1
fi

while IFS= read -r addr || [[ -n "$addr" ]]; do
  [[ -z "$addr" || "$addr" =~ ^# ]] && continue
  lookup=$(nslookup "$addr" 2>&1 || true)
  if grep -q "can't find" <<<"$lookup"; then
    echo "$addr Can't find DNS record"
  else
    echo "$addr $(grep 'Address:' <<<"$lookup" | tail -n +2)"
  fi
done < "$input_file"
