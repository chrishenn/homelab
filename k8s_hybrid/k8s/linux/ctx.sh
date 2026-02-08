#!/bin/bash

function k_unset {
	echo "kube: unset"
	ret=$(kubectl config unset current-context)
	if [[ ! "$ret" =~ "Property \"current-context\" unset" ]]; then
		echo "kube: error doing ctx unset"
	fi
}

function k_dev {
	echo "kube: attach to dev"
	ctx_tgt=''
	url=''

	kubectl config use-context $url
	ctx=$(kubectl config current-context)
	echo "current context: $ctx"

	if [[ ! "$ctx" =~ "$ctx_tgt" ]]; then
		echo "kube: error setting ctx"
		k_unset
	fi
}
