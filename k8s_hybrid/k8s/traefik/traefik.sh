#!/bin/bash

function traefik_install {
	helm repo add traefik https://helm.traefik.io/traefik
	helm repo update
	kubectl create namespace traefik
	helm install --namespace=traefik traefik traefik/traefik --values=values.yaml
}

function traefik_manual_install {
	# install traefik {crd, rbac}
	kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.4/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
	kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.4/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml

	# install the traefik service (and a whoami service as well)
	kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.4/docs/content/user-guides/crd-acme/02-services.yml

	# deployments: this needs editing as it references the letsencrypt staging server, not the real server
	dep="https://raw.githubusercontent.com/traefik/traefik/v3.4/docs/content/user-guides/crd-acme/03-deployments.yml"
	curl -L $dep | sd '(.*)caserver(.*)' '' | kubectl create -f -

	# we bind kube ports to the host so that acme challange can work
	# don't forget to add the host's local IP to the cloudflare DNS setup so it can answer dns challenge
	kubectl port-forward --address 0.0.0.0 service/traefik 8000:8000 8080:8080 443:4443 -n default

	# apply ingressroutes
	kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.4/docs/content/user-guides/crd-acme/04-ingressroutes.yml
}
