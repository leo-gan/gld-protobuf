# Examples

These examples use the generated `benchmark.v2` types. Generate them with
`pixi run generate` if `tests/generated/` is missing.

## Encode and decode a `Message`

`examples/encode_message.mojo`:

```mojo
from benchmark.v2 import Message

def main() raises:
    var msg = Message()
    msg.f_bool = True
    msg.f_int32 = 150
    msg.f_string = "hi"
    var buf = msg.encode()
    print("encoded", len(buf), "bytes")
    var again = Message.decode(buf)
    print("round-trip", again.f_int32, again.f_string)
```

```bash
pixi run mojo run -I src -I tests/generated examples/encode_message.mojo
```

A fuller value (`f_bool=true`, `f_int32=150`, `f_int64=1`, `f_float64=1.5`,
`f_string="hi"`) matches official `protoc --encode` byte for byte:

```text
08 01 10 96 01 18 01 21 00 00 00 00 00 00 f8 3f 2a 02 68 69
```

| Bytes | Meaning |
| --- | --- |
| `08 01` | field 1, varint, `true` |
| `10 96 01` | field 2, varint, `150` |
| `18 01` | field 3, varint, `1` |
| `21` + 8 bytes | field 4, I64, IEEE-754 `1.5` |
| `2a 02 68 69` | field 5, LEN 2, `hi` |

Zero, `false`, and empty strings are omitted. That is proto3 implicit
presence.

## Empty present submessage

A set-but-empty nested message is not omitted. `Document.meta` is field 3.

```mojo
from benchmark.v2 import Document, DocumentMeta

def main() raises:
    var doc = Document()
    doc.id = "x"
    doc.status = 1
    doc.meta = DocumentMeta()
    var buf = doc.encode()
    # 0a 01 78   id = "x"
    # 10 01      status = 1
    # 1a 00      meta present, length 0
```

Official Python emits the same `1a 00`. A second LEN record for field 3
**merges** into the existing `DocumentMeta`; it does not replace it.

## Packed `repeated double`

`Telemetry.values` encodes as one packed LEN (field 4, tag `22`).

```mojo
from benchmark.v2 import Telemetry

def main() raises:
    var tel = Telemetry()
    tel.source = "s"
    tel.ts = 9
    tel.values.append(1.0)
    tel.values.append(2.0)
    var buf = tel.encode()
    var got = Telemetry.decode(buf)
```

The decoder also accepts **unpacked** `I64` records for the same field. Both
forms are legal proto3. Generated encode always writes packed.

## Interop with `protoc`

```bash
printf 'f_bool: true f_int32: 150 f_string: "hi"\n' \
  | python3 tests_interop/encode_ref.py benchmark.v2.Message \
  > message.bin

python3 tests_interop/decode_ref.py benchmark.v2.Message < message.bin
```

Those scripts call `protoc --encode` and `protoc --decode`. The pipe is raw
protobuf bytes. There is no length prefix. The official conformance runner
uses a 4-byte little-endian length prefix; do not mix the two.
