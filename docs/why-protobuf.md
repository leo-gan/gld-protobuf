# Why ProtoBuf

Protocol Buffers (protobuf) is a **schema-driven binary format**. You write
message types in a `.proto` file. A generator turns that schema into code.
The code writes and reads a defined sequence of tags and payloads.

JSON is easier to read. Protobuf is smaller on the wire and has a single
agreed layout across languages. That is why services that already speak
protobuf stay on it, even when the encoder is unpleasant to write.

---

## What the wire looks like

Every field is a **tag** plus a **payload**. The tag is an unsigned varint:
`(field_number << 3) | wire_type`. There are four wire types this library
implements:

| ID | Name | Used for |
| --- | --- | --- |
| 0 | VARINT | `int32`, `int64`, `bool`, enums |
| 1 | I64 | `double`, `fixed64` |
| 2 | LEN | strings, bytes, nested messages, packed repeated values |
| 5 | I32 | `float`, `fixed32` |

A varint stores an integer in one to ten bytes. Each byte holds seven data
bits. The high bit says whether another byte follows. Negative proto3
`int32` values sign-extend to 64 bits, so they always take ten bytes.

That is the first reason the protocol is not small: the encoder must get
varints, field numbers, and length prefixes exactly right, or another
language’s official parser will reject the bytes.

---

## Why a schema helps

The `.proto` file is the contract. Field **numbers** stay stable when you
rename a field. A new field with a new number can be added without breaking
old readers, as long as both sides follow the same presence rules.

proto3 scalars have **implicit presence**: a zero, `false`, or empty string
is omitted on encode. A singular nested message has **explicit presence**:
if the field is set, it is written even when it is empty (`tag + LEN 0`).
Official Python writes an empty `Document.meta` as `1a 00`. This library
matches that.

Numeric `repeated` fields are **packed** by default in proto3: one LEN
record that holds concatenated values. A decoder must also accept the older
unpacked form (one tag per element). Both are legal on the wire.

---

## What this library does not hide

Many language bindings call into C++ libprotobuf. That is a large native
dependency, and a Mojo benchmark of that path would measure C++, not Mojo.

mojo-protobuf encodes and decodes the binary format in Mojo. `protoc` is
only a **build-time** compiler. It emits a `FileDescriptorSet` blob. A
hand-written Mojo decoder reads that blob. `gld-protoc-mojo` then writes
Mojo structs with explicit `encode_to` / `merge_from` methods.

There is no reflection codec. Mojo can list struct fields, but it cannot
see protobuf field numbers or the difference between `int32` and `sint32`.
Those facts live in the generated methods.

!!! warning "Unknown fields in v0.1"

    Unknown fields are **skipped and dropped** on re-encode. Official proto3
    libraries preserve them. That is a documented deviation and is planned to
    change. Do not use this library as a schema-evolution proxy until
    preservation ships.

---

## When to use it

Use protobuf here when you need bytes that official Python, Go, or `protoc
--decode` can read, and you want the encode path to stay in Mojo.

Use JSON or another format when you need a human-editable file and do not
already have a `.proto` contract.
