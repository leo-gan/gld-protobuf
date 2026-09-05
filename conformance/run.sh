#!/usr/bin/env bash
# Run the official conformance_test_runner against the Mojo adapter.
# Skips (exit 0) when the runner is not installed.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
export PATH="${HOME}/.pixi/bin:${PATH}"

runner="${CONFORMANCE_TEST_RUNNER:-}"
if [[ -z "$runner" ]]; then
  runner="$(command -v conformance_test_runner || true)"
fi
if [[ -z "$runner" || ! -x "$runner" ]]; then
  echo "conformance_test_runner not found; official suite skipped" >&2
  echo "Set CONFORMANCE_TEST_RUNNER to the official binary to run it." >&2
  exit 0
fi

adapter=(pixi run mojo run -I src -I tests/generated conformance/adapter.mojo)
exec "$runner" \
  --enforce_recommended \
  --failure_list "$root/conformance/failures.txt" \
  -- \
  "${adapter[@]}"
