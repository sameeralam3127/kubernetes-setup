#!/usr/bin/env bash
set -euo pipefail

JOIN_CMD="$1"

if [[ -z "$JOIN_CMD" ]]; then
  echo "Usage: $0 \"kubeadm join ...\""
  exit 1
fi

echo "🔗 Joining node to Kubernetes cluster..."
sudo $JOIN_CMD
echo "✅ Node successfully joined"
