#!/bin/bash
set -euo pipefail
"$(dirname "$0")/get_empty_disk.sh" | head -n 8
