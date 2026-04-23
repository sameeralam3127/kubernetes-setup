# Sameer Kubernetes Ansible Project

## Included content/ Directory Structure

The directory structure follows best practices recommended by the Ansible
community. Feel free to customize this template according to your specific
project requirements.

```shell
 ansible-project/
 |── .devcontainer/
 |    └── docker/
 |        └── devcontainer.json
 |    └── podman/
 |        └── devcontainer.json
 |    └── devcontainer.json
 |── .github/
 |    └── workflows/
 |        └── tests.yml
 |    └── ansible-code-bot.yml
 |── .vscode/
 |    └── extensions.json
 |── collections/
 |   └── requirements.yml
 |   └── ansible_collections/
 |       └── project_org/
 |           └── project_repo/
 |               └── README.md
 |               └── roles/sample_role/
 |                         └── README.md
 |                         └── tasks/main.yml
 |── inventory/
 |   |── hosts.yml
 |   |── argspec_validation_inventory.yml
 |   └── groups_vars/
 |   └── host_vars/
 |── ansible-navigator.yml
 |── ansible.cfg
 |── devfile.yaml
 |── linux_playbook.yml
 |── network_playbook.yml
 |── README.md
 |── site.yml
```

## Compatible with Ansible-lint

Tested with ansible-lint >=24.2.0 releases and the current development version
of ansible-core.

## Kubernetes kubeadm playbook

This repository now includes a dedicated kubeadm cluster playbook and collection
roles for the same flow used in `setup-scripts`.

Files:

- `kubeadm-cluster.yml`: main playbook
- `inventory/k8s-hosts.example.yml`: example inventory for one control plane and two workers
- `inventory/group_vars/kube_cluster.yml`: shared Kubernetes variables
- `collections/ansible_collections/sameer/kubernetes/roles/kubeadm_common`: prepares every node
- `collections/ansible_collections/sameer/kubernetes/roles/kubeadm_control_plane`: runs `kubeadm init` and installs Calico
- `collections/ansible_collections/sameer/kubernetes/roles/kubeadm_worker_join`: joins worker nodes

Expected inventory groups:

- `kube_cluster`
- `kube_control_plane`
- `kube_workers`

Example run:

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible
ansible-playbook -i inventory/k8s-hosts.example.yml kubeadm-cluster.yml -K
```

What the playbook does:

- disables swap
- configures required kernel modules and sysctl settings
- installs and configures `containerd`
- installs `kubelet`, `kubeadm`, and `kubectl` from the Kubernetes `v1.35` repo
- initializes the control plane
- applies Calico
- generates a join command and uses it to join the worker nodes
