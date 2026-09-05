#!/usr/bin/env bash
# Precompile the published packages: wire, runtime, protobuf.
# Optionally build the gld-protoc-mojo CLI into the same output directory.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
export PATH="${HOME}/.pixi/bin:${PATH}"

out="${1:-/tmp/mojo-protobuf-pkg}"
mkdir -p "$out"

if command -v pixi >/dev/null 2>&1; then
  MOJO=(pixi run mojo)
elif command -v mojo >/dev/null 2>&1; then
  MOJO=(mojo)
else
  echo "mojo not found; run scripts/ci-setup.sh" >&2
  exit 1
fi

"${MOJO[@]}" precompile -I src src/wire -o "$out/wire.mojoc"
"${MOJO[@]}" precompile -I src src/runtime -o "$out/runtime.mojoc"
"${MOJO[@]}" precompile -I src src/protobuf -o "$out/protobuf.mojoc"
"${MOJO[@]}" build -I src src/codegen/cli.mojo -o "$out/gld-protoc-mojo"
echo "wrote $out/wire.mojoc $out/runtime.mojoc $out/protobuf.mojoc $out/gld-protoc-mojo"
