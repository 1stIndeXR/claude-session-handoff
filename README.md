# Session Handoff + Session Refresh

Checkpoint system for long agent sessions, for Claude Code and other harnesses (Codex, OpenCode, anything with custom prompts).

Two workflows:

- **`/session-handoff`** — end a session cleanly. Write a structured artifact so a *fresh* session can resume without lost momentum.
- **`/session-refresh`** — continue the *same* session with a small context. One flow: write a comprehensive handoff → you run `/compact` → state is restored into the compacted session automatically (Claude Code) or via `/session-resume` (other harnesses). Use it around 30%+ context to avoid exponential context growth without losing state to lossy compaction.

## Session refresh flow

```
you: /session-refresh
       │  writes handoffs/latest.md (+ timestamped copy)
       │  writes handoffs/.refresh-pending marker
you: /compact
       │  [Claude Code] PreCompact guard: warns if no fresh handoff
       │  [Claude Code] SessionStart(compact) hook: injects latest.md back into context
agent: "Refreshed — resuming: <next action>"   ← continues working immediately
```

On harnesses without hooks, the last step is `/session-resume` (or "resume from handoff") — the fresh `.refresh-pending` marker tells it to hot-continue instead of cold-resuming.

## Harness support matrix

| Harness | Refresh command | Restore after compact | Install |
|---|---|---|---|
| Claude Code | `/session-refresh` | **automatic** (SessionStart hook) | install as plugin |
| Codex | `/session-refresh` prompt | best-effort auto (AGENTS.md rule) or `/session-resume` | `./install.sh codex` + `./install.sh agents` |
| OpenCode | `/session-refresh` command | `/session-resume` | `./install.sh opencode [project]` |
| ZCode / anything else | paste `core/session-refresh.md` | "read handoffs/latest.md and resume" | see `adapters/generic/README.md` |

The portable part is just **files + markdown instructions** — `core/` is the single source of truth; adapters are thin wrappers.

## File contract (harness-independent)

- `handoffs/latest.md` — always-current handoff, sections 1–8; the restore entry point
- `handoffs/YYYY-MM-DD_HHMM_<slug>.md` — history
- `handoffs/.refresh-pending` — marker (UTC timestamp) meaning "refresh in flight, restore me after compaction"; stale after 30 minutes

## Handoff modes

- **Conservative** (default) — artifact only; durable facts listed in section 6 for later approval.
- **Aggressive** (`/session-refresh aggressive` or `/session-handoff aggressive`) — also writes durable facts to long-term memory when available.

## Install

### Claude Code (plugin — recommended)

Install the repo as a plugin (marketplace, or add locally). You get `/session-handoff`, `/session-resume`, `/session-refresh`, the skills, and both hooks (PreCompact guard + post-compact auto-restore).

Or symlink pieces manually (no hooks that way):

```bash
mkdir -p ~/.claude/skills ~/.claude/commands
ln -s "$(pwd)/skills/session-handoff"  ~/.claude/skills/session-handoff
ln -s "$(pwd)/skills/session-refresh"  ~/.claude/skills/session-refresh
ln -s "$(pwd)/commands/session-handoff.md" ~/.claude/commands/session-handoff.md
ln -s "$(pwd)/commands/session-resume.md"  ~/.claude/commands/session-resume.md
ln -s "$(pwd)/commands/session-refresh.md" ~/.claude/commands/session-refresh.md
```

### Codex

```bash
./install.sh codex     # /session-refresh + /session-resume prompts → ~/.codex/prompts/
./install.sh agents    # prints AGENTS.md snippet for best-effort auto-restore
```

### OpenCode

```bash
./install.sh opencode /path/to/project   # commands → <project>/.opencode/command/
```

### Cowork / Claude in Chrome / Design plugins

Install the skill folders under the plugin's skills directory; invoke by phrase ("run session refresh"). Filesystem fallback to fenced-block output applies.

### Web/mobile chat

Paste `skills/session-handoff/SKILL.md` + `template.md` into a Project's custom instructions; the artifact is produced as a fenced block to copy.

## File layout

```
.
├── .claude-plugin/plugin.json       ← Claude Code plugin manifest
├── core/                            ← harness-agnostic procedures (source of truth)
│   ├── session-refresh.md
│   └── session-resume.md
├── skills/
│   ├── session-handoff/             ← SKILL.md + template.md (4-pass process)
│   └── session-refresh/             ← thin wrapper over core/
├── commands/                        ← Claude Code slash commands
│   ├── session-handoff.md
│   ├── session-resume.md
│   └── session-refresh.md
├── hooks/                           ← Claude Code automation
│   ├── hooks.json                   ← SessionStart(compact) + PreCompact(manual)
│   ├── restore-handoff.sh           ← injects latest.md after compaction
│   └── precompact-guard.sh          ← warns if compacting without a fresh handoff
├── adapters/
│   ├── codex/                       ← prompts + AGENTS.md snippet
│   ├── opencode/                    ← custom commands
│   └── generic/                     ← any other harness
├── install.sh                       ← adapter installer (codex | opencode | agents)
├── handoffs/                        ← generated artifacts land here
└── README.md
```

## Why a sweep pass before synthesis

A single LLM pass over 250K tokens drops things. The skill forces a structured enumeration first (every file, every command, every TODO, every dead end) before writing the polished artifact. The sweep is the safety net.

## Future enhancements

- **OpenCode plugin auto-restore:** a TS plugin hooking OpenCode's session events to inject `latest.md` post-compact, matching the Claude Code experience.
- **Token-threshold suggestion hook:** surface the refresh suggestion automatically near a context threshold.
- **Multi-handoff browser:** list `handoffs/*.md` with goals/timestamps to resume an older checkpoint.
- **Diff-mode resume:** compare `latest.md` against current repo state and flag drift before reporting back.
