#!/bin/bash
# Jenkins LTS on Ubuntu. Needs the 2026 repository signing key.
# https://www.jenkins.io/doc/book/installing/linux/
set -euo pipefail

sudo apt update
sudo apt install -y fontconfig openjdk-21-jre ca-certificates curl wget
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins

echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
