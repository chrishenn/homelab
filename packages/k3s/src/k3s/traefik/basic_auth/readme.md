this is for the traefik-basic-auth middleware

```bash
sudo apt install apache2-utils
htpasswd -nb chris <your_password> | openssl base64

# copy so that "secret" in filenames is .gitignore'd
# add your hashed user+pass to the file
cp dash_s.yaml cfg/dash_secret.yaml

kubectl apply -f dash_basicauth.yaml
kubectl apply -f dash_secret.yaml

# then you have to attach this dash_basicauth middleware to your ingressroute for the dashboard service
```
