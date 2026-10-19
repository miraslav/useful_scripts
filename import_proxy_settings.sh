#!/bin/bash
# Source this file: source ./import_proxy_settings.sh
# Override the address with PROXY_URL=http://host:port
proxy="${PROXY_URL:-http://10.8.54.68:9090}"
export http_proxy="$proxy"
export https_proxy="$proxy"
export HTTP_PROXY="$proxy"
export HTTPS_PROXY="$proxy"
export no_proxy="${NO_PROXY:-localhost,127.0.0.1}"
export NO_PROXY="$no_proxy"
