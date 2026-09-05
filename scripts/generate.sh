#!/usr/bin/env bash
# Generate Mojo sources from testdata proto trees.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
out="${1:-tests/generated}"
mkdir -p "$out"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
export PATH="${HOME}/.pixi/bin:${PATH}"
protoc --descriptor_set_out="$tmp" --include_imports \
  -I testdata/proto \
  -I testdata/conformance \
  testdata/proto/benchmark_v2.proto \
  testdata/proto/scalars.proto \
  testdata/proto/features.proto \
  testdata/conformance/test_messages_proto3.proto \
  testdata/conformance/conformance.proto
pixi run mojo run -I src src/codegen/cli.mojo \
  -- --descriptor-set "$tmp" --out "$out" \
  --proto benchmark_v2.proto \
  --proto scalars.proto \
  --proto features.proto \
  --proto test_messages_proto3.proto \
  --proto conformance.proto \
  --proto any.proto \
  --proto duration.proto \
  --proto field_mask.proto \
  --proto struct.proto \
  --proto timestamp.proto \
  --proto wrappers.proto
echo "generated under $out"
