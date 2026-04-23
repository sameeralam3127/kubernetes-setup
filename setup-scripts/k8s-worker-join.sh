#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 \"kubeadm join ...\""
  exit 1
fi

JOIN_CMD="$*"

echo "Joining worker node to the cluster..."
sudo ${JOIN_CMD}
echo "Worker node joined successfully"
