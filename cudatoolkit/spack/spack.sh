#!/bin/bash

function spack_once {
	git clone --depth=2 --branch=releases/latest https://github.com/spack/spack.git ~/spack
	source ~/spack/share/spack/setup-env.sh
	spack repo update builtin --tag v2025.07.0
}

function env_init {
	source ~/spack/share/spack/setup-env.sh
	spack -e . concretize --fresh --force
	spack -e . install
	spack env activate . -p
}

function spack_add_modules {
	# this is captured in the spack.yaml file
	# manual add LD_LIBRARY_PATH for cuda, as this is not automatically handled by spack anymore
	spack config add modules:prefix_inspections:lib64:[LD_LIBRARY_PATH]
	spack config add modules:prefix_inspections:lib:[LD_LIBRARY_PATH]
}

function env_once {
	# spack init is assumed in current shell (add to .bashrc)
	spack -e . concretize --fresh --force
	spack -e . install
	spack env activate . -p
}

function env {
	# uv venv init is assumed in current shell (done by IDE)
	source ~/spack/share/spack/setup-env.sh
	spack env activate . -p
}
