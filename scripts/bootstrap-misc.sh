#!/usr/bin/env bash
# bootstrap-misc.sh — ensure the MIS compiler `misc` is available at ./bin/misc.
#
# This repo ships a prebuilt macOS `bin/misc` for zero-friction use. This script
# refreshes it, or rebuilds/fetches it on other platforms, so the repo stays
# 100% usable from a fresh clone.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
target="$here/bin/misc"
mkdir -p "$here/bin"

if [ -x "$target" ] && "$target" --help >/dev/null 2>&1; then
  echo "misc present and runnable: $target"
  exit 0
fi

# 1) copy a shared compiler from a parent checkout, if present
for c in "$here/../bin/misc" "$here/../../bin/misc"; do
  if [ -x "$c" ]; then cp "$c" "$target"; chmod +x "$target"; echo "misc copied from $c"; exit 0; fi
done

# 2) build from the CLRTY-MIS-Kernel Rust source (portable / any platform)
if command -v cargo >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
  tmp="$(mktemp -d)"
  if git clone --depth 1 https://github.com/clarity-fintech/CLRTY-MIS-Kernel "$tmp/k" >/dev/null 2>&1; then
    if [ -f "$tmp/k/Cargo.toml" ] && (cd "$tmp/k" && cargo build --release >/dev/null 2>&1); then
      bin="$(find "$tmp/k/target/release" -maxdepth 1 -name misc -type f | head -1)"
      if [ -n "$bin" ]; then cp "$bin" "$target"; chmod +x "$target"; echo "misc built from source"; exit 0; fi
    fi
    if [ -x "$tmp/k/bin/misc" ]; then cp "$tmp/k/bin/misc" "$target"; chmod +x "$target"; echo "misc fetched (prebuilt)"; exit 0; fi
  fi
fi

echo "ERROR: could not obtain misc. Build it from https://github.com/clarity-fintech/CLRTY-MIS-Kernel" >&2
exit 1
