# cudatookit_bash

References for manually (bash scripts) installing and building against the cuda toolkit
Note that I recommend using a package manager to manage build deps including cuda. The ones I know of are:

- pixi (recommended)
- spack
- modulefiles / lmod

For more examples and stacks of tooling, see https://github.com/chrishenn/project_stubs

---

# Manual Install Recipe

```bash
. bash/cudatoolkit.sh
install_cudatoolkit_13

. bash/cudnn.sh
install_cudnn_13

. bash/cusparselt.sh
install_cusparselt_13

. bash/cudss.sh
install_cudss_13
```
