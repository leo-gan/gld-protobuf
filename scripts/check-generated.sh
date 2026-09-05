#!/usr/bin/env bash
# Fail if generated sources are out of date.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
./scripts/generate.sh "$tmp"
diff -ru tests/generated "$tmp"
