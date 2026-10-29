#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"
target="${MOONBIT_TEST_TARGET:-wasm-gc}"
tool_dir="$(mktemp -d)"
trap 'rm -rf "$tool_dir"' EXIT
moon install ./debug_deriving --bin "$tool_dir"
export PATH="$tool_dir:$PATH"
for module in debug debug_deriving debug_deriving_examples debug_deriving_examples_local_deps; do
  moon -C "$module" fmt --check
  moon -C "$module" check --target "$target" --deny-warn
  moon -C "$module" build --target "$target" --deny-warn
  moon -C "$module" test --target "$target" --deny-warn
done
