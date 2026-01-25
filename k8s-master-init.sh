#!/usr/bin/env bash
set -euo pipefail

MASTER_IP=$(hostname -I | awk '{print $1}')

echo "🚀 Initializing Kubernetes master..."

sudo kubeadm init \
  --apiserver-advertise-address="$MASTER_IP" \
  --pod-network-cidr=192.168.0.0/16

mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

echo "🌐 Installing Calico CNI..."

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

echo "📌 Kubernetes master initialized"
echo "👉 Run the join command on worker nodes:"
kubeadm token create --print-join-command
