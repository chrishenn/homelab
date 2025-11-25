#!/bin/bash

# this patches a cudatoolkit build issue, gone in cudatoolkit 13.0 against gcc15
sudo apt install -y sd

toolkit="$HOME/cuda/cuda-12.9"
pfile='targets/x86_64-linux/include/crt/math_functions.h'
tgt="$toolkit/$pfile"

sudo chmod 777 "$(dirname "$tgt")"
sudo chmod 777 "$tgt"

in='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double                 sinpi(double x);'
ot='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double                 sinpi(double x) noexcept (true);'
sd -F "$in" "$ot" "$tgt" -n 1

in='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float                  sinpif(float x);'
ot='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float                  sinpif(float x) noexcept (true);'
sd -F "$in" "$ot" "$tgt" -n 1

in='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double                 cospi(double x);'
ot='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double                 cospi(double x) noexcept (true);'
sd -F "$in" "$ot" "$tgt" -n 1

in='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float                  cospif(float x);'
ot='extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float                  cospif(float x) noexcept (true);'
sd -F "$in" "$ot" "$tgt" -n 1
