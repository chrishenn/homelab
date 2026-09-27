# Problem

It looks like people use calico instead of traefik in k8s

So we need a load balancer that can bind to external ips (maybe virtual, VIPs?) and also work with calico

And then certmanager can handle .... https? once the traffic gets into the cluster

---

# refs

https://github.com/arybach/kubeadm-calico-doris/blob/main/issuer.yml
https://github.com/mmatur/traefik-cert-manager
https://rafrasenberg.com/kubernetes-traefik-ingress/
https://github.com/loxilb-io/loxilbdocs/blob/main/docs/k3s_quick_start_calico.md

```bash
# assumes existing: helm, traefik

. certmanager.sh
certmanager_install

op inject -i cf.yaml | kubectl apply -f -
op inject -i issuer.yaml | kubectl apply -f -
```
