Creating a k3d cluster.

```
k3d cluster create lab --config lab.yaml
```

Add a worker node
```
k3d node create lab-worker -c lab --k3s-node-label k8s.lab.home/workload=services --memory 4Gi
```
