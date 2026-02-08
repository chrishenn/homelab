#!/bin/bash

function verify {
	# https://github.com/longhorn/longhorn/blob/v1.8.1/scripts/environment_check.sh
	# https://raw.githubusercontent.com/longhorn/longhorn/v1.8.1/scripts/environment_check.sh
	ver=${1:-"1.8.1"}

	url="https://raw.githubusercontent.com/longhorn/longhorn/v$ver/scripts/environment_check.sh"
	curl -Lo environment_check.sh "$url"
	sudo chmod a+x environment_check.sh
	./environment_check.sh
}

function install {
	# expected pods:
	#
	# NAME                                                READY   STATUS    RESTARTS   AGE
	# longhorn-ui-b7c844b49-w25g5                         1/1     Running   0          2m41s
	# longhorn-manager-pzgsp                              1/1     Running   0          2m41s
	# longhorn-driver-deployer-6bd59c9f76-lqczw           1/1     Running   0          2m41s
	# longhorn-csi-plugin-mbwqz                           2/2     Running   0          100s
	# csi-snapshotter-588457fcdf-22bqp                    1/1     Running   0          100s
	# csi-snapshotter-588457fcdf-2wd6g                    1/1     Running   0          100s
	# csi-provisioner-869bdc4b79-mzrwf                    1/1     Running   0          101s
	# csi-provisioner-869bdc4b79-klgfm                    1/1     Running   0          101s
	# csi-resizer-6d8cf5f99f-fd2ck                        1/1     Running   0          101s
	# csi-provisioner-869bdc4b79-j46rx                    1/1     Running   0          101s
	# csi-snapshotter-588457fcdf-bvjdt                    1/1     Running   0          100s
	# csi-resizer-6d8cf5f99f-68cw7                        1/1     Running   0          101s
	# csi-attacher-7bf4b7f996-df8v6                       1/1     Running   0          101s
	# csi-attacher-7bf4b7f996-g9cwc                       1/1     Running   0          101s
	# csi-attacher-7bf4b7f996-8l9sw                       1/1     Running   0          101s
	# csi-resizer-6d8cf5f99f-smdjw                        1/1     Running   0          101s
	# instance-manager-b34d5db1fe1e2d52bcfb308be3166cfc   1/1     Running   0          114s
	# engine-image-ei-df38d2e5-cv6nctraefik_helm

	ver=${1:-"1.8.1"}

	sudo apt install -yjq mktemp sort printf open-iscsi nfs-common

	sudo systemctl enable --now iscsid
	sudo systemctl status iscsid

	sudo modprobe iscsi_tcp

	verify "$ver"
	read -n1 -r -p "Press any key to continue..."
	echo

	helm repo add longhorn https://charts.longhorn.io
	helm repo update
	helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version "$ver"
	watch -n 1 kubectl -n longhorn-system get pod
}
