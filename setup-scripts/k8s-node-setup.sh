#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_common_setup() {
  bash "${SCRIPT_DIR}/k8s-common.sh"
}

run_control_plane_setup() {
  bash "${SCRIPT_DIR}/k8s-master-init.sh"
}

run_worker_join() {
  if [[ $# -eq 0 ]]; then
    read -r -p "Paste the full kubeadm join command: " join_cmd
  else
    join_cmd="$*"
  fi

  bash "${SCRIPT_DIR}/k8s-worker-join.sh" "${join_cmd}"
}

show_menu() {
  cat <<'EOF'
Choose an action:
1. Install node prerequisites only
2. Configure this node as the control plane
3. Join this node as a worker
4. Install prerequisites and configure as the control plane
5. Install prerequisites and join as a worker
EOF
}

interactive_mode() {
  show_menu
  read -r -p "Enter option [1-5]: " choice

  case "${choice}" in
    1)
      run_common_setup
      ;;
    2)
      run_control_plane_setup
      ;;
    3)
      run_worker_join
      ;;
    4)
      run_common_setup
      run_control_plane_setup
      ;;
    5)
      run_common_setup
      run_worker_join
      ;;
    *)
      echo "Invalid option: ${choice}"
      exit 1
      ;;
  esac
}

usage() {
  cat <<'EOF'
Usage:
  bash k8s-node-setup.sh
  bash k8s-node-setup.sh common
  bash k8s-node-setup.sh control-plane
  bash k8s-node-setup.sh worker-join "kubeadm join ..."
  bash k8s-node-setup.sh all-control-plane
  bash k8s-node-setup.sh all-worker "kubeadm join ..."

Modes:
  common             Install containerd, kubelet, kubeadm, and kubectl only
  control-plane      Run kubeadm init and install Calico
  worker-join        Join this node to an existing cluster
  all-control-plane  Run common setup, then initialize the control plane
  all-worker         Run common setup, then join as a worker

Environment variables:
  KUBERNETES_VERSION  Kubernetes package repo version, default: v1.35
  POD_NETWORK_CIDR    Pod CIDR for kubeadm init, default: 192.168.0.0/16
  CONTROL_PLANE_IP    IP advertised by kubeadm init, default: primary host IP
  CALICO_MANIFEST_URL Calico manifest URL
EOF
}

main() {
  mode="${1:-interactive}"

  case "${mode}" in
    interactive)
      interactive_mode
      ;;
    common)
      run_common_setup
      ;;
    control-plane)
      run_control_plane_setup
      ;;
    worker-join)
      shift || true
      run_worker_join "$@"
      ;;
    all-control-plane)
      run_common_setup
      run_control_plane_setup
      ;;
    all-worker)
      shift || true
      run_common_setup
      run_worker_join "$@"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      echo "Unknown mode: ${mode}"
      echo
      usage
      exit 1
      ;;
  esac
}

main "$@"
