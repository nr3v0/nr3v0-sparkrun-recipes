# build-and-copy

Wraps [`eugr/spark-vllm-docker`](https://github.com/eugr/spark-vllm-docker)'s
`build-and-copy.sh` so we can build its vLLM image with a local patch applied
to its `Dockerfile`, without vendoring or forking that repo.

## How it works

`build.sh`:

1. Clones (or updates, if already cached) `eugr/spark-vllm-docker` at a
   pinned ref into a scratch directory (`.cache/spark-vllm-docker/` by
   default — gitignored, never committed).
2. Resets that checkout to a clean state (discards anything left over from a
   previous run).
3. Applies `dockerfile.patch` to its `Dockerfile` via `git apply`.
4. Runs its `build-and-copy.sh`, forwarding all arguments straight through.
5. Reverts the patch on exit (success or failure) so the cached checkout is
   always clean for the next run.

We don't vendor `spark-vllm-docker`'s code in this repo at all — `build.sh`
and `dockerfile.patch` are the only files we own. That keeps this repo small
and avoids drift: upstream changes are picked up automatically (or on the
next explicit ref bump), and our only maintenance burden is the patch itself.

Note: each run resets the scratch clone to a clean checkout of `REPO_REF`, so
there's no incremental build caching across runs beyond whatever
`build-and-copy.sh`/Docker layer caching already provides.

## Usage

```bash
./build-and-copy/build.sh [any build-and-copy.sh flags]
```

For example:

```bash
./build-and-copy/build.sh --tag my-vllm-node --copy-to spark1,spark2
```

### Environment variables

| Variable                    | Default                        | Purpose                                              |
|------------------------------|---------------------------------|-------------------------------------------------------|
| `SPARK_VLLM_DOCKER_REF`     | `main`                          | Branch, tag, or commit of `spark-vllm-docker` to build against |
| `SPARK_VLLM_DOCKER_CACHE`   | `build-and-copy/.cache/spark-vllm-docker` | Where the scratch clone lives                        |

Pin to a specific commit/tag for reproducible builds, e.g.:

```bash
SPARK_VLLM_DOCKER_REF=v1.2.3 ./build-and-copy/build.sh
```

## The patch

`dockerfile.patch` currently changes the base CUDA image:

```diff
-ARG CUDA_IMAGE=nvidia/cuda:13.0.2-devel-ubuntu24.04
+ARG CUDA_IMAGE=nvidia/cuda:13.3.1-devel-ubuntu24.04
```

### Updating the patch

1. Clone upstream and check out the ref you're targeting:
   ```bash
   git clone https://github.com/eugr/spark-vllm-docker.git /tmp/svd
   cd /tmp/svd
   ```
2. Edit `Dockerfile` with the change you want.
3. Regenerate the patch and copy it back into this directory:
   ```bash
   git diff > /path/to/this/repo/build-and-copy/dockerfile.patch
   ```
4. Verify it still applies cleanly against the current `REPO_REF`:
   ```bash
   git apply --check build-and-copy/dockerfile.patch
   ```
