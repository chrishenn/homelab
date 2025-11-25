function install_gcc13 {
	# install gcc-13
	apt install build-essential libmpfr-dev libgmp3-dev libmpc-dev -y
	wget http://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz
	tar -xf gcc-13.2.0.tar.gz
	pushd gcc-13.2.0
	./configure -v --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --prefix=/usr/local/gcc-13.2.0 --enable-checking=release --enable-languages=c,c++ --disable-multilib --program-suffix=-13.2.0
	make -j$(($(nproc) - 2)) && sudo make install
	popd
	rm -rf gcc-13.2.0
	rm -f gcc-13.2.0.tar.gz
}

function install_gcc13_apt {
	# untested
	sudo apt install software-properties-common
	sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
	sudo apt update
	sudo apt install gcc-13 g++-13 -y
}
