#!/bin/bash
set -e

echo "Installing MetalLB..."

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

echo "Waiting for MetalLB pods..."
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=component=controller \
  --timeout=120s

echo "MetalLB installed."
