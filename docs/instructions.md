# Instructions

These steps install the library, generate Mojo from a `.proto` file, and run
the tests. The runtime needs **Mojo 1.0.0**. Code generation also needs
`protoc` on the host. `protoc` is not linked into the Mojo binary.

---

## Install

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
| `--unknown skip` | v0.1 only; unknown fields are dropped |

v0.1 codegen emits `bool`, `int32`, `int64`, `double`, `string`, nested
messages, and packed `repeated double`. Maps, oneof, proto2, and services
fail the CLI with a message on stderr.

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

---

## Continuous integration

Pull requests and pushes to `main` run `.github/workflows/ci.yml`:

1. `pixi install` and `pixi run test`
2. `mkdocs build --strict`

Pushes to `main` also run `.github/workflows/pages.yml`, which publishes this
site to GitHub Pages.

If the Modular channel requires a token in Actions, add a repository secret
named `PREFIX_API_KEY`. The test job passes it through as an environment
variable.

To serve the site locally:

```bash
pip install -r requirements-docs.txt
mkdocs serve
```
