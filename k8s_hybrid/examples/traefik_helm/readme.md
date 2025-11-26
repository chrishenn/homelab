```bash
# render a template using helm without installing the chart
helm install --debug --dry-run goodly-guppy ./mychart

helm install traefik traefik/traefik -f values.yaml -f overrides.yaml -f secrets.yaml --debug --dry-run

helm install traefik traefik/traefik -f values.yaml -f overrides.yaml -f secrets.yaml

kubectl logs -l app=plane-app -n plane --all-containers=true

# show full spec for resource, pretty-rpinted
kubectl get <resource-type> <resource-name> -n <namespace> -o yaml | yq '.spec'

kubectl get deployment -n traefik -o yaml | yq '.spec'
```
