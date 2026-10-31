#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Git Bash may not inherit the Node runtime available inside Codex.
windows_home="$(cygpath -u "${USERPROFILE:-$HOME}")"
if ! command -v node >/dev/null 2>&1; then
  for node_dir in "/c/Program Files/nodejs" "$windows_home/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin" "$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin"; do
    if [[ -f "$node_dir/node.exe" ]]; then
      export PATH="$node_dir:$PATH"
      break
    fi
  done
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js was not found. Install Node.js LTS, reopen Git Bash, and retry."
  exit 1
fi

echo "Using Node $(node --version)"
preview_port=55371
echo "Preview URL: http://localhost:$preview_port/"
if node -e 'const http = require("node:http"); const req = http.get("http://127.0.0.1:55371/", res => { res.resume(); process.exit(res.statusCode === 200 ? 0 : 1); }); req.on("error", () => process.exit(1)); req.setTimeout(2000, () => { req.destroy(); process.exit(1); });'; then
  echo "Preview is already running. Open http://localhost:55371/"
  exit 0
fi
exec hugo server --disableFastRender --bind 127.0.0.1 --port "$preview_port" "$@"
