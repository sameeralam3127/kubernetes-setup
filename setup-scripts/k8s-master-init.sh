#!/usr/bin/env bash
set -euo pipefail

POD_NETWORK_CIDR="${POD_NETWORK_CIDR:-192.168.0.0/16}"
CALICO_MANIFEST_URL="${CALICO_MANIFEST_URL:-https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml}"
CONTROL_PLANE_IP="${CONTROL_PLANE_IP:-$(hostname -I | awk '{print $1}')}"

echo "Initializing the Kubernetes control plane on ${CONTROL_PLANE_IP}..."

sudo kubeadm init \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --pod-network-cidr="${POD_NETWORK_CIDR}" \
  --cri-socket=unix:///run/containerd/containerd.sock

mkdir -p "${HOME}/.kube"
sudo cp /etc/kubernetes/admin.conf "${HOME}/.kube/config"
sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"

echo "Installing Calico CNI from ${CALICO_MANIFEST_URL}..."
kubectl apply -f "${CALICO_MANIFEST_URL}"

echo
echo "Control plane is ready."
echo "Use the command below on each worker node:"
sudo kubeadm token create --print-join-command
