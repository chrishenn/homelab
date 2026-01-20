# Windows Hybrid Cluster: Calico Network Test

https://docs.tigera.io/calico/latest/getting-started/kubernetes/windows-calico/demo

Create a server and client in each of linux and windows nodes

```bash
# Create a client (busybox) and server (nginx) pods on linux nodes:
kubectl apply -f linux.yml

# Create a client (powershell) and server (porter) pods on windows nodes:
# note: update the base images to match your server, ie servercore:ltsc2025
kubectl apply -f windows.yml

# debug
kubectl get pods -n calico-demo
kubectl describe pod -n calico-demo pwsh
```

Now, we test access from each to each

```bash
# First, we will need the porter pod IP:
PORTER=$(kubectl get po porter -n calico-demo -o 'jsonpath={.status.podIP}')
echo $PORTER

# Then we can exec into the busybox pod and try reaching the porter pod on port 80:
kubectl exec -n calico-demo busybox -- nc -vz $PORTER 80

# If the connection from the busybox pod to the porter pod succeeds, we will get output similar to the following:
$ 192.168.40.166 (192.168.40.166:80) open

# Now let's verify that the powershell pod can reach the nginx pod:
kubectl exec -n calico-demo pwsh -- powershell Invoke-WebRequest -Uri http://$(kubectl get po nginx -n calico-demo -o 'jsonpath={.status.podIP}') -UseBasicParsing -TimeoutSec 5

# If the connection succeeds, we will get output similar to:
$ StatusCode        : 200 ...

# Finally, let's verify that the powershell pod can reach the porter pod:
kubectl exec -n calico-demo pwsh -- powershell Invoke-WebRequest -Uri http://$(kubectl get po porter -n calico-demo -o 'jsonpath={.status.podIP}') -UseBasicParsing -TimeoutSec 5

# success would mean
$ StatusCode        : 200 ...
```

Next, we test applying a basic network policy (one of calico's big features).
This policy allows only the busybox pod to reach the porter pod.

```bash
kubectl apply -f policy.yml

# With the policy in place, the busybox pod should still be able to reach the porter pod:
kubectl exec -n calico-demo busybox -- nc -vz $(kubectl get po porter -n calico-demo -o 'jsonpath={.status.podIP}') 80

# However, the powershell pod will not able to reach the porter pod:
kubectl exec -n calico-demo pwsh -- powershell Invoke-WebRequest -Uri http://$(kubectl get po porter -n calico-demo -o 'jsonpath={.status.podIP}') -UseBasicParsing -TimeoutSec 5

# the request should time out, like:
Invoke-WebRequest : The operation has timed out. [...]
```

---

# Delete the demo

```bash
kubectl delete ns calico-demo
```
