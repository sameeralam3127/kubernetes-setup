#!/usr/bin/env bash
set -euo pipefail

MASTER="k8s-master"
WORKERS=("k8s-worker-1" "k8s-worker-2")

CPUS=2
MEMORY=4G
DISK=20G
IMAGE=22.04

echo "🚀 Creating Kubernetes VMs using Multipass..."

multipass launch "$IMAGE" \
  --name "$MASTER" \
  --cpus "$CPUS" \
  --memory "$MEMORY" \
  --disk "$DISK"

for w in "${WORKERS[@]}"; do
  multipass launch "$IMAGE" \
    --name "$w" \
    --cpus "$CPUS" \
    --memory "$MEMORY" \
    --disk "$DISK"
done

echo "✅ VMs created successfully"
multipass list
