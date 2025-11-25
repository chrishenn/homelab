function install_nccl {
	NCCL_VERSION=v2.21.5-1

	git clone -b $NCCL_VERSION --depth 1 https://github.com/NVIDIA/nccl.git
	pushd nccl && make -j src.build
	sudo cp -a build/include/* /usr/local/cuda/include/
	sudo cp -a build/lib/* /usr/local/cuda/lib64/
	popd
	rm -rf nccl
}

function install_nccl_alt {
	declare NCCL_VER=${1}
	shift

	echo "Installing: NCCL ${NCCL_VER}"

	mkdir tmp && pushd tmp
	git clone -b "${NCCL_VER}" --depth 1 https://github.com/NVIDIA/nccl.git
	pushd nccl
	NVCC_GENCODE="-gencode=arch=compute_80,code=sm_80 -gencode=arch=compute_90,code=sm_90 -gencode=arch=compute_100,code=sm_100 -gencode=arch=compute_120,code=sm_120 -gencode=arch=compute_120,code=compute_120" \
		make -j -Wno-deprecated-gpu-targets src.build
	cp -a build/include/* /usr/local/cuda/include/
	cp -a build/lib/* /usr/local/cuda/lib64/
	popd
	popd
	rm -rf tmp
}
