# Kubernetes Local Lab on macOS

This repository is a practical Kubernetes learning lab for macOS. It helps you understand the stack from the Linux kernel level up to a working cluster, and it gives you multiple ways to run Kubernetes locally:

- Docker Desktop Kubernetes
- Kind
- Minikube
- K3s
- kubeadm on Multipass
- Rancher Desktop
- Podman for container workflows

It also includes a small FastAPI + PostgreSQL sample app so you can practice image builds, deployments, services, ingress, storage, and troubleshooting.

## Who This Repo Is For

Use this repo if you want to:

- learn Kubernetes in a practical way on macOS
- compare local cluster options before choosing one
- understand how OCI, CRI, `runc`, namespaces, and cgroups fit together
- practice with control plane and worker node components
- publish a clean public repo that others can follow

## Recommended Learning Path

If you already have Docker Desktop with Kubernetes enabled, start here:

1. Use Docker Desktop Kubernetes for your first workloads.
2. Use Kind when you want repeatable multi-node test clusters.
3. Use Minikube when you want a feature-rich single-node learning environment.
4. Use K3s when you want a lightweight distro close to edge and homelab setups.
5. Use kubeadm on Multipass when you want to learn "upstream-style" Kubernetes components and node bootstrapping in more detail.

## Repository Structure

- `app/`: sample FastAPI app
- `docs/`: architecture, setup, and troubleshooting guides
- `k8s/`: Kubernetes manifests for the sample app
- `setup-scripts/`: hands-on Multipass and kubeadm cluster setup

## Start Here

Choose the path that matches your goal:

- Use Docker Desktop Kubernetes if you want the fastest start.
- Use Kind if you want repeatable throwaway clusters.
- Use Minikube if you want a flexible local learning environment.
- Use K3s if you want a lightweight Kubernetes distribution.
- Use `setup-scripts/` if you want the deepest practical understanding of cluster bootstrapping.

## Quick Start

### Option 1: Docker Desktop Kubernetes

Prerequisites:

- Docker Desktop installed
- Kubernetes enabled in Docker Desktop settings
- `kubectl` installed on macOS

Verify:

```bash
kubectl config current-context
kubectl get nodes
```

Build and deploy:

```bash
docker build -t fastapi-app:local .
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/app.yaml
kubectl apply -f k8s/ingress.yaml
kubectl get pods,svc,ingress
```

Because Docker Desktop uses its own image store, the `fastapi-app:local` image is available directly to the local cluster.

### Option 2: Kind

Install Kind and create a cluster:

```bash
kind create cluster --name local-lab
kubectl cluster-info --context kind-local-lab
```

Load your image into Kind:

```bash
docker build -t fastapi-app:local .
kind load docker-image fastapi-app:local --name local-lab
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/app.yaml
```

### Option 3: Minikube

Start Minikube with Docker as the driver:

```bash
minikube start --driver=docker
eval "$(minikube docker-env)"
docker build -t fastapi-app:local .
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/app.yaml
```

### Option 4: K3s

For a lightweight distro, use a Linux VM through Multipass and install K3s:

```bash
multipass launch 22.04 --name k3s-server --cpus 2 --memory 4G --disk 20G
multipass exec k3s-server -- bash -lc "curl -sfL https://get.k3s.io | sh -"
multipass exec k3s-server -- sudo kubectl get nodes
```

Copy kubeconfig back to macOS if needed:

```bash
multipass exec k3s-server -- sudo cat /etc/rancher/k3s/k3s.yaml
```

### Option 5: kubeadm on Multipass

Use [setup-scripts/README.md](setup-scripts/README.md) when you want hands-on practice with `kubeadm`, `containerd`, CNI setup, and worker node joining.

## macOS Tooling Choices

### Docker Desktop

Best for:

- easiest startup
- built-in Kubernetes
- smooth developer UX on macOS

Tradeoffs:

- heavier resource usage
- licensing considerations for some organizations

### Rancher Desktop

Best for:

- Docker Desktop alternative
- K3s-based local Kubernetes
- choice of `containerd` or `dockerd`

Tradeoffs:

- slightly different workflow than Docker Desktop
- image handling depends on runtime choice

### Podman

Best for:

- daemonless container workflows
- users who want Docker-compatible CLI behavior without Docker Desktop

Tradeoffs:

- Kubernetes experience is not as straightforward as Docker Desktop, Kind, or Minikube on macOS
- often used more for container workflows than as the first-choice local Kubernetes platform

### Multipass

Best for:

- real Linux VMs on macOS
- learning kubeadm or K3s in a more realistic Linux environment

Tradeoffs:

- slower than container-based local clusters
- more VM management overhead

## Kubernetes Options Compared

| Tool                      | What It Is                                         | Best Use                        | Notes                                        |
| ------------------------- | -------------------------------------------------- | ------------------------------- | -------------------------------------------- |
| Docker Desktop Kubernetes | Single-node Kubernetes bundled with Docker Desktop | fastest local start             | easiest if already installed                 |
| Kind                      | Kubernetes in Docker containers                    | testing and repeatable clusters | ideal for CI-like workflows                  |
| Minikube                  | local Kubernetes runner with many drivers          | learning and add-ons            | very flexible                                |
| K3s                       | lightweight Kubernetes distro                      | edge, homelab, lightweight labs | simpler and smaller than upstream Kubernetes |
| kubeadm + Multipass       | upstream-style cluster bootstrapping in VMs        | deep learning                   | best for understanding cluster internals     |
| Rancher Desktop           | desktop app bundling container runtime + K3s       | Docker Desktop alternative      | good GUI-driven option                       |

## Learn The Internals

Read these next:

- [docs/README.md](docs/README.md)
- [docs/macos-setup.md](docs/macos-setup.md)
- [docs/kubernetes-architecture.md](docs/kubernetes-architecture.md)
- [docs/container-runtime-stack.md](docs/container-runtime-stack.md)
- [docs/troubleshooting.md](docs/troubleshooting.md)
- [setup-scripts/README.md](setup-scripts/README.md)

## Sample App Deployment Notes

The sample app uses:

- FastAPI
- PostgreSQL
- Kubernetes `Deployment`
- Kubernetes `Service`
- Kubernetes `Ingress`
- a persistent volume claim for Postgres

To inspect resources:

```bash
kubectl get all
kubectl get pvc
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

## Cleanup Commands

Kind:

```bash
kind delete cluster --name local-lab
```

Minikube:

```bash
minikube delete
```

Docker Desktop:

Delete the resources:

```bash
kubectl delete -f k8s/ingress.yaml --ignore-not-found
kubectl delete -f k8s/app.yaml --ignore-not-found
kubectl delete -f k8s/postgres.yaml --ignore-not-found
```

Multipass:

```bash
multipass delete --all
multipass purge
```

## Important Note

This repo is designed for learning and local development. It is not a production-grade cluster automation project. For production, you would add stronger security, secrets management, observability, upgrade strategy, backup strategy, ingress hardening, and proper storage classes.
