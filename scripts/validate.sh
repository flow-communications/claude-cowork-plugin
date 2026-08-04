#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 -m json.tool "$repository_root/.claude-plugin/marketplace.json" >/dev/null
python3 -m json.tool "$repository_root/plugins/flow/.claude-plugin/plugin.json" >/dev/null

if command -v claude >/dev/null 2>&1; then
  claude plugin validate "$repository_root" --strict
else
  printf '%s\n' "Claude CLI not found; skipped Claude's schema validator."
fi
