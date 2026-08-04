#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 -m json.tool "$repository_root/.claude-plugin/marketplace.json" >/dev/null
python3 -m json.tool "$repository_root/plugins/flow/.claude-plugin/plugin.json" >/dev/null
python3 -m json.tool "$repository_root/plugins/flow/.mcp.json" >/dev/null
sh -n "$repository_root/plugins/flow/bin/flow-mcp-launcher"

if [ ! -x "$repository_root/plugins/flow/bin/flow-mcp-launcher" ]; then
  printf '%s\n' "Flow MCP launcher must be executable." >&2
  exit 1
fi

if command -v claude >/dev/null 2>&1; then
  claude plugin validate "$repository_root" --strict
else
  printf '%s\n' "Claude CLI not found; skipped Claude's schema validator."
fi
