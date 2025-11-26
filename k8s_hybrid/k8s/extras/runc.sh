function runc_install() {
	ver=${1}
	arch=${2}

	dst="/usr/local/sbin/runc"

	url="https://github.com/opencontainers/runc/releases/download/v${ver}/runc.${arch}"
	curl -Lo "runc.$arch" "${url}"

	sudo install -m 755 "runc.$arch" "$dst"
	rm "runc.$arch"
}
