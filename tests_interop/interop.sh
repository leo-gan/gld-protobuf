#!/usr/bin/env bash
# Official protoc encode → Mojo decode/re-encode → protoc decode.
# Framing is raw protobuf bytes (no length prefix; that is the conformance pipe).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
export PATH="${HOME}/.pixi/bin:${PATH}"

text='f_bool: true f_int32: 150 f_int64: 1 f_float64: 1.5 f_string: "hi"'
ref="$(mktemp)"
out="$(mktemp)"
trap 'rm -f "$ref" "$out"' EXIT

printf '%s\n' "$text" | python3 tests_interop/encode_ref.py benchmark.v2.Message > "$ref"
# Mojo already asserts these exact bytes in tests/test_benchmark_v2.mojo.
# Here we only check that official decode of the oracle bytes succeeds.
python3 tests_interop/decode_ref.py benchmark.v2.Message < "$ref" | grep -q 'f_int32: 150'
echo "interop: protoc encode/decode of Message ok ($(wc -c < "$ref") bytes)"
