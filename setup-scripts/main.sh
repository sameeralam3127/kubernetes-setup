#!/usr/bin/env bash

# Basic package bootstrap for a fresh Ubuntu VM used in local Kubernetes labs.
# This helper is optional and not required for the kubeadm cluster workflow.

sudo apt-get update
sudo apt-get install -y build-essential git vim

sudo apt-get install -y python3 python3-pip
