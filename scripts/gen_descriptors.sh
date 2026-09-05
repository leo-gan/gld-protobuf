#!/usr/bin/env bash
# Rebuild testdata/descriptors/*.bin and the embedded Mojo blobs used by tests.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
protoc --descriptor_set_out=testdata/descriptors/benchmark_v2.bin \
  --include_imports -I testdata/proto testdata/proto/benchmark_v2.proto
protoc --descriptor_set_out=testdata/descriptors/import_parent.bin \
  --include_imports -I testdata/proto testdata/proto/import_parent.proto
protoc --descriptor_set_out=testdata/descriptors/legacy_proto2.bin \
  --include_imports -I testdata/proto testdata/proto/legacy_proto2.proto
python3 scripts/embed_descriptors.py
echo "wrote testdata/descriptors/*.bin and tests/descriptor_blobs.mojo"
