```bash
kubectl apply -f 00-role.yml \
    -f 00-account.yml \
    -f 01-role-binding.yml \
    -f 02-traefik.yml \
    -f 02-traefik-services.yml

kubectl apply -f 03-whoami.yml \
              -f 03-whoami-services.yml \
              -f 04-whoami-ingress.yml
```
