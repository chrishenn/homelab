#!/bin/bash

function cilim_cli_install() {
	# https://github.com/cilium/cilium-cli/releases/latest
	ver=${1:-"v0.18.3"}
	arch=amd64

	printf "cilium ver: $ver"

	if [ "$(uname -m)" = "aarch64" ]; then arch=arm64; fi
	url="https://github.com/cilium/cilium-cli/releases/download/${ver}/cilium-linux-${arch}.tar.gz{,.sha256sum}"
	curl -L --fail --remote-name-all $url
	sha256sum --check cilium-linux-${arch}.tar.gz.sha256sum
	sudo tar xzvfC cilium-linux-${arch}.tar.gz /usr/local/bin
	rm cilium-linux-${arch}.tar.gz{,.sha256sum}
}

function hubble_install() {
	HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
	HUBBLE_ARCH=amd64
	if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
	curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
	sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
	sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
	rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
}

function cilim_install() {
	ver=${1:-"v1.17.4"}
	cilium install --version "$ver"
}

function cilim_uninstall() {
	cilium uninstall
}

function cilium_bounce() {
	kubectl -n kube-system delete pods -l k8s-app=cilium
}

function cilium_set_native() {
	cilium config set routing-mode native
	cilium config set ipv4-native-routing-cidr 10.0.0.0/16
}

function cilium_test_delete() {
	kubectl delete namespace cilium-test-1 --grace-period=0 --force
}

function check_pod_cidr() {
	kubectl get node -o custom-columns=NAME:.metadata.name,PODCIDR:.spec.podCIDR
	kubectl get ciliumnode -o custom-columns=NAME:.metadata.name,PODCIDR:.spec.ipam.podCIDRs
	kubectl get ciliumnode -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.ipam.podCIDRs}{"\n"}{end}'
}
