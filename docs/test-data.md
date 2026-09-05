# Test data

`testdata/` holds the schemas and oracle bytes that the tests compare against.
Those files are ordinary test inputs. They are not the library API and not a
product schema.

An **oracle** here is an official encoder or compiler whose output this
repository treats as correct. The Mojo runtime does not import those tools.
`protoc` and Python `google.protobuf` run only in scripts and interop
harnesses.

---

## Four trees

| Directory | What it holds | Why it exists |
| --- | --- | --- |
| [`testdata/proto/`](#schemas-testdataproto) | Hand-written `.proto` files | Local message shapes the unit tests generate and round-trip. |
| [`testdata/golden/`](#oracle-bytes-testdatagolden) | Official encode output (`.bin` + `.hex`) | Known wire bytes for varints, tags, and a few `benchmark.v2` messages. |
| [`testdata/descriptors/`](#descriptor-blobs-testdatadescriptors) | `protoc --descriptor_set_out` blobs | Layer 2 input: decode a real `FileDescriptorSet` without spawning `protoc` in the test. |
| [`testdata/conformance/`](#official-conformance-inputs-testdataconformance) | Official protobuf v29.3 test schemas | Inputs for the conformance adapter and for generating `TestAllTypesProto3`. |

A **FileDescriptorSet** is the binary proto2 message that `protoc` writes when
you pass `--descriptor_set_out`. Layer 2 is the hand-written decoder that
reads that blob so `gld-protoc-mojo` can emit Mojo.

---

## How the pieces connect

```text
testdata/proto/*.proto          authored schemas
        │
        ├── scripts/gen_golden.py          → testdata/golden/*.bin
        ├── scripts/gen_descriptors.sh     → testdata/descriptors/*.bin
        │                                      └── scripts/embed_descriptors.py
        │                                            → tests/descriptor_blobs.mojo
        └── scripts/generate.sh            → tests/generated/**  (plus conformance)
```

Mojo tests do not open the `.bin` files at runtime. Wire tests hard-code the
same bytes (see `tests/test_varint.mojo` and `tests/test_benchmark_v2.mojo`).
The committed `.bin` and `.hex` files are the oracle copy you can inspect or
regenerate.

`tests/generated/` is committed output of `pixi run generate`. CI runs
`scripts/check-generated.sh` so that tree cannot drift from the schemas.

---

## Schemas (`testdata/proto/`)

These files were written for this repository. They cover one concern each so
a failing test points at a single feature.

`scripts/generate.sh` compiles `benchmark_v2.proto`, `scalars.proto`, and
`features.proto`. The import pair and `legacy_proto2.proto` are descriptor
inputs only. They are not generated to Mojo.

### `benchmark_v2.proto`

Package `benchmark.v2`. This is the first test schema (v0.1). The shapes are
a common mixed-scalar / nested / packed set. The name `benchmark` is
historical. The file is not a product schema and is not shared with any other
repository.

| Type | Role |
| --- | --- |
| `Message` | Mixed scalars: `bool`, `int32`, `int64`, `double`, `string`, plus a second `bool` / `int32` / `string`. Used for the official `protoc --encode` byte match (`08 01 10 96 01 …`). |
| `Document` + `DocumentMeta` + `DocumentItem` | Nested message with explicit presence. An empty `meta` must encode as `1a 00` (tag 3, length 0), not be omitted. |
| `Telemetry` | Packed `repeated double` (`values`) plus `repeated string` (`tags`). Encode writes one LEN record. Decode also accepts unpacked I64 records. |
| `Strings`, `Event` + `EventAttr` | Repeated strings and a small nested-attribute shape. |
| `BatchMessage`, `BatchDocument`, `BatchTelemetry`, `BatchStrings`, `BatchEvent` | A `repeated` wrapper around each of the types above, so codegen and the descriptor decoder see batches as well as singles. |

The descriptor blob for this file contains **13** messages. Unit tests focus
on `Message`, `Document`, and `Telemetry`. The remaining types keep the
original set complete so generation and Layer 2 still see every shape.

Examples and `tests_interop/` use the same `Message` text:

```text
f_bool: true f_int32: 150 f_int64: 1 f_float64: 1.5 f_string: "hi"
```

### `scalars.proto`

Package `scalars`. `benchmark.v2.Message` only needs a few scalar types.
This file holds the rest of proto3.

| Field / type | Why it is here |
| --- | --- |
| `uint32`, `uint64`, `sint32`, `sint64` | Unsigned varints and ZigZag signed varints. ZigZag stores the sign in the low bit so small negatives stay small on the wire. |
| `fixed32`, `fixed64`, `sfixed32`, `sfixed64`, `float` | I32 / I64 wire types that `Message` does not use. |
| `bytes data` | Length-delimited payload that is not UTF-8. |
| `Color` enum (`COLOR_UNSPECIFIED`, `RED`, `BLUE`) | Enum as varint. Unknown numeric values must be retained. |
| `repeated sint32 packed_s32` | Default proto3 packed repeated. |
| `repeated sint32 unpacked_s32 [packed = false]` | Older unpacked form. Encode writes one tag per element. |
| `optional int32 maybe` | proto3 explicit presence. Zero is written when the field is set. The generated type is `Optional[Int32]`. |

`tests/test_scalars.mojo` round-trips a fully populated `Scalars`, including
`maybe = 0`.

### `features.proto`

Package `features`. One message, `Holder`, covers the two remaining proto3
features.

| Field | Why it is here |
| --- | --- |
| `oneof payload { string name = 1; int32 id = 2; }` | At most one arm is set. The last record on the wire wins. An empty `name` is still present. |
| `map<string, int32> attrs` | String-keyed map. Maps encode as repeated entries. A later entry with the same key replaces the earlier one. |
| `map<int32, string> labels` | Integer-keyed map, so both key wire types are generated. |

`tests/test_features.mojo` covers last-wins oneof, empty-string presence, map
round-trip, and unknown-field preservation.

### `import_child.proto` and `import_parent.proto`

Packages `imp.child` and `imp.parent`. `Parent` has one field of type
`imp.child.Child`. The parent file uses `import public`.

Layer 2 must decode a **multi-file** `FileDescriptorSet`. `public import`
fills `public_dependency` with a non-empty unpacked `repeated int32` (the
index `0` into `dependency`). A single-file blob would leave that field
empty and would not exercise that decoder path.

These two files are not passed to `scripts/generate.sh`.

### `legacy_proto2.proto`

Package `legacy`. Syntax `proto2`, one message `Box`.

Codegen accepts proto3 only. This file exists so
`tests/test_descriptor.mojo` can assert that `proto3_error` is non-empty
when `syntax` is not `"proto3"`. It is not generated to Mojo.

---

## Oracle bytes (`testdata/golden/`)

Produced by `python3 scripts/gen_golden.py`. Do not edit the `.bin` files
by hand. Re-run the script after you change a test `.proto` that those
vectors encode.

Each `.bin` has a sibling `.hex` (space-separated bytes) so a human can
read the same vector.

Varints use Python `google.protobuf.internal.encoder._VarintBytes`. Message
vectors use `protoc --encode` against `benchmark_v2.proto`. One vector,
`telemetry_unpacked_values.bin`, is built by hand because official encoders
always emit packed `repeated double`.

| File | Bytes | Why |
| --- | --- | --- |
| `varint_0.bin` | `00` | Smallest varint. |
| `varint_127.bin` | `7f` | Last value that fits in one byte. |
| `varint_128.bin` | `80 01` | First two-byte varint. The high bit of `80` means “another byte follows”. |
| `varint_150.bin` | `96 01` | The [protobuf.dev](https://protobuf.dev/programming-guides/encoding/) example. |
| `varint_300.bin` | `ac 02` | Another two-byte value (`300 = 44 + 2×128`). |
| `varint_u64_max.bin` | `ff ff ff ff ff ff ff ff ff 01` | Largest unsigned 64-bit value. Ten bytes. |
| `varint_int32_neg1.bin` | same ten bytes | proto3 `int32` −1 sign-extends to 64 bits, so it uses the same encoding as `u64` max. |
| `tag1_int32_150.bin` | `08 96 01` | Field 1, wire type VARINT, value 150. Tag `(1 << 3) \| 0 = 8`. |
| `message_populated.bin` | `08 01 10 96 01 18 01 21 00 00 00 00 00 00 f8 3f 2a 02 68 69` | Official encode of the `Message` text above. |
| `document_empty_meta.bin` | `0a 01 78 10 01 1a 00` | `id = "x"`, `status = 1`, empty present `meta`. |
| `telemetry_packed.bin` | `0a 01 73 10 09 1a 01 61 22 10 …` | Official packed `values` (`1.0`, `2.0`) plus `source = "s"`, `ts = 9`, `tags = "a"`. |
| `telemetry_unpacked_values.bin` | `0a 01 73 10 09 21 … 21 …` | Legal unpacked form: two I64 records for field 4. Decode must accept this. Encode still writes packed. |

`message_populated.bin` is the byte-for-byte check in
`tests/test_roundtrip_manual.mojo` (hand-written types) and
`tests/test_benchmark_v2.mojo` (generated types).

---

## Descriptor blobs (`testdata/descriptors/`)

Produced by `scripts/gen_descriptors.sh` (`protoc --descriptor_set_out
--include_imports`). The same bytes are embedded as Mojo helpers in
`tests/descriptor_blobs.mojo` so `tests/test_descriptor.mojo` does not
depend on filesystem paths.

| File | Source | Why |
| --- | --- | --- |
| `benchmark_v2.bin` | `benchmark_v2.proto` | One file, package `benchmark.v2`, 13 messages, packed `Telemetry.values`. Checks names, numbers, labels, and `is_packed`. |
| `import_parent.bin` | `import_parent.proto` + child | Two files. `public_dependency = [0]`. Checks multi-file `dependency` / `public_dependency` and the field type `.imp.child.Child`. |
| `legacy_proto2.bin` | `legacy_proto2.proto` | Syntax gate: `proto3_error` must be non-empty. |

Regenerate both the blobs and the embedded helpers with
`scripts/gen_descriptors.sh`. Do not edit `tests/descriptor_blobs.mojo` by
hand.

---

## Official conformance inputs (`testdata/conformance/`)

Vendored from [protocolbuffers/protobuf](https://github.com/protocolbuffers/protobuf)
**v29.3**. License is BSD (see the header in each file). These are **test
inputs**. The runtime does not link official protobuf libraries.

`scripts/generate.sh` compiles this tree and emits Mojo under
`tests/generated/{conformance,google/protobuf,protobuf_test_messages/proto3}/`.

| Path | Why it is here |
| --- | --- |
| `conformance.proto` | Official pipe messages: `ConformanceRequest`, `ConformanceResponse`, `FailureSet`, `WireFormat`. The adapter speaks this protocol (uint32 little-endian length, then the request). |
| `test_messages_proto3.proto` | Official proto3 kitchen-sink type `protobuf_test_messages.proto3.TestAllTypesProto3`. That is the only payload type the adapter accepts. |
| `google/protobuf/any.proto` | Well-known `Any`. Imported by `TestAllTypesProto3`. |
| `google/protobuf/duration.proto` | Well-known `Duration`. |
| `google/protobuf/timestamp.proto` | Well-known `Timestamp`. |
| `google/protobuf/field_mask.proto` | Well-known `FieldMask`. |
| `google/protobuf/struct.proto` | Well-known `Struct` / `Value` / `ListValue`. Generated as `struct_.mojo` because `struct` is a Mojo keyword. |
| `google/protobuf/wrappers.proto` | Well-known wrappers (`Int32Value`, `StringValue`, …). |

The adapter handles **binary proto3** `TestAllTypesProto3` only. JSON, text,
JSPB, proto2, and editions requests are skipped. See
[Instructions](instructions.md#conformance).

Mojo 1.0 cannot form a `Deinitable` `Optional` of a type that refers back to
itself. Codegen therefore omits cyclic fields on `TestAllTypesProto3` and
lets those records fall through to `UnknownFieldSet`. The `.proto` file is
still the official schema; the generated struct is a subset.

---

## Derived trees (not under `testdata/`)

These are produced from the files above. They are not a second set of
schemas.

| Path | Produced by | Role |
| --- | --- | --- |
| `tests/generated/` | `scripts/generate.sh` | Generated Mojo for `benchmark.v2`, `scalars`, `features`, conformance, and well-known types. Committed. |
| `tests/descriptor_blobs.mojo` | `scripts/embed_descriptors.py` | The three descriptor blobs as `List[Byte]` helpers. |
| `tests/manual_types.mojo` | Hand-written | Types that match `benchmark.v2` so Layer 1 could be tested before codegen existed. Still used by `tests/test_packed.mojo` and `tests/test_roundtrip_manual.mojo`. |
| `tests_interop/` | Hand-written | Shell + Python that call `protoc --encode` / `--decode` on the same `Message` text. Raw protobuf bytes. No length prefix. |

---

## Regenerating

| Command | Writes |
| --- | --- |
| `python3 scripts/gen_golden.py` | `testdata/golden/*.bin` and `*.hex` |
| `scripts/gen_descriptors.sh` | `testdata/descriptors/*.bin` and `tests/descriptor_blobs.mojo` |
| `pixi run generate` | `tests/generated/` |

`gen_golden.py` needs `protoc` and Python `google.protobuf`.
`gen_descriptors.sh` and `generate.sh` need `protoc`. None of those tools
are required to encode or decode at runtime.
