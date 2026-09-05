# mojo-protobuf

mojo-protobuf is a Protocol Buffers serializer written in [Mojo](https://www.modular.com/mojo).
The runtime and the code generator are Mojo. They do not wrap libprotobuf or any
other C, C++, or Rust protobuf library.

Protocol Buffers is a compact, schema-driven binary format. The format is
precise and easy to get wrong. These pages explain why the format exists, how
to use this library, and how a generated message looks on the wire.

| Page | Contents |
| --- | --- |
| [Why ProtoBuf](why-protobuf.md) | What the format is for, and why the encoder is not a small wrapper |
| [Instructions](instructions.md) | Install, generate Mojo from `.proto`, test, and CI secrets |
| [Examples](examples.md) | Encode and decode generated types |

Source: [github.com/leo-gan/gld-protobuf](https://github.com/leo-gan/gld-protobuf).
License: MIT.
