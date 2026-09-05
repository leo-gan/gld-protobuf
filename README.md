# mojo-protobuf

A from-scratch Protocol Buffers implementation for [Mojo](https://mojolang.org/).
The runtime and the code generator are written in Mojo. They do not wrap, link,
or vendor libprotobuf, protobuf-c, nanopb, protozero, prost, or any other C,
C++, or Rust protobuf library.

`protoc` is a **build-time host tool** only. It compiles `.proto` files to a
`FileDescriptorSet`. Python `google.protobuf` is a **test oracle** for golden
byte vectors. Neither is required to encode or decode at runtime.

This repository is a standalone library. It is not part of any other project.

## Status

Phase 0 (wire format) and Phase 1 (`FileDescriptorSet` decoder) are implemented.
Code generation from `.proto` files is the next phase. See [DESIGN.md](DESIGN.md).

Requires **Mojo 1.0.0**.

## Layout

```text
src/wire/         # Layer 1: wire primitives
src/descriptor/   # Layer 2: FileDescriptorSet decoder (later)
src/codegen/      # Layer 3: gld-protoc-mojo (later)
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

MIT. Official Protocol Buffers is BSD-3-Clause; the licenses are not the same.
