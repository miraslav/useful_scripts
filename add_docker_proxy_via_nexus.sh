#!/bin/bash
# Point the Docker daemon at an HTTP proxy. Override with HTTP_PROXY=...
set -euo pipefail

proxy="${HTTP_PROXY:-http://10.8.54.68:9090}"
dropin_dir="/etc/systemd/system/docker.service.d"
dropin_file="${dropin_dir}/http-proxy.conf"

mkdir -p "$dropin_dir"
cat > "$dropin_file" <<EOF
[Service]
Environment="HTTP_PROXY=${proxy}"
Environment="HTTPS_PROXY=${proxy}"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

systemctl daemon-reload
systemctl restart docker
echo "Docker proxy set to ${proxy}"
