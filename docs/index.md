# mojo-protobuf

mojo-protobuf is a Protocol Buffers serializer written in [Mojo](https://www.modular.com/mojo).
The runtime and the code generator are Mojo. They do not wrap libprotobuf or any
other C, C++, or Rust protobuf library.

<div class="grid cards" markdown="1">

-   __Why ProtoBuf__

    ---

    What the format is for, how tags and varints work on the wire, and why the
    encoder is not a small wrapper around a native library.

    [:octicons-arrow-right-24: Read Why ProtoBuf](why-protobuf.md)

-   __Instructions__

    ---

    Install Mojo 1.0.0 with pixi, generate Mojo from a `.proto` file, run the
    tests, and publish this site.

    [:octicons-arrow-right-24: Open Instructions](instructions.md)

-   __Examples__

    ---

    Encode and decode generated types, match official `protoc --encode` bytes,
    and round-trip an empty present submessage.

    [:octicons-arrow-right-24: See Examples](examples.md)

</div>

---

## What it does

| Feature | Meaning |
| --- | --- |
| From-scratch Mojo | The runtime and `gld-protoc-mojo` are Mojo. They do not wrap, link, or vendor libprotobuf. |
| proto3 wire | Varint, ZigZag, tags, packed and unpacked repeated values, and empty present submessages (`1a 00`). |
| FileDescriptorSet | A hand-written proto2 decoder reads the blob that `protoc --descriptor_set_out` writes. |
| Code generator | `gld-protoc-mojo` emits Mojo structs with explicit `encode_to` / `merge_from` methods. |
| Implicit presence | proto3 scalars omit zero, `false`, and empty string on encode. |
| Nested presence | A set-but-empty nested message is written as tag plus length 0. Official Python does the same. |
| Packed repeated | Encode writes one LEN record. Decode also accepts the older unpacked form. |
| Unknown fields | Generated types keep unknown records and write them back. `--unknown skip` is opt-in. |
| Interop | Golden vectors come from official `protoc --encode`. `tests_interop/` pipes the same bytes. |
| proto3 types | All proto3 scalars, enums, nested messages, packed and unpacked repeated, `oneof`, `map`, proto3 `optional`. |

`protoc` is a **build-time** host tool. Python `google.protobuf` is a **test
oracle**. Neither is required to encode or decode at runtime.

---

## Quick start

Install [pixi](https://pixi.sh/), then:

```bash
git clone https://github.com/leo-gan/gld-protobuf.git
cd gld-protobuf
pixi install
pixi run generate
```

Encode a generated `Message`:

```bash
pixi run mojo run -I src -I tests/generated examples/encode_message.mojo
```

Run the suite:

```bash
pixi run test
```

Requires **Mojo 1.0.0**. If `pixi install` fails on `conda.modular.com`, see
[Instructions](instructions.md).

---

## Encode example

`examples/encode_message.mojo` builds a `benchmark.v2.Message`, encodes it,
and decodes the same bytes:

```mojo
from benchmark.v2 import Message

def main() raises:
    var msg = Message()
    msg.f_bool = True
    msg.f_int32 = 150
    msg.f_string = "hi"
    var buf = msg.encode()
    var again = Message.decode(buf)
```

A fuller value matches official `protoc --encode` byte for byte. Field-by-field
hex and the empty-`meta` / packed-`repeated` cases are on
[Examples](examples.md).
