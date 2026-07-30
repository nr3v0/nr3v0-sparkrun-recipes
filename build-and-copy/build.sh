#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/eugr/spark-vllm-docker.git"
REPO_REF="${SPARK_VLLM_DOCKER_REF:-main}"
CACHE_DIR="${SPARK_VLLM_DOCKER_CACHE:-$SCRIPT_DIR/.cache/spark-vllm-docker}"
PATCH_FILE="$SCRIPT_DIR/dockerfile.patch"

if [ -d "$CACHE_DIR/.git" ]; then
  git -C "$CACHE_DIR" fetch --quiet origin "$REPO_REF"
  git -C "$CACHE_DIR" checkout --quiet --detach FETCH_HEAD
else
  git clone --quiet "$REPO_URL" "$CACHE_DIR"
  git -C "$CACHE_DIR" checkout --quiet "$REPO_REF"
fi

# Discard anything left over from a previous run before patching.
git -C "$CACHE_DIR" checkout --quiet -- .
git -C "$CACHE_DIR" clean --quiet -fdx

cleanup() {
  git -C "$CACHE_DIR" checkout --quiet -- Dockerfile 2>/dev/null || true
}
trap cleanup EXIT

git -C "$CACHE_DIR" apply "$PATCH_FILE"

(cd "$CACHE_DIR" && exec ./build-and-copy.sh "$@")
