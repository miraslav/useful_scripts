#!/bin/bash

# Retrieve mpath values from pvs command output
mapaths=$(pvs --noheadings -o pv_name | awk '{print $1}')

# Check if there are no mpath values
if [[ -z "$mapaths" ]]; then
  echo "No mpath found. Exiting..."
  exit 1
fi

# Iterate over each mpath and attempt to run pvresize command
for mpath in $mapaths; do
  # Check if the mpath exists
  if [[ -e "$mpath" ]]; then
    pvresize "$mpath"
  else
    echo "Invalid mpath: $mpath does not exist."
  fi
done

