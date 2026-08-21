# Session Handoff + Session Refresh

Checkpoint system for long agent sessions, for Claude Code and other harnesses (Codex, OpenCode, anything with custom prompts).

Two workflows:

- **`/session-handoff`** — end a session cleanly. Write a structured artifact so a *fresh* session can resume without lost momentum.
- **`/session-refresh`** — continue the *same* session with a small context. One flow: write a comprehensive handoff → compact → state is restored into the compacted session automatically when native hooks are installed, or via `/session-resume` as a fallback. Use it around 30%+ context to avoid exponential context growth without losing state to lossy compaction.

## Session refresh flow

```
you: /session-refresh
       │  writes handoffs/latest.md (+ timestamped copy)
       │  writes handoffs/.refresh-pending marker
you: compact
       │  PreCompact guard: warns if no fresh handoff
       │  SessionStart(compact) hook: injects latest.md back into context
agent: "Refreshed — resuming: <next action>"   ← continues working immediately
```

On harnesses without hooks, the last step is `/session-resume` (or "resume from handoff") — the fresh `.refresh-pending` marker tells it to hot-continue instead of cold-resuming.

## Harness support matrix

| Harness | Refresh command | Restore after compact | Install |
|---|---|---|---|
| Claude Code | `/session-refresh` | **automatic** (SessionStart hook) | install as plugin |
| Codex | `$session-refresh` skill | **automatic** with plugin hooks; `$session-resume` fallback | install as plugin, or `./install.sh codex` |
| OpenCode | `/session-refresh` command | `/session-resume` | `./install.sh opencode [project]` |
| ZCode / anything else | paste `core/session-refresh.md` | "read handoffs/latest.md and resume" | see `adapters/generic/README.md` |

The portable part is just **files + markdown instructions** — `core/` is the single source of truth; adapters are thin wrappers.

## File contract (harness-independent)

- `handoffs/latest.md` — always-current handoff and restore entry point. Sections 1–7 hold synthesized state. A normal refresh adds section 8, **Refresh Continuation**. Selective mode first adds sections 8–10, **Verbatim-Kept Threads**, **Summarized Threads**, and **Omitted Material**, then adds **Refresh Continuation** as section 11.
- `handoffs/YYYY-MM-DD_HHMM_<slug>.md` — history
- `handoffs/.refresh-pending` — marker (UTC timestamp) meaning "refresh in flight, restore me after compaction"; stale after 30 minutes

## Handoff modes

- **Conservative** (default) — artifact only; durable facts listed in section 6 for later approval.
- **Aggressive** (`/session-refresh aggressive` or `/session-handoff aggressive`) — also writes durable facts to long-term memory when available.
- **Selective retention** (`/session-refresh selective` or `$session-refresh selective`) — classifies every conversation thread into three buckets before compaction:
  - **Verbatim-Kept Threads** — active work, unresolved constraints, and current task state copied unchanged and replayed unchanged on restore.
  - **Summarized Threads** — completed work whose outcome matters but whose process can be compressed.
  - **Omitted Material** — confirmed dead ends, redundant verbosity, and unrelated side-tracking; the handoff keeps one-line titles only as an audit trail.

`selective` controls retention and `aggressive` controls memory writes, so `/session-refresh selective aggressive` combines them.

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

Install this repository as a Codex plugin to get all three skills plus native compact hooks. The `PreCompact` hook checks for a fresh handoff, and the `SessionStart(compact)` hook restores it automatically. Review and trust the hooks through `/hooks` when Codex prompts you.

For a standalone installation without hooks:

```bash
./install.sh codex     # standalone skills → ~/.agents/skills/; compatibility prompts → ~/.codex/prompts/
./install.sh agents    # optional AGENTS.md fallback for auto-restore
```

Invoke the native skills as `$session-handoff`, `$session-refresh`, and `$session-resume`.
They are installed as standalone user skills so Codex does not add a plugin namespace prefix.
The compatibility prompts remain available as `/prompts:session-refresh` and
`/prompts:session-resume`.
On a cold resume, Codex renames the active task from the handoff's original goal when
task-title control is available; hot continuations keep their current title.

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
├── .codex-plugin/plugin.json        ← Codex plugin manifest
├── core/                            ← harness-agnostic procedures (source of truth)
│   ├── session-refresh.md
│   └── session-resume.md
├── skills/
│   ├── session-handoff/             ← SKILL.md + template.md (4-pass process)
│   ├── session-refresh/             ← thin wrapper over core/
│   └── session-resume/              ← thin wrapper over core/
├── commands/                        ← Claude Code slash commands
│   ├── session-handoff.md
│   ├── session-resume.md
│   └── session-refresh.md
├── hooks/                           ← Claude Code and Codex automation
│   ├── hooks.json                   ← SessionStart(compact) + PreCompact(manual|auto)
│   ├── restore-handoff.sh           ← injects latest.md after compaction
│   └── precompact-guard.sh          ← warns if compacting without a fresh handoff
├── adapters/
│   ├── codex/                       ← standalone skills + compatibility prompts + AGENTS.md snippet
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
