#!/bin/bash

set -e

python3 -m pip install -U sentencepiece tiktoken tokenizers
python3 -m pip install --force-reinstall \
  "tokenizers==0.23.0" \
  "transformers"
