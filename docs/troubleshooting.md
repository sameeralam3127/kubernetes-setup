# kubectl Troubleshooting Cheatsheet

This file collects practical commands for debugging local Kubernetes clusters.

## Cluster State

```bash
kubectl cluster-info
kubectl config get-contexts
kubectl get nodes -o wide
kubectl get namespaces
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Workload Inspection

```bash
kubectl get pods -A
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs -f <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl top nodes
kubectl top pods
```

## Services and Networking

```bash
kubectl get svc -A
kubectl describe svc <service-name>
kubectl get endpoints
kubectl get ingress
kubectl describe ingress <ingress-name>
kubectl port-forward svc/fastapi-service 8080:80
```

## Storage

```bash
kubectl get pvc,pv
kubectl describe pvc <pvc-name>
```

## Rollouts

```bash
kubectl get deploy
kubectl describe deploy fastapi-app
kubectl rollout status deploy/fastapi-app
kubectl rollout history deploy/fastapi-app
kubectl rollout restart deploy/fastapi-app
```

## Exec Into Pods

```bash
kubectl exec -it <pod-name> -- sh
kubectl exec -it deploy/fastapi-app -- sh
```

## Common Failure Patterns

### Pod Stuck In `Pending`

Check:

```bash
kubectl describe pod <pod-name>
```

Usually caused by:

- not enough CPU or memory
- PVC not bound
- image pull problems
- taints or scheduling constraints

### Pod In `CrashLoopBackOff`

Check:

```bash
kubectl logs <pod-name> --previous
kubectl describe pod <pod-name>
```

Usually caused by:

- app startup failure
- wrong environment variables
- database connectivity failure
- bad command or entrypoint

### Service Has No Endpoints

Check:

```bash
kubectl get endpoints
kubectl describe svc <service-name>
kubectl get pods --show-labels
```

Usually caused by:

- service selector does not match pod labels
- pods are not Ready

### Ingress Not Working

Check:

```bash
kubectl get ingress
kubectl describe ingress fastapi-ingress
kubectl get pods -A | grep -i ingress
```

Usually caused by:

- ingress controller not installed
- wrong `ingressClassName`
- service target mismatch

## Node-Level Troubleshooting

When using Multipass or other Linux nodes, SSH or exec into the node and check:

```bash
sudo systemctl status kubelet
sudo journalctl -u kubelet -xe
sudo crictl ps
sudo crictl images
```

For K3s:

```bash
sudo systemctl status k3s
sudo journalctl -u k3s -xe
```

## Useful Cleanup Commands

```bash
kubectl delete pod <pod-name>
kubectl delete deploy fastapi-app
kubectl delete svc fastapi-service
kubectl delete ingress fastapi-ingress
kubectl delete -f k8s/
```
