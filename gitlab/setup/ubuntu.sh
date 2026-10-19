#!/bin/bash
# GitLab EE on Ubuntu 22.04 / 24.04.
# https://docs.gitlab.com/install/package/ubuntu/
set -euo pipefail

: "${EXTERNAL_URL:?Set EXTERNAL_URL, for example: EXTERNAL_URL=https://gitlab.example.com $0}"

sudo apt update
sudo apt install -y curl openssh-server ca-certificates
curl --location "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh" | sudo bash
sudo EXTERNAL_URL="$EXTERNAL_URL" apt install -y gitlab-ee

echo "Root password is in /etc/gitlab/initial_root_password and is deleted after 24 hours."
