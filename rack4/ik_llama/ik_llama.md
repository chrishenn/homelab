# ik_llama and r1 quantizations

https://huggingface.co/ubergarm/DeepSeek-R1-0528-GGUF
https://github.com/ikawrakow/ik_llama.cpp
https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md

- the ik_llama form of llama.cpp gives us improved cpu/gpu hetero compute, which is necessary for huge models and
  smol gpus
- this is the smallest deepseek distillation of deepseek-r1 5B params, that can run under ik_llama
- I ran this IQ1_S_R4 quant in rack4, but had to unload the entire compose project to make it fit
- I used spack to install the cudatoolkit; not recommended

---

cuda toolkit required for cuda build of ik_llama server

```bash
git clone https://github.com/ikawrakow/ik_llama.cpp.git
cd ik_llama.cpp

cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release -j 16

# if native arch doesn't work
# -DCMAKE_CUDA_ARCHITECTURES="89"
```

model selection

too big for now

```bash
# IQ3_K_R4
# This is probably a good size quant for a 368GB RAM rig preferably with at least a single 24GB VRAM GPU. It is probably a
# little out of reach for a 256GB RAM rig unless you have 80+GB VRAM. You could still run "troll rig" style and page off
# disk for maybe 5 tok/sec and some hot NVMe drives hahah...

# Fits 32k context in under 24GB VRAM
# Optional `-ser 6,1` improves speed at some cost to quality
# Recommended sampling: --temp 0.6 --top-p 0.95

# would need to buy 4x 64GB DDR4 dimms, at $126 each, or $500. Then we just squeak in at 128 + 256 = 384 GB.
# Seems like a bit much for old-ass last-gen dimms, plus, they'll be mismatched with the 32GB dimms that I have
# already, meaning who tf knows how slow they'd run together.

CUDA_VISIBLE_DEVICES="0," \
./build/bin/llama-server \
--model /mnt/raid/models/ubergarm/DeepSeek-R1-0528-GGUF/DeepSeek-R1-0528-IQ3_K_R4.gguf \
--alias ubergarm/DeepSeek-R1-0528-IQ3_K_R4 \
--ctx-size 32768 \
-ctk q8_0 \
-mla 3 -fa \
-amb 512 \
-fmoe \
--n-gpu-layers 63 \
--override-tensor exps=CPU \
--parallel 1 \
--threads 16 \
--host 127.0.0.1 \
--port 8080
```

fits in 128 GB + 24 GB

```bash
# IQ1_S_R4
# The world's smallest working DeepSeek-R1-0528 quant!

# If you can fit a larger model completely in RAM+VRAM I would recommend that, but if you have 128GB RAM + 24GB VRAM
# then give this a try as it is surprisingly usable despite heavy quantization.

# You can use more CUDA devices just set them all visibile and do *not* use `-ts ...` with this `-ot ...` strategy.
CUDA_VISIBLE_DEVICES="0" \
./build/bin/llama-server \
    --model /mnt/k/docker/models/DeepSeek-R1-0528-IQ1_S_R4-00001-of-00003.gguf \
    --alias ubergarm/DeepSeek-R1-0528-IQ1_S_R4 \
    --ctx-size 32768 \
    -ctk q8_0 \
    -mla 3 -fa \
    -amb 256 \
    -fmoe \
    --n-gpu-layers 99 \
    -ot "blk\.(3|4|5|6)\.ffn_.*=CUDA0" \
    --override-tensor exps=CPU \
    -rtr \
    --parallel 1 \
    --threads 24 \
    --host 192.168.1.142 \
    --port 8082
```
