#!/bin/bash
set -e

sudo kubeadm join <MASTER_IP>:6443 \
 --token <TOKEN> \
 --discovery-token-ca-cert-hash sha256:<HASH>
