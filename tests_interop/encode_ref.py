#!/usr/bin/env python3
"""Oracle encoder: text proto on stdin → binary on stdout via protoc --encode."""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROTO = ROOT / "testdata" / "proto" / "benchmark_v2.proto"


def main() -> int:
    message = sys.argv[1] if len(sys.argv) > 1 else "benchmark.v2.Message"
    protoc = shutil.which("protoc")
    if not protoc:
        print("protoc not found", file=sys.stderr)
        return 1
    proc = subprocess.run(
        [protoc, f"--encode={message}", f"-I{PROTO.parent}", PROTO.name],
        input=sys.stdin.buffer.read(),
        cwd=PROTO.parent,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    sys.stdout.buffer.write(proc.stdout)
    if proc.stderr:
        sys.stderr.buffer.write(proc.stderr)
    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main())
