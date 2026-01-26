# Working k3s + traefik + cert-manager example

I did put the load balancer onto a 192.168.1.0/24 IP, but now that I've natted 192.168.1.0/24 to 192.168.30.0/24, the
30 subnet should work for the external ips of the cluster services

So this kluster evidently has

- rancher
- k3s
    - k3s binary is symlinked to kubectl and crictl
    - k3s is registered as a systemd service with a unit file
    - there's a token that master nodes use to talk together securely (?)
    - each node gets an ip
- kube-vip
    - arp mode
    - https://kube-vip.io/manifests/rbac.yaml
    - also populates a yaml template and applies the kube-vip daemonset
- metallb
    - in layer2 mode
    - in native type
- flannel

- http proxy for internet: off
- calico: off
- cilium: off
    - if cilium_bgp is enabled, the ansible config will disable metallb

# k3s cluster ansible

```bash
git clone https://github.com/techno-tim/k3s-ansible

# populate these files here in k3s/ into the techno tim project

uv sync
. .venv/bin/activate
ansible-galaxy install -r ./collections/requirements.yml

# had to run with -K to type in root password on target machine
ansible-playbook ./site.yml -i ./inventory/my-cluster/hosts.ini -K

# this file is owned by root. have to ssh to remote and add +rw permissions in order to copy out
# for whatever reason, kubectl running on remote (control plane) also won't use the copied version in ~/.kube/config
#   so the remote machine also wants +r set on it to use with kubectl
# sudo chmod +r /etc/rancher/k3s/k3s.yaml
scp 192.168.1.142:/etc/rancher/k3s/k3s.yaml ~/.kube/config

# have to manually edit to add the remote machine ip
# use the apiserver ip: 192.168.30.222
nano ~/.kube/config

# remove k3s from all nodes
# ansible-playbook ./reset.yml -i ./inventory/my-cluster/hosts.ini
```

### example

```bash
# see nat.sh for the routing rules I set up to route subnets together.
kubectl apply -f example

# With subnets natted I can curl the service from my workstation
curl http://192.168.30.80

# delete the example
kubectl delete -f example
```

# traefik + cert-manager

You will need a dns record somewhere on your network that gets you to the external load-balancer ip when looking for
the service hostname. I use blocky (not included here)

```bash
$ kubectl get svc --all-namespaces

NAMESPACE        NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP
traefik          traefik                   LoadBalancer   10.43.85.136    192.168.1.80

$ nslookup kube-traefik.henn.dev
Non-authoritative answer:
Name: kube-traefik.henn.dev
Address: 192.168.30.80
```

```bash
. helm.sh
helm_install

. traefik.sh
traefik_install

# edit the ingress.yaml file such that requests for host kube-traefik.henn.dev redirect to the external lb ip
kubectl apply -f dash_secret.yaml
kubectl apply -f middleware.yaml
kubectl apply -f ingress.yaml

. certmanager.sh
certmanager_install

kubectl apply -f cf_secret.yaml
kubectl apply -f letsencrypt-production.yaml
kubectl apply -f local-example-com.yaml

# verify/monitor
kubectl get challenges
kubectl get certificate
kubectl describe order
kubectl logs -n cert-manager -f cert-manager-7c9668955f-5gml7
```

example nginx service + traefik + cert-manager

```bash
kubectl apply -f nginx_example
kubectl delete -f nginx_example
```
