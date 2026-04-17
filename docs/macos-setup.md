# macOS Local Kubernetes Setup Guide

This guide helps you choose the right setup on macOS depending on what you want to learn.

## Option A: Docker Desktop

Use Docker Desktop when you want the fastest path from zero to a working cluster.

Steps:

1. Install Docker Desktop.
2. Enable Kubernetes in Docker Desktop settings.
3. Install `kubectl`:

```bash
brew install kubectl
```

4. Verify:

```bash
kubectl config get-contexts
kubectl get nodes
```

This is the best starting point if Docker Desktop is already installed on your machine.

## Option B: Rancher Desktop

Rancher Desktop is a strong Docker Desktop alternative on macOS and usually runs K3s under the hood.

Install:

```bash
brew install --cask rancher
```

Then:

1. open Rancher Desktop
2. choose Kubernetes version
3. choose runtime, usually `containerd`
4. wait for the cluster to become ready
5. verify with `kubectl get nodes`

Use Rancher Desktop if you want a desktop-managed K3s experience.

## Option C: Kind

Install:

```bash
brew install kind kubectl
```

Create a cluster:

```bash
kind create cluster --name local-lab
kubectl cluster-info --context kind-local-lab
```

Use Kind when you want:

- disposable clusters
- repeatable configs
- multi-node testing
- CI-style workflows

## Option D: Minikube

Install:

```bash
brew install minikube kubectl
```

Start:

```bash
minikube start --driver=docker
kubectl get nodes
```

Use Minikube when you want:

- add-ons like ingress and dashboard
- a flexible learning environment
- a simple one-cluster experience

## Option E: Multipass + K3s

Install Multipass:

```bash
brew install --cask multipass
```

Start K3s server:

```bash
multipass launch 22.04 --name k3s-server --cpus 2 --memory 4G --disk 20G
multipass exec k3s-server -- bash -lc "curl -sfL https://get.k3s.io | sh -"
multipass exec k3s-server -- sudo kubectl get nodes
```

Add an agent node:

```bash
TOKEN=$(multipass exec k3s-server -- sudo cat /var/lib/rancher/k3s/server/node-token)
SERVER_IP=$(multipass info k3s-server | awk '/IPv4/ {print $2; exit}')
multipass launch 22.04 --name k3s-agent-1 --cpus 2 --memory 2G --disk 15G
multipass exec k3s-agent-1 -- bash -lc "curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${TOKEN} sh -"
```

Use this path when you want lightweight real Linux nodes.

## Option F: Multipass + kubeadm

Use this when you want to understand upstream Kubernetes bootstrapping in detail:

- preparing Linux nodes
- installing `containerd`
- configuring `kubelet`
- running `kubeadm init`
- applying CNI
- joining worker nodes

See [../setup-scripts/README.md](/Users/sameeralam/Documents/GitHub/kubernetes-multipass-setup/setup-scripts/README.md) for the guided Multipass plus `kubeadm` workflow included in this repository.

## Podman on macOS

Podman is useful for building and running containers, but for local Kubernetes on macOS most learners get a smoother experience with Docker Desktop, Kind, Minikube, Rancher Desktop, or Multipass.

Install Podman:

```bash
brew install podman
podman machine init
podman machine start
podman info
```

Use Podman if you want to practice:

- OCI-compatible image builds
- container CLI workflows
- daemonless container tooling concepts

## Which One Should You Use?

- Start with Docker Desktop if you want speed.
- Use Kind if you want repeatability.
- Use Minikube if you want a rich local lab.
- Use K3s if you want lightweight Kubernetes.
- Use kubeadm on Multipass if you want the deepest learning experience.
