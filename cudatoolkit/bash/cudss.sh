function install_cudss_13 {
	tgt="$HOME/cuda/cuda-13.0"

	burl="https://developer.download.nvidia.com/compute"
	url="$burl/cudss/redist/libcudss/linux-x86_64/libcudss-linux-x86_64-0.6.0.5_cuda12-archive.tar.xz"

	mkdir tmp && pushd tmp
	wget -O pkg.tar.xz "$url"
	tar xf pkg.tar.xz --strip-components=1
	sudo cp -a include/* "$tgt/include/"
	sudo cp -a lib/* "$tgt/lib64/"
	popd && rm -rf tmp
}
