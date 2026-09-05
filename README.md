# mojo-protobuf

A from-scratch Protocol Buffers implementation for [Mojo](https://mojolang.org/).
The runtime and the code generator are written in Mojo. They do not wrap, link,
or vendor libprotobuf, protobuf-c, nanopb, protozero, prost, or any other C,
C++, or Rust protobuf library.

`protoc` is a **build-time host tool** only. It compiles `.proto` files to a
`FileDescriptorSet`. Python `google.protobuf` is a **test oracle** for golden
byte vectors. Neither is required to encode or decode at runtime.

This repository is a standalone library. It is not part of any other project.

Documentation: [Why ProtoBuf](https://leo-gan.github.io/gld-protobuf/why-protobuf/),
[Instructions](https://leo-gan.github.io/gld-protobuf/instructions/),
[Examples](https://leo-gan.github.io/gld-protobuf/examples/).

## Install

From a git checkout (development):

```bash
git clone https://github.com/leo-gan/gld-protobuf.git
cd gld-protobuf
pixi install
pixi run test
```

To consume the library as precompiled packages plus the codegen CLI:

```bash
pixi run precompile          # writes /tmp/mojo-protobuf-pkg/{protobuf,wire,runtime}.mojoc
                             # and gld-protoc-mojo
```

`from protobuf import …` then resolves from that directory (`mojo run -I /tmp/mojo-protobuf-pkg …`) or, after a conda install, from `$PREFIX/lib/mojo/` with no extra `-I`.

The conda recipe is `conda.recipe/recipe.yaml` (package name `mojo-protobuf`, pin `mojo-compiler ==1.0.0`). Build with [rattler-build](https://prefix-dev.github.io/rattler-build/):

```bash
rattler-build build \
  --recipe conda.recipe/recipe.yaml \
  -c conda-forge \
  -c https://conda.modular.com/max
```

That install puts `protobuf.mojoc` (and `wire` / `runtime`) in `$PREFIX/lib/mojo/` and `gld-protoc-mojo` on `PATH`.

## Status

Phases 0–5 are implemented: wire format, `FileDescriptorSet` decoder,
`gld-protoc-mojo` for proto3 messages, unknown-field preservation, a binary
conformance adapter, and a conda recipe that precompiles `protobuf.mojoc`.
See [DESIGN.md](DESIGN.md).

```bash
pixi run generate    # testdata/proto/benchmark_v2.proto → tests/generated/
```

Requires **Mojo 1.0.0**.

## Layout

```text
src/wire/         # Layer 1: wire primitives
src/descriptor/   # Layer 2: FileDescriptorSet decoder
src/codegen/      # Layer 3: gld-protoc-mojo
src/runtime/      # Layer 4: ProtoMessage, DecodeError
src/protobuf/     # public facade (`from protobuf import …`)
```

## Develop

Install [pixi](https://pixi.sh/), then:

```bash
pixi install
pixi run test
```

If `pixi` cannot see the Modular channel, see `scripts/ci-setup.sh`. A Modular
or prefix.dev token may be required depending on how the channel is published.

Regenerate golden vectors (needs `protoc` and Python `protobuf`):

```bash
python3 scripts/gen_golden.py
```

Tests import the library with `-I src`:

```bash
mojo run -I src tests/test_varint.mojo
```

## License

MIT. Copyright (c) 2026 Leonid Ganeline.

Official Protocol Buffers is BSD-3-Clause; the licenses are not the same.
