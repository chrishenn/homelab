#!/bin/bash

function install_cudnn {
	# complete ver, ie "9.13.0.50"
	declare cudnn_ver=${1}
	shift
	# one number, ie "12" or "13"
	declare cuda_major=${1}
	shift
	declare tgt=${1}
	shift

	if [ -z "$cudnn_ver" ]; then
		echo "cudnn_ver empty" && return 1
	elif [ -z "$cuda_major" ]; then
		echo "cuda_major empty" && return 1
	elif [ -z "$tgt" ]; then
		echo "tgt empty" && return 1
	fi

	urlb="https://developer.download.nvidia.com/compute/cudnn/redist/cudnn"
	url="${urlb}/linux-x86_64/cudnn-linux-x86_64-${cudnn_ver}_cuda${cuda_major}-archive.tar.xz"

	mkdir tmp && pushd tmp
	wget -O pkg.tar.xz "${url}"
	tar xf pkg.tar.xz --strip-components=1
	sudo cp -a include/* "$tgt/include/"
	sudo cp -a lib/* "$tgt/lib64/"
	popd && rm -rf tmp
}

function install_cudnn_13 {
	# redistrib info with available versions at:
	# https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_9.13.0.json

	install_cudnn "9.13.0.50" "13" "$HOME/cuda/cuda-13.0/"
}

function install_cudnn_alt2 {
	cudnn_ver=9.5.1.17
	mkdir tmp_cudnn && pushd tmp_cudnn
	wget -q https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/cudnn-linux-x86_64-${cudnn_ver}_cuda12-archive.tar.xz -O cudnn-linux-x86_64-${cudnn_ver}_cuda12-archive.tar.xz
	tar xf cudnn-linux-x86_64-${cudnn_ver}_cuda12-archive.tar.xz
	sudo cp -a cudnn-linux-x86_64-${cudnn_ver}_cuda12-archive/include/* /usr/local/cuda/include/
	sudo cp -a cudnn-linux-x86_64-${cudnn_ver}_cuda12-archive/lib/* /usr/local/cuda/lib64/
	sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
	popd
	rm -rf tmp_cudnn
}

function install_cudnn_alt3 {
	cudnn_ver=9.5.1.17

	mkdir tmp_cudnn
	pushd tmp_cudnn
	if [[ ${CUDA_VERSION:0:4} == "12.6" ]]; then
		CUDNN_NAME="cudnn-linux-x86_64-9.5.1.17_cuda12-archive"
	elif [[ ${CUDA_VERSION:0:2} == "12" ]]; then
		CUDNN_NAME="cudnn-linux-x86_64-9.1.0.70_cuda12-archive"
	elif [[ ${CUDA_VERSION:0:2} == "11" ]]; then
		CUDNN_NAME="cudnn-linux-x86_64-9.1.0.70_cuda11-archive"
	else
		print "Unsupported CUDA version ${CUDA_VERSION}"
		exit 1
	fi
	curl --retry 3 -OLs https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/${CUDNN_NAME}.tar.xz
	tar xf ${CUDNN_NAME}.tar.xz
	cp -a ${CUDNN_NAME}/include/* /usr/local/cuda/include/
	cp -a ${CUDNN_NAME}/lib/* /usr/local/cuda/lib64/
	popd
	rm -rf tmp_cudnn
	ldconfig
}
