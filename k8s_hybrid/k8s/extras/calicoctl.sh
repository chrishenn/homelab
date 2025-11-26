function calicoctl_install {
	ver=${1}

	dst="/usr/local/bin/"

	curl -Lo calicoctl "https://github.com/projectcalico/calico/releases/download/v$ver/calicoctl-linux-amd64"
	sudo install calicoctl $dst
	rm calicoctl
}
