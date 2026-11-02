#!/bin/bash

set -e

# Uninstall existing tokenizers
python3 -m pip uninstall -y tokenizers

# Install specific version of tokenizers
python3 -m pip install "tokenizers==0.23.0"

# Install transformers, sentencepiece, and tiktoken
python3 -m pip install -U transformers sentencepiece tiktoken