#!/usr/bin/env bash
# PreCompact(manual|auto) hook: warn (never block) if compaction starts without a fresh handoff.
set -euo pipefail

MARKER_MAX_AGE_SECS=1800  # 30 min

hook_input="$(cat)"
project_dir="${CLAUDE_PROJECT_DIR:-}"
codex_hook=false
if [ -z "$project_dir" ] && [ -n "$hook_input" ]; then
  project_dir="$(python3 -c '
import json
import sys

print(json.load(sys.stdin).get("cwd", ""))
' <<< "$hook_input" 2>/dev/null || true)"
  if [ -n "$project_dir" ]; then
    codex_hook=true
  fi
fi

root=""
if [ -n "$project_dir" ] && [ -d "${project_dir}/handoffs" ]; then
  root="${project_dir}/handoffs"
elif [ -d "${HOME}/Documents/claude-handoffs" ]; then
  root="${HOME}/Documents/claude-handoffs"
fi

marker="${root}/.refresh-pending"
if [ -n "$root" ] && [ -f "$marker" ]; then
  now=$(date +%s)
  if stat -f %m "$marker" >/dev/null 2>&1; then
    mtime=$(stat -f %m "$marker")
  else
    mtime=$(stat -c %Y "$marker")
  fi
  if [ $(( now - mtime )) -le "$MARKER_MAX_AGE_SECS" ]; then
    exit 0  # fresh handoff exists — compact away
  fi
fi

if [ "$codex_hook" = true ]; then
  export PC_WARNING='session-handoff: no fresh handoff found — run $session-refresh before compacting to preserve full session state. Proceeding with plain compaction.'
  python3 - <<'PY'
import json
import os

print(json.dumps({"systemMessage": os.environ["PC_WARNING"]}))
PY
else
  echo "session-handoff: no fresh handoff found — run /session-refresh before compacting to preserve full session state. Proceeding with plain compaction." >&2
fi
exit 0
