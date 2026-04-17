# kubeadm Cluster Setup on Multipass

This folder contains the most hands-on setup path in the repository. It shows how to create a local Kubernetes cluster on Multipass using `kubeadm`, `containerd`, and Calico.

Use this path when you want to understand what happens below tools like Docker Desktop, Kind, Minikube, K3s, or Rancher Desktop.

## What This Setup Creates

- 1 control plane node
- 2 worker nodes
- `containerd` as the container runtime
- Calico as the CNI plugin

## Why This Folder Matters

This is the best folder for learners who want practical understanding of:

- control plane versus worker responsibilities
- node preparation and Linux prerequisites
- `kubeadm init` and `kubeadm join`
- `containerd`, `kubelet`, and Kubernetes networking basics

If you want the fastest path to a working cluster, use one of the options in the root [README.md](/Users/sameeralam/Documents/GitHub/kubernetes-multipass-setup/README.md) instead.

File purpose:

- `create-vms.sh`: creates one control plane VM and two worker VMs
- `k8s-common.sh`: installs Kubernetes prerequisites on every node
- `k8s-master-init.sh`: initializes the control plane and installs Calico
- `k8s-worker-join.sh`: joins a worker node to the cluster
- `main.sh`: optional Ubuntu package bootstrap helper

## Architecture Overview

```text
Host Machine
|
|-- k8s-master
|   |-- kube-apiserver
|   |-- kube-controller-manager
|   `-- kube-scheduler
|
|-- k8s-worker-1
|   `-- kubelet + kube-proxy
|
`-- k8s-worker-2
    `-- kubelet + kube-proxy
```

## Prerequisites

Install these on your macOS host:

- Multipass
- Bash or a compatible shell
- `kubectl` on your host if you want to inspect the cluster locally
- internet access for package and image downloads

Verify Multipass:

```bash
multipass version
```

## Workflow

### Step 1: Create Virtual Machines

```bash
cd setup-scripts
./create-vms.sh
```

This creates:

- `k8s-master`
- `k8s-worker-1`
- `k8s-worker-2`

Verify:

```bash
multipass list
```

### Step 2: Install Kubernetes Prerequisites On Every Node

Run the common setup script on the control plane and each worker:

```bash
cd setup-scripts
multipass transfer k8s-common.sh k8s-master:/home/ubuntu/k8s-common.sh
multipass transfer k8s-common.sh k8s-worker-1:/home/ubuntu/k8s-common.sh
multipass transfer k8s-common.sh k8s-worker-2:/home/ubuntu/k8s-common.sh

multipass exec k8s-master -- bash /home/ubuntu/k8s-common.sh
multipass exec k8s-worker-1 -- bash /home/ubuntu/k8s-common.sh
multipass exec k8s-worker-2 -- bash /home/ubuntu/k8s-common.sh
```

This script:

- disables swap
- configures kernel networking parameters
- installs `containerd`
- installs `kubelet`, `kubeadm`, and `kubectl`

### Step 3: Initialize The Control Plane

```bash
cd setup-scripts
multipass transfer k8s-master-init.sh k8s-master:/home/ubuntu/k8s-master-init.sh
multipass exec k8s-master -- bash /home/ubuntu/k8s-master-init.sh
```

This step:

- runs `kubeadm init`
- configures `kubectl`
- installs Calico
- prints the worker join command

Save the join command because you will use it in the next step.

### Step 4: Join The Worker Nodes

Copy the worker join script and run it with the join command produced in step 3:

```bash
cd setup-scripts
multipass transfer k8s-worker-join.sh k8s-worker-1:/home/ubuntu/k8s-worker-join.sh
multipass transfer k8s-worker-join.sh k8s-worker-2:/home/ubuntu/k8s-worker-join.sh

multipass exec k8s-worker-1 -- bash /home/ubuntu/k8s-worker-join.sh "<JOIN_COMMAND>"
multipass exec k8s-worker-2 -- bash /home/ubuntu/k8s-worker-join.sh "<JOIN_COMMAND>"
```

Example join command:

```bash
kubeadm join 10.0.0.10:6443 \
  --token abcdef.123456 \
  --discovery-token-ca-cert-hash sha256:xxxxxxxx
```

### Step 5: Verify The Cluster

Run from the master node:

```bash
multipass exec k8s-master -- kubectl get nodes
```

Expected result:

```text
NAME           STATUS   ROLES           AGE   VERSION
k8s-master     Ready    control-plane   2m    v1.29.x
k8s-worker-1   Ready    <none>          1m    v1.29.x
k8s-worker-2   Ready    <none>          1m    v1.29.x
```

## Optional Test Workload

```bash
multipass exec k8s-master -- kubectl create deployment nginx --image=nginx
multipass exec k8s-master -- kubectl expose deployment nginx --port=80 --type=NodePort
multipass exec k8s-master -- kubectl get pods,svc
```

## Cleanup

```bash
multipass delete k8s-master k8s-worker-1 k8s-worker-2
multipass purge
```

## Notes

- This setup is intended for learning, testing, and development.
- It is not intended as a production cluster deployment pattern.
- It works especially well when you want to understand Kubernetes components in a more realistic Linux environment.
