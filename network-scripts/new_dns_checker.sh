#!/bin/bash

# This script reads each line in the input file ips.txt, performs a DNS lookup using nslookup for each IP address, and outputs the results to the file dns_check_out.txt. If the DNS record exists, it writes "DNS record exists" to the file. If the DNS record does not exist, it writes "Can't find DNS record" to the file.


# Input file with IP addresses
input_file="ips.txt"

# Output file
output_file="dns_check_out.txt"

# Loop through each line in the input file
counter=1
while read line; do
    # Get the canonical name of the IP address
    dns_record=$(nslookup "$line" | grep "name =" | awk '{print $4}')

    # Write the results to the output file
    echo "Record $counter: IP address - $line, DNS record - $dns_record" >> "$output_file"

    # Check if the DNS record exists
    if [ -z "$dns_record" ]; then
        echo "Can't find DNS record" >> "$output_file"
    else
        echo "DNS record exists" >> "$output_file"
    fi

    # Increment the counter
    counter=$((counter + 1))
done < "$input_file"
