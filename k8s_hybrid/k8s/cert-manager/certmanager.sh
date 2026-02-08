#!/bin/bash

function certmanager_install() {
	# https://github.com/cert-manager/cert-manager/releases/latest
	ver="v1.18.2"

	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	kubectl create namespace cert-manager

	kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/$ver/cert-manager.crds.yaml"
	helm install cert-manager jetstack/cert-manager --namespace cert-manager --version "$ver" --values=values.yaml
}
