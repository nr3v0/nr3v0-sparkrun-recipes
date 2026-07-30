#!/bin/bash

# Copy the files to the SSU area
set -e
#cd $WORKSPACE_DIR

pip install flashinfer-python flashinfer-cubin
pip install flashinfer-jit-cache --index-url https://flashinfer.ai/whl/cu130 --no-deps

cp /usr/local/lib/python3.12/dist-packages/vllm/model_executor/layers/mamba/ops/configs/selective_state_update/headdim=64,dstate=128,device_name=NVIDIA_B200,cache_dtype=float32.json /usr/local/lib/python3.12/dist-packages/vllm/model_executor/layers/mamba/ops/configs/selective_state_update/headdim=64,dstate=128,device_name=NVIDIA_GB10,cache_dtype=float32.json
cp /usr/local/lib/python3.12/dist-packages/vllm/model_executor/layers/mamba/ops/configs/selective_state_update/headdim=64,dstate=128,device_name=NVIDIA_B200,cache_dtype=float16.json /usr/local/lib/python3.12/dist-packages/vllm/model_executor/layers/mamba/ops/configs/selective_state_update/headdim=64,dstate=128,device_name=NVIDIA_GB10,cache_dtype=float16.json
