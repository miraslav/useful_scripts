#!/bin/bash
# Usage: add_multiple_users_to_group.sh group user1 user2 user3
set -euo pipefail

if (($# < 2)); then
  echo "Usage: $0 group user [user ...]"
  exit 1
fi

group=$1
shift

for user in "$@"; do
  usermod -aG "$group" "$user"
  echo "Added $user to $group"
done
