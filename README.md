# nr3v0-sparkrun-recipes

A [sparkrun](https://sparkrun.dev) recipe registry for the `nr3v0` team/project,
targeting NVIDIA DGX Spark. It hosts three registries — `nr3v0` (stable),
`nr3v0-fast`, and `nr3v0-experimental` — each with its own recipes (and
optional tuning configs, benchmark profiles, and shared mods) that `sparkrun`
can auto-discover and install via `@<registry-name>/<recipe-name>` syntax.

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
│   └── registry.yaml     # registry manifest declaring all three registries below
├── stable/               # nr3v0 — production-ready, vetted recipes
│   ├── recipes/
│   ├── tuning/
│   ├── benchmarking/
│   └── mods/
├── fast/                 # nr3v0-fast — throughput/latency-optimized recipes
│   ├── recipes/
│   ├── tuning/
│   ├── benchmarking/
│   └── mods/
├── experimental/         # nr3v0-experimental — unvetted, hidden by default
│   ├── recipes/
│   ├── tuning/
│   ├── benchmarking/
│   └── mods/
└── README.md
```

Each subdirectory follows the same layout: `recipes/` (recipe YAML files),
`tuning/` (optional kernel/runtime tuning configs), `benchmarking/` (optional
benchmark profiles), and `mods/` (optional shared mods).

## Registries

| Registry              | Path            | Visible by default    | Purpose                                           |
|-----------------------|-----------------|------------------------|----------------------------------------------------|
| `nr3v0`               | `stable/`       | Yes                    | Production-ready, vetted recipes                  |
| `nr3v0-fast`          | `fast/`         | Yes                    | Recipes tuned for throughput/latency, less vetted  |
| `nr3v0-experimental`  | `experimental/` | No (`visible: false`) | Work-in-progress / risky recipes, opt-in only      |

Hidden registries (`nr3v0-experimental`) don't show up in default listings but
are still usable via explicit `@nr3v0-experimental/<recipe-name>` references
or with `--all`.

## Usage

### Add a registry to sparkrun

```bash
sparkrun registry add nr3v0 <git-url-of-this-repo>
```

Because all three registries live in the same repo, adding it once makes
`nr3v0`, `nr3v0-fast`, and `nr3v0-experimental` all available — sparkrun uses
sparse checkout so it only fetches the subdirectories each registry declares.

### List available recipes

```bash
sparkrun recipe list @nr3v0               # stable
sparkrun recipe list @nr3v0-fast          # fast
sparkrun recipe list @nr3v0-experimental --all   # experimental (hidden by default)
```

### Run a recipe

```bash
sparkrun run @nr3v0/<recipe-name>
sparkrun run @nr3v0-fast/<recipe-name>
sparkrun run @nr3v0-experimental/<recipe-name>
```

### Adding a new recipe

1. Decide which registry it belongs in — `stable/`, `fast/`, or
   `experimental/` — and create a new YAML file under that registry's
   `recipes/` directory, named after the model/variant
   (e.g. `stable/recipes/my-model-vllm.yaml`).
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
   add it under that registry's `tuning/`, `benchmarking/`, or `mods/`
   respectively and reference it from the recipe.
4. Commit and push. `sparkrun` picks up changes the next time the registry
   is refreshed (`sparkrun registry update nr3v0`).

## Naming conventions

- Registry names (`nr3v0`, `nr3v0-fast`, `nr3v0-experimental`) avoid reserved
  prefixes (`sparkrun`, `official`, `arena`, `spark-arena`) as required by the
  sparkrun registry guidelines, and use suffixes to indicate maturity level.
- Recipe files should be named descriptively after the model and serving
  engine, e.g. `<model>-<engine>.yaml`.

## References

- Registry guidelines: https://sparkrun.dev/recipes/registries/#creating-a-registry
- Recipe format: https://sparkrun.dev/recipes/format/
