#!/bin/bash

function plane_install() {
	# https://plane.so/changelog/commercial
	PLANE_VERSION=v1.9.1
	DOMAIN_NAME="plane.henn.dev"

	# assumes you've installed and configured traefik, longhorn on the cluster already
	helm repo add plane https://helm.plane.so/
	helm install plane-app plane/plane-enterprise \
		--create-namespace \
		--namespace plane \
		--set license.licenseDomain=${DOMAIN_NAME} \
		--set license.licenseServer=https://prime.plane.so \
		--set planeVersion=${PLANE_VERSION} \
		--set ingress.enabled=true \
		--set ingress.ingressClass=traefik \
		--set env.storageClass=longhorn \
		--timeout 10m \
		--wait \
		--wait-for-jobs
}
