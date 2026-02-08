#!/bin/bash

function metallb_install {
	helm repo add metallb https://metallb.github.io/metallb
	helm install my-metallb metallb/metallb --version 0.15.2 --values=values.yml
}

function metallb_install_manual {
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
}

function metallb_uninstall_manual {
	kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
}
