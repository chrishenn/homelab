# Wintest

Schedule work on a windows worker node in a hybrid k8s cluster

```bash
kubectl create -f wintest.yml
k get pods -o wide -w
k get pods -o wide
curl pod -p 80
```

- Several pods listed from the Linux control plane node, use`kubectl get pods`
- Node-to-pod communication across the network,`curl`port 80 of your pod IPs from the Linux control plane node to
  check for a web server response
- Pod-to-pod communication, ping between pods (and across hosts, if you have more than one Windows node) using
  `kubectl exec`
- Service-to-pod communication,`curl`the virtual service IP (seen under`kubectl get services`) from the Linux
  control plane node and from individual pods
- Service discovery,`curl`the service name with the
  Kubernetes[default DNS suffix](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#services)
- Inbound connectivity,`curl`the NodePort from the Linux control plane node or machines outside of the cluster
- Outbound connectivity,`curl`external IPs from inside the pod using`kubectl exec`
