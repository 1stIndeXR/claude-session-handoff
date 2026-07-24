#!/usr/bin/env bash
# Install session-refresh adapters for non-Claude harnesses. Idempotent.
# Claude Code users: install this repo as a plugin instead (see README).
#
# Usage:
#   ./install.sh codex                 # install Codex skills and compatibility prompts
#   ./install.sh opencode [project]    # copy commands to <project>/.opencode/command/ (default: cwd)
#   ./install.sh agents                # print the AGENTS.md auto-restore snippet
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

install_codex_skill() {
  skill_name="$1"
  skill_source="$2"
  skill_target="$skill_dest/$skill_name"
  managed_marker="$skill_target/.session-handoff-skill-source"

  if [[ -e "$skill_target" || -L "$skill_target" ]]; then
    if [[ ! -f "$managed_marker" ]]; then
      echo "Refusing to replace unmanaged skill path: $skill_target" >&2
      exit 1
    fi
  else
    mkdir -p "$skill_target"
  fi

  cp -RL "$skill_source/." "$skill_target/"
  printf '%s\n' "$skill_source" > "$managed_marker"
}

case "${1:-}" in
  codex)
    codex_root="${CODEX_HOME:-${HOME}/.codex}"
    prompt_dest="$codex_root/prompts"
    legacy_skill_dest="$codex_root/skills"
    skill_dest="${HOME}/.agents/skills"
    mkdir -p "$prompt_dest" "$skill_dest"

    skill_names=(session-handoff session-refresh session-resume)
    skill_sources=(
      "$here/skills/session-handoff"
      "$here/adapters/codex/skills/session-refresh"
      "$here/adapters/codex/skills/session-resume"
    )

    for index in "${!skill_names[@]}"; do
      skill_name="${skill_names[$index]}"
      skill_source="${skill_sources[$index]}"
      install_codex_skill "$skill_name" "$skill_source"

      legacy_link="$legacy_skill_dest/$skill_name"
      if [[ -L "$legacy_link" && "$(readlink "$legacy_link")" == "$skill_source" ]]; then
        unlink "$legacy_link"
      fi
    done

    cp "$here/adapters/codex/prompts/session-refresh.md" "$here/adapters/codex/prompts/session-resume.md" "$prompt_dest/"

    echo "Installed \$session-handoff, \$session-refresh, and \$session-resume standalone skills to $skill_dest"
    echo "Installed compatibility prompts to $prompt_dest"
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
