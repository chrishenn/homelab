# apptainer

An ancient singularity/apptainer image definition file
Formerly singularity, this project has entered FOSS stewardship and is renamed to Apptainer

```bash
# train
python cuda_lib/cuda_example/cuda_example.py

# train in apptainer
apptainer exec --nv /home/chris/Documents/apptainer/env182.sif ./train.sh

# install apptainer
apptainer exec --nv /home/chris/Documents/apptainer/env182.sif ./install.sh $@
```
