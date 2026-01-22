#!/bin/bash
set -e

echo "Creating Kubernetes nodes using Multipass..."

multipass launch 22.04 --name k8s-master --cpus 2 --memory 4G --disk 20G
multipass launch 22.04 --name k8s-worker-1 --cpus 2 --memory 4G --disk 20G
multipass launch 22.04 --name k8s-worker-2 --cpus 2 --memory 4G --disk 20G

echo "Nodes created:"
multipass list
