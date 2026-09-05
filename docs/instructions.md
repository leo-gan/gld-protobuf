# Instructions

These steps install the library, generate Mojo from a `.proto` file, and run
the tests. The runtime needs **Mojo 1.0.0**. Code generation also needs
`protoc` on the host. `protoc` is not linked into the Mojo binary.

---

## Install

Published package (linux-64):

```bash
pixi add --channel https://prefix.dev/leo-gan/leo-gan mojo-protobuf
```

The channel is [prefix.dev/leo-gan/leo-gan](https://prefix.dev/leo-gan/leo-gan). The package name is `mojo-protobuf`. It needs `mojo-compiler` 1.0. After install, `from protobuf import …` resolves with no extra `-I`, and `gld-protoc-mojo` is on `PATH`.

A GitHub Release on this repository builds `conda.recipe/recipe.yaml` and uploads that package. Do not publish from a pull request or from every push to `main`.

### From a git checkout

1. Install [pixi](https://pixi.sh/).
2. Clone the repository and install the environment:

```bash
git clone https://github.com/leo-gan/gld-protobuf.git
cd gld-protobuf
pixi install
pixi run mojo --version   # expect Mojo 1.0.0
```

!!! note "Modular channel token"

    If `pixi install` fails with 401 or 403 on `conda.modular.com`, set
    `PREFIX_API_KEY` (or the Modular token from the Mojo install docs) and run
    `scripts/ci-setup.sh`.

For codegen, install `protoc` (the `protobuf-compiler` package on Debian and
Ubuntu, or any 3.21+ release).

### Local precompile

`pixi run precompile` writes `wire.mojoc`, `runtime.mojoc`, `protobuf.mojoc`,
and the `gld-protoc-mojo` binary (default output `/tmp/mojo-protobuf-pkg`).
The conda recipe `conda.recipe/recipe.yaml` installs those artifacts under
`$PREFIX/lib/mojo/` and `$PREFIX/bin`. It pins `mojo-compiler ==1.0.0`.

```bash
pixi run precompile
mojo run -I /tmp/mojo-protobuf-pkg your_app.mojo
```

---

## Generate Mojo from a `.proto` file

`gld-protoc-mojo` reads a `FileDescriptorSet` and writes `.mojo` files.

=== "pixi generate"

    ```bash
    pixi run generate
    ```

    That script runs `protoc --descriptor_set_out` on
    `testdata/proto/benchmark_v2.proto`, then the Mojo CLI. Output lands in
    `tests/generated/benchmark/v2/`.

=== "descriptor set + CLI"

    ```bash
    protoc --descriptor_set_out=fds.bin --include_imports \
      -I testdata/proto testdata/proto/benchmark_v2.proto
    pixi run mojo run -I src src/codegen/cli.mojo -- \
      --descriptor-set fds.bin --out tests/generated --proto benchmark_v2.proto
    ```

| Flag | Meaning |
| --- | --- |
| `--out DIR` | Root of the generated tree |
| `--descriptor-set FILE` | Use this blob; do not spawn `protoc` |
| `--proto FILE` | Which file in the set to emit (basename) |
| `--proto-path DIR` | `-I` when the CLI runs `protoc` |
| `--module-prefix P` | Extra directory under `--out`, prepended once |
| `--unknown preserve` | Default. Store unknown records and write them back |
| `--unknown skip` | Drop unknown fields on re-encode (official proto3 deviation) |

Codegen emits proto3 scalars, enums, nested messages, packed and unpacked
repeated fields, `oneof`, `map`, and proto3 `optional`. Groups, proto2
`required`, editions, and services fail the CLI with a message on stderr.

---

## Use generated types

Point the compiler at `src` and the generated tree:

```bash
pixi run mojo run -I src -I tests/generated examples/encode_message.mojo
```

```mojo
from benchmark.v2 import Message

def main() raises:
    var msg = Message()
    msg.f_bool = True
    msg.f_int32 = 150
    var buf = msg.encode()
    var again = Message.decode(buf)
```

`from protobuf import …` resolves through `-I src`. After `mojo precompile`,
the package can be installed as `protobuf.mojoc`.

---

## Test

```bash
pixi run test
```

That runs every `tests/test_*.mojo` file with `-I src -I tests -I tests/generated`.

Golden byte files under `testdata/golden/` come from
`python3 scripts/gen_golden.py` (official `protoc --encode` and Python
varint helpers). Re-run that script if you change a test `.proto` file.
What each testdata file is for is listed on [Test data](test-data.md).

---

## Continuous integration

Pull requests and pushes to `main` run `.github/workflows/ci.yml`:

1. `pixi install` and `pixi run test`
2. `mkdocs build --strict`

Pushes to `main` also run `.github/workflows/pages.yml`, which publishes this
site to GitHub Pages.

If the Modular channel requires a token in Actions, add a repository secret
named `PREFIX_API_KEY`. The test job and the publish job pass it through as
an environment variable when resolving `mojo-compiler`.

### Publish

`.github/workflows/publish.yml` runs when a GitHub Release is published
(and can be started by hand). It builds `conda.recipe/recipe.yaml` and
uploads `mojo-protobuf` to [prefix.dev/leo-gan/leo-gan](https://prefix.dev/leo-gan/leo-gan).

One-time channel setup: in the prefix.dev channel, under **Settings →
Repository access**, allow GitHub `leo-gan/gld-protobuf`, workflow
`publish.yml`, environment `prefix.dev`, access **Read/write**. Upload uses
OIDC (`id-token: write`). It does not store a prefix.dev API key in the
repository.

---

## Conformance

`conformance/adapter.mojo` speaks the official runner protocol: a
little-endian `uint32` length, then a `ConformanceRequest`. It handles
**binary proto3** `TestAllTypesProto3` only. JSON, text, JSPB, proto2, and
editions are skipped.

```bash
pixi run generate
conformance/run.sh   # no-op unless conformance_test_runner is on PATH
```

Set `CONFORMANCE_TEST_RUNNER` to the official binary to run the suite.
Known limits are listed in `conformance/failures.txt`.

To serve the site locally:

```bash
pip install -r requirements-docs.txt
mkdocs serve
```
