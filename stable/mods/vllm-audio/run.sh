#!/bin/bash

# Install vLLM's audio extras (librosa, soundfile, etc.) for models that
# accept audio inputs (e.g. Nemotron-3-Nano-Omni).
set -e

pip install vllm[audio]
