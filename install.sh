#!/usr/bin/env bash
# Install session-refresh adapters for non-Claude harnesses. Idempotent.
# Claude Code users: install this repo as a plugin instead (see README).
#
# Usage:
#   ./install.sh codex                 # copy prompts to ~/.codex/prompts/
#   ./install.sh opencode [project]    # copy commands to <project>/.opencode/command/ (default: cwd)
#   ./install.sh agents                # print the AGENTS.md auto-restore snippet
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

case "${1:-}" in
  codex)
    dest="${HOME}/.codex/prompts"
    mkdir -p "$dest"
    cp "$here/adapters/codex/prompts/session-refresh.md" "$here/adapters/codex/prompts/session-resume.md" "$dest/"
    echo "Installed /session-refresh and /session-resume prompts to $dest"
    echo "For best-effort auto-restore, add the AGENTS.md snippet: ./install.sh agents"
    ;;
  opencode)
    project="${2:-$(pwd)}"
    dest="$project/.opencode/command"
    mkdir -p "$dest"
    cp "$here/adapters/opencode/command/session-refresh.md" "$here/adapters/opencode/command/session-resume.md" "$dest/"
    echo "Installed /session-refresh and /session-resume commands to $dest"
    ;;
  agents)
    cat "$here/adapters/codex/AGENTS-snippet.md"
    ;;
  *)
    echo "Usage: $0 {codex|opencode [project_dir]|agents}" >&2
    exit 1
    ;;
esac
