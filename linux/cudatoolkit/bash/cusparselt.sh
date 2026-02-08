#!/bin/bash

function install_cusparselt_13 {
	tgt="$HOME/cuda/cuda-13.0"
	url="https://developer.download.nvidia.com/compute/cusparselt/redist/libcusparse_lt/linux-x86_64/libcusparse_lt-linux-x86_64-0.8.1.1_cuda13-archive.tar.xz"

	mkdir tmp && pushd tmp
	wget -O pkg.tar.xz "$url"
	tar xf pkg.tar.xz --strip-components=1
	sudo cp -a include/* "$tgt/include/"
	sudo cp -a lib/* "$tgt/lib64/"
	popd && rm -rf tmp
}
