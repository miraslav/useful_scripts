#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example. Set MYSQL_ROOT_PASSWORD, then run this script again."
  exit 1
fi

docker compose -f compose.yml --env-file .env up -d
docker compose -f compose.yml ps
