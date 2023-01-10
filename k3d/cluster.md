# Creating a k3d cluster

```
k3d cluster create lab --config lab.yaml
```

# Add a worker node
```
k3d node create lab-worker -c lab --k3s-node-label k8s.lab.home/workload=services --memory 4Gi
```

# Upgrade server node

Add a new server node to the cluster
```
k3d node create lab-server-vNext  -c lab --memory 2Gi --role server --image rancher/k3s:vNext
```

Wait for the node to join the cluster.
```
kubectl get nodes
```

Cordon and drain the old server node.
```
kubectl drain k3d-lab-server-0
```

Delete the server node from k3d
```
k3d node delete k3d-lab-server-0
```

Recreate the server node (override the `--server` arg as the server node now is not the cluster default)
```
k3d node create lab-server -c lab --memory 2Gi --role server --image rancher/k3s:vNext --k3s-arg "--server=https://k3d-lab-server-vNext-0:6443"
```

Cordon and drain the vNext server node
```
kubectl drain k3d-lab-server-vNext-0
```

Delete the server node from k3d
```
k3d node delete k3d-lab-server-vNext-0
```
