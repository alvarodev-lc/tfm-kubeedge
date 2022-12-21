# Kubernetes cheatsheet

Get all kubernetes components from all namespaces

```sh
kubectl get all -A
```

Get nodes of the cluster

```sh
kubectl get nodes
```

Get logs from pods

```sh
kubectl logs -n <NAMESPACE> <PODNAME>
```

Force delete pod, even if it's terminating

```sh
kubectl delete pod <PODNAME> --grace-period=0 --force --namespace <NAMESPACE>
```

Debug pod connection

```sh
kubectl exec -i -t <PODNAME> -- nslookup kubernetes.default
```

Taint nodes

```sh
kubectl label nodes <your_node> kubernetes.io/role=<your_label>
```

Access pods from cloudcore. From inside you can curl services to show web servers are running

```sh
kubectl exec -it <PODNAME> -- sh
```
