# sameer.kubernetes Collection

This local collection contains the Kubernetes roles used by the Ansible kubeadm playbook in this repository.

## Included Roles

- `sameer.kubernetes.kubeadm_common`
- `sameer.kubernetes.kubeadm_control_plane`
- `sameer.kubernetes.kubeadm_worker_join`

## Usage

Run the playbook from the project root:

```bash
cd /Users/sameeralam/Documents/GitHub/kubernetes-setup/ansible
ansible-playbook kubeadm-cluster.yml -K
```

Edit `inventory/hosts.yml` before running the playbook so it matches your control-plane and worker nodes.
