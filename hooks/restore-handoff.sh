#!/usr/bin/env bash
# SessionStart(compact) hook: inject handoffs/latest.md back into context after compaction.
# Fresh .refresh-pending marker => hot continuation (resume immediately, delete marker).
# Otherwise => inject with a staleness note.
set -euo pipefail

MARKER_MAX_AGE_SECS=1800   # 30 min
SIZE_LIMIT_BYTES=51200     # 50 KB

hook_input="$(cat)"
project_dir="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$project_dir" ] && [ -n "$hook_input" ]; then
  project_dir="$(python3 -c '
import json
import sys

print(json.load(sys.stdin).get("cwd", ""))
' <<< "$hook_input" 2>/dev/null || true)"
fi

root=""
if [ -n "$project_dir" ] && [ -f "${project_dir}/handoffs/latest.md" ]; then
  root="${project_dir}/handoffs"
elif [ -f "${HOME}/Documents/claude-handoffs/latest.md" ]; then
  root="${HOME}/Documents/claude-handoffs"
else
  exit 0  # no handoff anywhere — nothing to inject
fi

latest="${root}/latest.md"
marker="${root}/.refresh-pending"

# Marker freshness (by file mtime — portable, no date parsing)
hot=false
if [ -f "$marker" ]; then
  now=$(date +%s)
  if stat -f %m "$marker" >/dev/null 2>&1; then
    mtime=$(stat -f %m "$marker")            # BSD/macOS
  else
    mtime=$(stat -c %Y "$marker")            # GNU/Linux
  fi
  age=$(( now - mtime ))
  if [ "$age" -le "$MARKER_MAX_AGE_SECS" ]; then
    hot=true
  fi
  rm -f "$marker"  # consumed either way; stale markers must not linger
fi

# Content, truncated to key sections if oversized
size=$(wc -c < "$latest" | tr -d ' ')
if [ "$size" -gt "$SIZE_LIMIT_BYTES" ]; then
  content=$(awk '
    /^## /{keep=0}
    /^## 1\./||/^## 2\./||/^## 3\./||/^## 7\./||/^## 8\./{keep=1}
    NR<=8{print; next}
    keep{print}
  ' "$latest")
  content="${content}

[Handoff truncated by restore hook: sections 4-6 omitted, full artifact at ${latest}]"
else
  content=$(cat "$latest")
fi

if [ "$hot" = true ]; then
  header="SESSION REFRESH RESTORE — a /session-refresh was just completed and the conversation was compacted. The handoff below is your authoritative state. Resume the 'Immediate next action' from section 8 (or section 7) NOW: confirm the restore to the user in one line, then continue working without waiting for confirmation."
else
  header="SESSION HANDOFF (stale — written before this compaction cycle, not part of a refresh; it may not reflect the latest work). Use it as background state only."
fi

# Emit JSON via python for safe string escaping
export RH_HEADER="$header" RH_CONTENT="$content"
python3 - <<'PY'
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ["RH_HEADER"] + "\n\n" + os.environ["RH_CONTENT"],
    }
}))
PY
