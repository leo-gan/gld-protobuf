#!/usr/bin/env python3
"""Write testdata/golden/* using official protobuf tools as the oracle.

Varints use Python `google.protobuf` encoders. Messages use `protoc --encode`.
The Mojo runtime does not import these tools.
"""

from __future__ import annotations

import shutil
import struct
import subprocess
from pathlib import Path

from google.protobuf.internal.encoder import _EncodeVarint, _VarintBytes
from google.protobuf.internal.wire_format import (
    WIRETYPE_FIXED64,
    WIRETYPE_LENGTH_DELIMITED,
    WIRETYPE_VARINT,
    PackTag,
)

ROOT = Path(__file__).resolve().parents[1]
GOLDEN = ROOT / "testdata" / "golden"
PROTO = ROOT / "testdata" / "proto" / "benchmark_v2.proto"


def write_bin(name: str, data: bytes) -> None:
    path = GOLDEN / name
    path.write_bytes(data)
    (GOLDEN / (name + ".hex")).write_text(data.hex(" ") + "\n", encoding="utf-8")
    print(f"{name}: {data.hex(' ')}")


def tag(field: int, wire: int) -> bytes:
    return _VarintBytes(PackTag(field, wire))


def protoc_encode(message: str, text: str) -> bytes:
    """Official encoder via `protoc --encode` (no generated Python stubs)."""
    protoc = shutil.which("protoc")
    if not protoc:
        raise SystemExit("protoc not found on PATH")
    proc = subprocess.run(
        [protoc, f"--encode={message}", f"-I{PROTO.parent}", str(PROTO.name)],
        input=text.encode("utf-8"),
        cwd=PROTO.parent,
        check=True,
        stdout=subprocess.PIPE,
    )
    return proc.stdout


def main() -> int:
    GOLDEN.mkdir(parents=True, exist_ok=True)

    # Spec examples (protobuf.dev encoding).
    write_bin("varint_150.bin", _VarintBytes(150))  # 96 01
    write_bin("tag1_int32_150.bin", tag(1, WIRETYPE_VARINT) + _VarintBytes(150))

    buf = bytearray()
    _EncodeVarint(buf.extend, 0)
    write_bin("varint_0.bin", bytes(buf))
    write_bin("varint_127.bin", _VarintBytes(127))
    write_bin("varint_128.bin", _VarintBytes(128))
    write_bin("varint_300.bin", _VarintBytes(300))
    write_bin("varint_u64_max.bin", _VarintBytes((1 << 64) - 1))

    # proto3 int32 -1 is a 10-byte signed varint (0xff * 10).
    neg = bytearray()
    _EncodeVarint(neg.extend, (1 << 64) - 1)  # same as sign-extended -1
    write_bin("varint_int32_neg1.bin", bytes(neg))

    write_bin(
        "message_populated.bin",
        protoc_encode(
            "benchmark.v2.Message",
            'f_bool: true f_int32: 150 f_int64: 1 f_float64: 1.5 f_string: "hi"',
        ),
    )
    write_bin(
        "document_empty_meta.bin",
        protoc_encode(
            "benchmark.v2.Document",
            'id: "x" status: 1 meta {}',
        ),
    )
    write_bin(
        "telemetry_packed.bin",
        protoc_encode(
            "benchmark.v2.Telemetry",
            'source: "s" ts: 9 tags: "a" values: 1 values: 2',
        ),
    )

    # Unpacked repeated double is legal proto3; official encoders emit packed.
    unpacked = (
        tag(1, WIRETYPE_LENGTH_DELIMITED)
        + _VarintBytes(1)
        + b"s"
        + tag(2, WIRETYPE_VARINT)
        + _VarintBytes(9)
        + tag(4, WIRETYPE_FIXED64)
        + struct.pack("<d", 1.0)
        + tag(4, WIRETYPE_FIXED64)
        + struct.pack("<d", 2.0)
    )
    write_bin("telemetry_unpacked_values.bin", unpacked)

    (GOLDEN / "README.md").write_text(
        "Golden byte vectors produced by `scripts/gen_golden.py` using official\n"
        "Python protobuf (`SerializeToString` / `_VarintBytes`). Do not hand-edit\n"
        "the `.bin` files. Re-run the script after changing testdata/proto.\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
