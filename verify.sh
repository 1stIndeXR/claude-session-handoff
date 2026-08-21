#!/usr/bin/env bash
set -euo pipefail

assert_contains() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  if ! grep -Eqi -- "$pattern" "$file"; then
    printf 'FAIL: %s (%s)\n' "$description" "$file" >&2
    return 1
  fi
}

selective_files=(
  core/session-refresh.md
  skills/session-refresh/SKILL.md
  commands/session-refresh.md
  adapters/codex/skills/session-refresh/SKILL.md
  adapters/codex/prompts/session-refresh.md
)

for file in "${selective_files[@]}"; do
  assert_contains "$file" 'selective' 'selective mode is documented'
done

assert_contains skills/session-handoff/template.md '^## [0-9]+\. Verbatim-Kept Threads$' 'template has a verbatim-kept section'
assert_contains skills/session-handoff/template.md '^## [0-9]+\. Summarized Threads$' 'template has a summarized section'
assert_contains skills/session-handoff/template.md '^## [0-9]+\. Omitted Material$' 'template has an omitted-material section'
assert_contains core/session-resume.md 'verbatim-kept threads' 'restore replays verbatim-kept threads'
assert_contains README.md '^## Handoff modes$' 'README documents handoff modes'
assert_contains README.md 'Selective' 'README documents selective mode'
assert_contains README.md 'Verbatim-Kept Threads' 'README file contract names the verbatim section'
assert_contains README.md 'Summarized Threads' 'README file contract names the summarized section'
assert_contains README.md 'Omitted Material' 'README file contract names the omitted section'

while IFS= read -r -d '' shell_file; do
  bash -n "$shell_file"
done < <(git ls-files -z '*.sh')

printf 'verify.sh: all checks passed\n'
