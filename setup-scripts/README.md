# kubeadm Cluster Setup on Multipass

This folder contains the manual `kubeadm` setup flow for a small local Kubernetes cluster on Multipass VMs.

The scripts are aligned with the Kubernetes `install-kubeadm` guidance for the `pkgs.k8s.io` package repository and use:

- 1 control plane node
- 2 worker nodes
- `containerd` as the container runtime
- Calico as the CNI plugin

## Files

- `create-vms.sh`: creates the Multipass VMs
- `k8s-common.sh`: installs and configures the required Kubernetes components on every node
- `k8s-master-init.sh`: initializes the control plane and applies Calico
- `k8s-worker-join.sh`: joins a worker node using the `kubeadm join` command from the control plane

## Prerequisites

Install these on your macOS host before you begin:

- Multipass
- Bash or a compatible shell
- internet access for package and image downloads
- `kubectl` on your host if you want to inspect the cluster from macOS

Verify Multipass:

```bash
multipass version
```

## Architecture

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

## Step 1: Create the VMs

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/setup-scripts
./create-vms.sh
```

Verify:

```bash
multipass list
```

## Step 2: Install Kubernetes Components on Every Node

Copy the shared install script to the control plane and both workers:

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/setup-scripts

for node in k8s-master k8s-worker-1 k8s-worker-2; do
  multipass transfer k8s-common.sh "${node}:/home/ubuntu/k8s-common.sh"
done
```

Run it on each node:

```bash
for node in k8s-master k8s-worker-1 k8s-worker-2; do
  multipass exec "${node}" -- bash /home/ubuntu/k8s-common.sh
done
```

What `k8s-common.sh` does:

- disables swap and comments swap entries in `/etc/fstab`
- enables the required kernel modules and networking sysctls
- installs and configures `containerd`
- sets `SystemdCgroup = true` in the `containerd` config
- installs `kubelet`, `kubeadm`, and `kubectl` from the Kubernetes `v1.35` package repository

If you want a different Kubernetes minor version, set `KUBERNETES_VERSION` when running the script:

```bash
multipass exec k8s-master -- env KUBERNETES_VERSION=v1.34 bash /home/ubuntu/k8s-common.sh
```

## Step 3: Initialize the Control Plane

Copy and run the control-plane script:

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/setup-scripts
multipass transfer k8s-master-init.sh k8s-master:/home/ubuntu/k8s-master-init.sh
multipass exec k8s-master -- bash /home/ubuntu/k8s-master-init.sh
```

This step:

- runs `kubeadm init`
- points Kubernetes to the `containerd` CRI socket
- configures `kubectl` for the `ubuntu` user
- installs Calico
- prints the join command for worker nodes

Optional overrides:

```bash
multipass exec k8s-master -- env POD_NETWORK_CIDR=192.168.0.0/16 bash /home/ubuntu/k8s-master-init.sh
```

Save the `kubeadm join ...` command printed at the end.

## Step 4: Join the Worker Nodes

Copy the worker join helper:

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/setup-scripts
multipass transfer k8s-worker-join.sh k8s-worker-1:/home/ubuntu/k8s-worker-join.sh
multipass transfer k8s-worker-join.sh k8s-worker-2:/home/ubuntu/k8s-worker-join.sh
```

Run the join command on each worker:

```bash
multipass exec k8s-worker-1 -- bash /home/ubuntu/k8s-worker-join.sh "kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
multipass exec k8s-worker-2 -- bash /home/ubuntu/k8s-worker-join.sh "kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
```

Example:

```bash
multipass exec k8s-worker-1 -- bash /home/ubuntu/k8s-worker-join.sh "kubeadm join 10.0.0.10:6443 --token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:xxxxxxxx"
```

## Step 5: Verify the Cluster

Check node status from the control plane:

```bash
multipass exec k8s-master -- kubectl get nodes -o wide
```

Expected shape:

```text
NAME           STATUS   ROLES           AGE   VERSION
k8s-master     Ready    control-plane   2m    v1.35.x
k8s-worker-1   Ready    <none>          1m    v1.35.x
k8s-worker-2   Ready    <none>          1m    v1.35.x
```

## Optional Smoke Test

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
- It is not a production cluster deployment pattern.
- The Kubernetes docs recommend installing a supported container runtime before using `kubeadm`; these scripts use `containerd`.
