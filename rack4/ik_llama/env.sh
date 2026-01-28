#!/bin/bash

function env_once() {
	source ~/spack/share/spack/setup-env.sh
	spack -e . concretize --fresh --force
	spack -e . install
	spack env activate . -p
}

function env() {
	source ~/spack/share/spack/setup-env.sh
	spack env activate . -p
}
