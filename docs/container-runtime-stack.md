# OCI, CRI, runc, Namespaces, and cgroups

This file explains the container stack below Kubernetes.

## The Mental Model

Kubernetes does not directly create Linux containers itself. It relies on lower layers:

- OCI image format and runtime specs
- CRI for talking to runtimes
- container runtimes such as `containerd` or CRI-O
- low-level runtimes such as `runc`
- Linux kernel features such as namespaces and cgroups

## OCI

OCI stands for Open Container Initiative.

OCI defines standards for:

- container images
- runtime behavior

This is why an image built by Docker, Podman, or Buildah can often run through different OCI-compatible runtimes.

## CRI

CRI stands for Container Runtime Interface.

CRI is the API Kubernetes uses to talk to a container runtime. The `kubelet` does not need to know all implementation details of every runtime. It calls the CRI implementation instead.

Common CRI-compatible runtimes:

- `containerd`
- CRI-O

## containerd

`containerd` is a popular high-level container runtime. It handles:

- image pulls
- image storage
- container lifecycle
- snapshotting
- low-level runtime integration

It commonly uses `runc` underneath to create Linux containers.

## CRI-O

CRI-O is another Kubernetes-focused container runtime. It was designed specifically for Kubernetes and CRI usage. It is common in some enterprise and OpenShift-style environments.

## runc

`runc` is a low-level OCI runtime. It is close to the Linux kernel layer and is responsible for actually creating and starting the container process using kernel primitives.

Think of it this way:

- Kubernetes decides what should run
- `kubelet` asks the runtime to run it
- `containerd` or CRI-O manages the request
- `runc` creates the actual Linux container process

## Linux Namespaces

Namespaces isolate what a process can see.

Important namespace types:

- PID namespace: isolates process IDs
- NET namespace: isolates network interfaces, routes, ports
- MNT namespace: isolates mount points
- IPC namespace: isolates inter-process communication
- UTS namespace: isolates hostname and domain name
- USER namespace: isolates user and group IDs

This is one reason containers feel like separate environments.

## cgroups

cgroups control and account for resource usage.

They are used for:

- CPU limits
- memory limits
- I/O limits
- process accounting

In Kubernetes, your pod resource requests and limits eventually depend on cgroup enforcement at the node level.

## How It Fits Together

When a pod starts:

1. The `kubelet` receives the pod assignment.
2. The `kubelet` calls the runtime using CRI.
3. The runtime pulls or finds the OCI image.
4. The runtime calls a low-level runtime like `runc`.
5. `runc` uses namespaces and cgroups to create the containerized process.

That is the practical bridge from a YAML manifest to a real Linux process.
