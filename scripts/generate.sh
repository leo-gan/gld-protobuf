#!/usr/bin/env bash
# Generate Mojo sources from testdata/proto/*.proto.
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
  testdata/proto/benchmark_v2.proto \
  testdata/proto/scalars.proto \
  testdata/proto/features.proto
pixi run mojo run -I src src/codegen/cli.mojo \
  -- --descriptor-set "$tmp" --out "$out" \
  --proto benchmark_v2.proto \
  --proto scalars.proto \
  --proto features.proto
echo "generated under $out"
