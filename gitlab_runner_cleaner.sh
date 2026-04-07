#!/bin/bash
set -euo pipefail

echo "⚙️ Cleaning up unused Docker resources..."

docker image prune -af || true
docker container prune -f || true
docker volume prune -f || true
docker builder prune -af || true

echo
echo "🧹 Stopping GitLab Runner..."
docker stop gitlab-runner || true

echo
echo "🧹 Removing GitLab Runner cache volumes..."
docker volume ls -q | grep '^runner-.*-project-.*-cache-' | xargs -r docker volume rm || true

echo
echo "🧹 Removing buildx state..."
docker rm -f buildx_buildkit_ci-builder0 || true
docker volume rm buildx_buildkit_ci-builder0_state || true

echo
echo "▶️ Starting GitLab Runner back..."
docker start gitlab-runner || true

echo
echo "📦 Docker disk usage:"
docker system df

echo
echo "💽 Filesystem usage:"
df -h

echo
echo "✅ Cleanup completed."
