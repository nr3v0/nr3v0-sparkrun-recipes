# nrevo-sparkrun-recipes

A [sparkrun](https://sparkrun.dev) recipe registry for the `nrevo` team/project,
targeting NVIDIA DGX Spark. It hosts recipes (and optional tuning configs,
benchmark profiles, and shared mods) that `sparkrun` can auto-discover and
install via the `@nrevo/recipe-name` syntax.

## Purpose

This repository is a curated collection of `sparkrun` recipes for running
inference servers (vLLM, SGLang, llama.cpp, TensorRT-LLM, etc.) on DGX Spark
hardware. Keeping recipes in a dedicated git repo lets them be:

- **Versioned** — changes to a recipe are tracked and reviewable via git history/PRs.
- **Shared** — anyone with `sparkrun` can add this repo as a registry and pull
  recipes by name instead of copy-pasting `podman run` commands.
- **Discoverable** — the `.sparkrun/registry.yaml` manifest lets `sparkrun`
  auto-discover recipes, tuning configs, benchmarks, and mods without manual
  configuration.

## Structure

```
.
├── .sparkrun/
│   └── registry.yaml     # registry manifest (required for auto-discovery)
├── recipes/              # recipe YAML files (model + container + run command)
├── tuning/               # optional: kernel/runtime tuning configs (e.g. sglang)
├── benchmarking/         # optional: benchmark profile YAML files
├── mods/                 # optional: shared mods (dirs containing run.sh)
└── README.md
```

## Usage

### Add this registry to sparkrun

```bash
sparkrun registry add nrevo <git-url-of-this-repo>
```

Once added, recipes in `recipes/` become available as `@nrevo/<recipe-name>`.

### List available recipes

```bash
sparkrun recipe list @nrevo
```

### Run a recipe

```bash
sparkrun run @nrevo/<recipe-name>
```

### Adding a new recipe

1. Create a new YAML file under `recipes/`, named after the model/variant
   (e.g. `recipes/my-model-vllm.yaml`).
2. Follow the [sparkrun recipe format](https://sparkrun.dev/recipes/format/):
   at minimum, a `model` (HuggingFace identifier) and `container` (image URI),
   plus a `command` template. Example:

   ```yaml
   model: Qwen/Qwen3-1.7B
   runtime: vllm
   container: scitrera/dgx-spark-vllm:0.16.0-t5
   defaults:
     port: 8000
     host: 0.0.0.0
   command: |
     vllm serve {model} --host {host} --port {port}
   ```

3. If the recipe needs runtime tuning, a benchmark profile, or a shared mod,
   add it under `tuning/`, `benchmarking/`, or `mods/` respectively and
   reference it from the recipe.
4. Commit and push. `sparkrun` picks up changes the next time the registry
   is refreshed (`sparkrun registry update nrevo`).

## Naming conventions

- The registry name (`nrevo`) avoids reserved prefixes (`sparkrun`, `official`,
  `arena`, `spark-arena`) as required by the sparkrun registry guidelines.
- Recipe files should be named descriptively after the model and serving
  engine, e.g. `<model>-<engine>.yaml`.

## References

- Registry guidelines: https://sparkrun.dev/recipes/registries/#creating-a-registry
- Recipe format: https://sparkrun.dev/recipes/format/
