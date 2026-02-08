#!/bin/bash

set -ex

function install_cudatoolkit_13 {
	# requires driver >=
	# builds against gcc15
	tgt="$HOME/cuda/cuda-13.0"
	url="https://developer.download.nvidia.com/compute/cuda/13.0.1/local_installers/cuda_13.0.1_580.82.07_linux.run"

	mkdir -p tmp && pushd tmp
	wget -O cuda.run "$url" || exit
	sudo sh cuda.run '--silent' '--override' '--toolkit' "--installpath=$tgt" || exit
	popd && rm -rf tmp
}

function install_cudatoolkit129_simple {
	tgt="$HOME/cuda/cuda-12.9"
	wget https://developer.download.nvidia.com/compute/cuda/12.9.1/local_installers/cuda_12.9.1_575.57.08_linux.run
	sudo sh cuda_12.9.1_575.57.08_linux.run '--silent' '--override' '--toolkit' "--installpath=$tgt"
}

function install_cudatoolkit {
	declare CU_VER=${1}
	shift
	declare NV_DRIVER=${1}
	shift

	runfile="cuda_${CU_VER}_${NV_DRIVER}_linux.run"

	echo "Installing: CUDA ${CU_VER}"
	echo "Requires: GCC <= 14"

	# delete existing cudatoolkit if present
	rm -rf /usr/local/cuda

	# download and install
	mkdir tmp && pushd tmp

	# the runfile creates a symlink
	# the runfile does not set env vars
	wget -O cuda.run "https://developer.download.nvidia.com/compute/cuda/$CU_VER/local_installers/$runfile"
	sudo chmod +x cuda.run
	sudo sh cuda.run --toolkit --silent

	popd
	rm -rf tmp
}

function manual_path {
	# manually add cudatoolkit dirs to global PATH, LD_LIBRARY_PATH.
	# should not be necessary for most modern build tools
	export PATH=/usr/local/cuda-12.6/bin${PATH:+:${PATH}}
	export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

	# simpler syntax
	export CUDA_HOME=/usr/local/cuda
	export PATH=$PATH:/usr/local/cuda/bin
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
}

function link_cudatoolkit_gcc13 {
	# link cuda installation to use gcc-13
	ln -s /usr/local/gcc-13.2.0/bin/gcc-13.2.0 /usr/local/cuda/bin/gcc
	ln -s /usr/local/gcc-13.2.0/bin/g++-13.2.0 /usr/local/cuda/bin/g++
}

function install_cudatoolkit_alt {
	ver="12.6.3"
	mver="12.6"
	rfile="cuda_12.6.3_560.35.05_linux.run"

	# install cudatoolkit
	wget -q "https://developer.download.nvidia.com/compute/cuda/12.6.3/local_installers/$rfile"
	sudo chmod +x $rfile
	sudo ./$rfile --toolkit --silent

	# link to the correct gcc version
	MAX_GCC_VERSION=13
	sudo ln -s /usr/bin/gcc-$MAX_GCC_VERSION /usr/local/cuda/bin/gcc
	sudo ln -s /usr/bin/g++-$MAX_GCC_VERSION /usr/local/cuda/bin/g++
}

function install_cudatoolkit_128 {
	CU_MAJOR=12
	CU_VER=12.8.0
	NV_DRIVER=570.86.10
	CUDNN_VER=9.7.0.66
	NCCL_VER=v2.25.1-1

	. cudnn.sh
	. nccl.sh

	install_cudatoolkit $CU_VER $NV_DRIVER
	install_cudnn $CUDNN_VER $CU_MAJOR
	install_nccl $NCCL_VER
}
