# Kubernetes Architecture Notes

This file explains the main Kubernetes components in practical terms.

## High-Level Model

A Kubernetes cluster usually has:

- control plane nodes
- worker nodes

The control plane makes decisions about the cluster. Worker nodes run your application pods.

## Control Plane

The control plane is the "brain" of Kubernetes.

### kube-apiserver

The `kube-apiserver` is the front door of the cluster. Almost every operation goes through it:

- `kubectl` talks to the API server
- controllers talk to the API server
- the scheduler talks to the API server
- kubelets report state back through the API server

If the API server is down, your cluster cannot be managed correctly.

### etcd

`etcd` is the key-value store that holds the cluster state:

- deployments
- services
- configmaps
- secrets
- node information
- leader election data

If you lose `etcd` without backups, you effectively lose your cluster state.

### kube-scheduler

The `kube-scheduler` decides where unscheduled pods should run. It looks at:

- CPU and memory requests
- taints and tolerations
- affinity and anti-affinity rules
- node selectors
- topology constraints

It does not run containers itself. It only assigns pods to nodes.

### kube-controller-manager

The `kube-controller-manager` runs controllers that continuously compare desired state with actual state.

Examples:

- deployment controller
- replica set controller
- node controller
- job controller
- endpoint controller

If a deployment says there should be three replicas and only two are running, a controller works to fix that.

## Worker Node Components

Workers are where application workloads run.

### kubelet

The `kubelet` is the node agent. It:

- watches pod assignments for its node
- asks the container runtime to start and stop containers
- runs probes
- mounts volumes
- reports node and pod status back to the API server

### kube-proxy

`kube-proxy` handles service networking on each node. It usually programs `iptables`, `ipvs`, or similar rules so that traffic to a `Service` can be forwarded to healthy pods.

In some CNI setups, eBPF-based data planes can reduce or replace some traditional `kube-proxy` behavior.

### Container Runtime

The container runtime actually runs containers. Common examples:

- `containerd`
- CRI-O

Historically Docker was common, but Kubernetes now talks through CRI to runtimes like `containerd` and CRI-O.

## Control Plane vs Worker Summary

| Area | Main Components | Responsibility |
| --- | --- | --- |
| Control plane | `kube-apiserver`, `etcd`, `kube-scheduler`, `kube-controller-manager` | cluster decisions and state |
| Worker | `kubelet`, `kube-proxy`, container runtime | running workloads |

## Practical Example

When you run:

```bash
kubectl apply -f k8s/app.yaml
```

the flow is roughly:

1. `kubectl` sends your manifest to `kube-apiserver`.
2. The desired state is stored in `etcd`.
3. Controllers notice a new deployment and create replica sets and pods.
4. The scheduler picks nodes for unscheduled pods.
5. Each selected node's `kubelet` asks the runtime to start the containers.
6. `kube-proxy` and the CNI help make networking work.

That is the core Kubernetes reconciliation loop in action.
