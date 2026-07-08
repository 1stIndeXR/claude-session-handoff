#!/usr/bin/env bash
# PreCompact(manual) hook: warn (never block) if the user compacts without a fresh handoff.
set -euo pipefail

MARKER_MAX_AGE_SECS=1800  # 30 min

root=""
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "${CLAUDE_PROJECT_DIR}/handoffs" ]; then
  root="${CLAUDE_PROJECT_DIR}/handoffs"
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

echo "session-handoff: no fresh handoff found — run /session-refresh before compacting to preserve full session state. Proceeding with plain compaction." >&2
exit 0
