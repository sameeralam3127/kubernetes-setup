# Kubernetes Cluster on Multipass (1 Master + 2 Workers)

This project provides **step-by-step Bash scripts** to create a **local Kubernetes cluster** using **Multipass** with:

- 1 Control Plane (Master)
- 2 Worker Nodes
- `kubeadm` + `containerd`
- Calico CNI

---

## 📌 Architecture Overview

```
Host Machine
│
├── k8s-master
│   ├── kube-apiserver
│   ├── controller-manager
│   └── scheduler
│
├── k8s-worker-1
│   └── kubelet + kube-proxy
│
└── k8s-worker-2
    └── kubelet + kube-proxy
```

---

## 🧰 Prerequisites

Make sure the following are installed on your **host machine**:

- **Multipass**
- **Bash shell**
- Internet access

### Verify Multipass

```bash
multipass version
```

---

## 📂 Project Structure

```
.
├── create-vms.sh
├── k8s-common.sh
├── k8s-master-init.sh
├── k8s-worker-join.sh
└── README.md
```

---

## 🚀 Step 1: Create Virtual Machines

This script creates:

- 1 master node
- 2 worker nodes

### Script

```bash
./create-vms.sh
```

### What it does

- Launches Ubuntu 22.04 VMs
- Allocates CPU, memory, and disk
- Names nodes consistently

### Verify

```bash
multipass list
```

Expected output:

```
k8s-master
k8s-worker-1
k8s-worker-2
```

---

## ⚙️ Step 2: Install Kubernetes Prerequisites (ALL NODES)

This step prepares **every node**.

### Script

```bash
k8s-common.sh
```

### What it does

- Disables swap (required by Kubernetes)
- Enables kernel modules
- Installs:
  - containerd
  - kubelet
  - kubeadm
  - kubectl

### Run on master

```bash
multipass exec k8s-master -- bash k8s-common.sh
```

### Run on workers

```bash
multipass exec k8s-worker-1 -- bash k8s-common.sh
multipass exec k8s-worker-2 -- bash k8s-common.sh
```

---

## 🧠 Step 3: Initialize Kubernetes Master Node

This step **bootstraps the control plane**.

### Script

```bash
k8s-master-init.sh
```

### Run

```bash
multipass exec k8s-master -- bash k8s-master-init.sh
```

### What it does

- Initializes Kubernetes using `kubeadm`
- Configures kubectl access
- Installs **Calico CNI**
- Prints the **join command** for workers

⚠️ **Save the join command output** — you will need it next.

---

## 🔗 Step 4: Join Worker Nodes to Cluster

Workers join the master using the join command.

### Script

```bash
k8s-worker-join.sh
```

### Example Join Command

```bash
kubeadm join 10.0.0.10:6443 \
  --token abcdef.123456 \
  --discovery-token-ca-cert-hash sha256:xxxxxxxx
```

### Run on each worker

```bash
multipass exec k8s-worker-1 -- bash k8s-worker-join.sh "<JOIN_COMMAND>"
multipass exec k8s-worker-2 -- bash k8s-worker-join.sh "<JOIN_COMMAND>"
```

---

## ✅ Step 5: Verify Kubernetes Cluster

Run from the master node:

```bash
kubectl get nodes
```

Expected output:

```
NAME           STATUS   ROLES           AGE   VERSION
k8s-master     Ready    control-plane   2m    v1.29.x
k8s-worker-1   Ready    <none>           1m    v1.29.x
k8s-worker-2   Ready    <none>           1m    v1.29.x
```

---

## 🌐 Optional: Test with Sample App

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pods,svc
```

---

## 🧹 Cleanup (Optional)

To delete everything:

```bash
multipass delete k8s-master k8s-worker-1 k8s-worker-2
multipass purge
```

---

## 🛡️ Best Practices Used

- `containerd` instead of Docker
- Swap disabled
- Kernel networking configured
- Version-pinned Kubernetes
- Modular, reusable scripts
- Strict Bash (`set -euo pipefail`)

---

## 📘 Notes

- This setup is for **learning, testing, and development**
- Not recommended for production
- Works on Linux & macOS hosts
