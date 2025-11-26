# k8s traefik + cert-manager

You will need a dns record somewhere on your network that gets you to the external load-balancer ip when looking for
the service hostname. I use blocky (not included here)

```bash
# assumes helm, metallb installed

. traefik.sh
traefik_install

# edit the ingress.yaml file such that requests for host kube-traefik.henn.dev redirect to the external lb ip
kubectl apply -f dash_secret.yaml
kubectl apply -f middleware.yaml
kubectl apply -f ingress.yaml
```

---

example nginx service + traefik + cert-manager

```bash
kubectl apply -f example
kubectl delete -f example
```

---

# monitor

```bash
$ kubectl get svc --all-namespaces

NAMESPACE        NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP
traefik          traefik                   LoadBalancer   10.43.85.136    192.168.1.80

$ nslookup kube-traefik.henn.dev
Non-authoritative answer:
Name: kube-traefik.henn.dev
Address: 192.168.30.80
```
