# Bootcamp Test

```bash
k create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
k get deployments
k proxy
curl http://localhost:8001/version

POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME
curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/

k delete deployment kubernetes-bootcamp
```
