function calico_install {
	calico_ver=${1}

	# configure networkmanager to not interfere with calico
	cat <<-'EOF' | sudo tee /etc/NetworkManager/conf.d/calico.conf >/dev/null
		[keyfile]
		unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali
	EOF
	sudo systemctl restart NetworkManager

	# install the crds and operator
	kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/v$calico_ver/manifests/tigera-operator.yaml"
	kubectl create -f custom-resources.yml
}

function watch_calico {
	watch -n 1 kubectl get pods -n calico-system
}

function calico_install_windows {
	kube_ver=${1}

	# required for hybrid clusters
	kubectl patch ipamconfigurations default -p '{"spec": {"strictAffinity": true}}'

	# apply the kuberenetes-services-endpoint configmap
	APISERVER_ADDR=$(kubectl get endpointslice kubernetes -n default -o jsonpath='{.endpoints[0].addresses[0]}')
	APISERVER_PORT=$(kubectl get endpointslice kubernetes -n default -o jsonpath='{.ports[0].port}')
	kubectl apply -f - <<-EOF
		kind: ConfigMap
		apiVersion: v1
		metadata:
		  name: kubernetes-services-endpoint
		  namespace: tigera-operator
		data:
		  KUBERNETES_SERVICE_HOST: "${APISERVER_ADDR}"
		  KUBERNETES_SERVICE_PORT: "${APISERVER_PORT}"
	EOF

	## for operator installs, you always patch the `installation`, not the `ippool` directly
	# never supported for windows (wait I should never need to patch the ippool)
	# kubectl patch ippool default-ipv4-ippool -p '{"spec": {"ipipMode": "Never"}}'

	# vxlan
	kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/calicoNetwork/bgp", "value": "Disabled"}]'
	kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/calicoNetwork/ipPools/0/encapsulation", "value": "VXLAN"}]'
	kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/calicoNetwork/ipPools/0/disableBGPExport", "value": true}]'

	# bgp
	kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/calicoNetwork/bgp", "value": "Enabled"}]'
	kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/calicoNetwork/ipPools/0/encapsulation", "value": "None"}]'
	kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/calicoNetwork/ipPools/0/disableBGPExport", "value": false}]'

	url="https://raw.githubusercontent.com/kubernetes-sigs/sig-windows-tools/master/hostprocess/calico/kube-proxy/kube-proxy.yml"
	curl -L $url | sd -n 1 'KUBE_PROXY_VERSION' "v$kube_ver" | kubectl create -f -
}

function calico_log {
	# who is using this port?
	# Get-Process -Id (Get-NetTCPConnection -LocalPort 10250).OwningProcess

	kubectl logs -n calico-system -l k8s-app=calico-node-windows --all-containers
	kubectl logs -n calico-system -l k8s-app=calico-node-windows -c install-cni
	kubectl logs -n calico-system -l k8s-app=calico-node-windows -c node
	kubectl logs -n calico-system -l k8s-app=calico-node-windows -c felix
	kubectl logs -n calico-system -l k8s-app=calico-node-windows -c confd

	kubectl describe pod calico-node-xrt7f -n calico-system
	kubectl logs -n calico-system -l k8s-app=calico-node
	kubectl logs -n calico-system -l k8s-app=calico-node --all-containers=true --ignore-errors
	kubectl logs -n calico-system -l k8s-app=calico-node -c calico-node
	kubectl logs -n calico-system -l k8s-app=calico-node -c flexvol-driver
	kubectl logs -n calico-system -l k8s-app=calico-node -c install-cni

	kubectl logs -n kube-system -l k8s-app=kube-proxy --all-containers=true --ignore-errors

	kubectl logs -n kube-system -l k8s-app=kube-proxy-windows --all-containers=true --ignore-errors
	kubectl logs -n kube-system -l k8s-app=kube-proxy-windows -c kube-proxy

	kubectl describe installation default
	kubectl describe ippool default-ipv4-ippool
}

function calico_fix_bird {
	# https://unix.stackexchange.com/questions/773708/calico-node-is-not-ready-bird-is-not-ready-error-querying-bird-unable-to-conn
	kubectl -n calico-system edit daemonset calico-node

	Add it in this block:
	- name: CLUSTER_TYPE
	value: k8s,bgp
	- name: IP
	value: autodetect
	- name: CALICO_IPV4POOL_IPIP
	value: Always
	- name: CALICO_IPV4POOL_VXLAN
	value: Never
	- name: CALICO_IPV6POOL_VXLAN
	value: Never
	- name: IP_AUTODETECTION_METHOD
	value: can-reach=192.168.1.65 add this <---
	# default
	value: first-found
}

function calico_uninstall {
	ver=${1}
	kubectl delete -f "https://raw.githubusercontent.com/projectcalico/calico/v$ver/manifests/custom-resources.yaml"
	kubectl delete -f "https://raw.githubusercontent.com/projectcalico/calico/v$ver/manifests/tigera-operator.yaml"
}
