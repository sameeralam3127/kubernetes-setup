# Kubernetes Ansible Setup

This folder contains a clean Ansible implementation of the kubeadm setup flow used in `setup-scripts`.

## Files

- `kubeadm-cluster.yml`: main playbook
- `ansible.cfg`: local Ansible configuration for this project
- `inventory/hosts.yml`: default inventory to edit with your real node IPs
- `inventory/k8s-hosts.example.yml`: reference inventory example
- `inventory/group_vars/kube_cluster.yml`: shared Kubernetes settings
- `collections/requirements.yml`: required Ansible collections

## Roles

- `sameer.kubernetes.kubeadm_common`: prepares every node
- `sameer.kubernetes.kubeadm_control_plane`: initializes the control plane and installs Calico
- `sameer.kubernetes.kubeadm_worker_join`: joins worker nodes

## Before You Run

1. Update [/Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible/inventory/hosts.yml](/Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible/inventory/hosts.yml) with your real control-plane and worker IP addresses.
2. Make sure SSH access works for all nodes.
3. Make sure the remote user can use `sudo`.
4. Install the required collections:

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible
ansible-galaxy collection install -r collections/requirements.yml
```

## Inventory Layout

The playbook expects these groups:

- `kube_cluster`
- `kube_control_plane`
- `kube_workers`

Default example:

```yaml
all:
  children:
    kube_cluster:
      children:
        kube_control_plane:
          hosts:
            k8s-master:
              ansible_host: 192.168.64.10
              ansible_user: ubuntu
        kube_workers:
          hosts:
            k8s-worker-1:
              ansible_host: 192.168.64.11
              ansible_user: ubuntu
            k8s-worker-2:
              ansible_host: 192.168.64.12
              ansible_user: ubuntu
```

## Run The Playbook

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible
ansible-playbook kubeadm-cluster.yml -K
```

If you want to use the example inventory explicitly:

```bash
ansible-playbook -i inventory/k8s-hosts.example.yml kubeadm-cluster.yml -K
```

## What It Does

- disables swap
- configures kernel modules and sysctl values required by Kubernetes
- installs and configures `containerd`
- installs `kubelet`, `kubeadm`, and `kubectl` from the Kubernetes `v1.35` package repository
- initializes the control plane
- applies Calico
- generates the worker join command automatically
- joins all worker nodes

## Customize

You can change shared settings in [/Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible/inventory/group_vars/kube_cluster.yml](/Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible/inventory/group_vars/kube_cluster.yml), including:

- `kubernetes_version`
- `pod_network_cidr`
- `calico_manifest_url`
- `kubeconfig_user`
