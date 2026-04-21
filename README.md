# Session Handoff Skill

Manual checkpoint system for long Claude sessions. Generates a structured artifact so a fresh session can resume work without losing momentum, instead of relying on auto-compaction at 95% context.

## How it works

1. At any point (suggested cue: ~250K tokens consumed), invoke `/session-handoff`.
2. Claude does a structured sweep of the conversation, then writes a single artifact to `handoffs/latest.md` (and a timestamped copy alongside).
3. You `/clear` (Code) or open a new session (Cowork/Chat).
4. In the new session, invoke `/session-resume`. Claude reads `latest.md`, reads the key files it lists, and reports back in three lines where you left off.

Two modes:

- **Conservative** (default) — artifact only; durable facts are listed in section 6 for you to approve later.
- **Aggressive** (`/session-handoff aggressive`) — also writes durable facts directly to the long-term memory system, when one is available.

## Install

### Claude Code

```bash
mkdir -p ~/.claude/skills ~/.claude/commands
ln -s "$(pwd)/skills/session-handoff" ~/.claude/skills/session-handoff
ln -s "$(pwd)/commands/session-handoff.md" ~/.claude/commands/session-handoff.md
ln -s "$(pwd)/commands/session-resume.md"  ~/.claude/commands/session-resume.md
```

(Use `cp -r` instead of `ln -s` if you'd rather not symlink.)

### Cowork

Cowork picks up skills from its plugin directories. Either:

- Bundle the `skills/session-handoff/` folder into a plugin and install it, or
- Drop the folder into the user-skills location used by your Cowork install (commonly under `~/Library/Application Support/Claude/.../skills/`).

Slash commands aren't a first-class concept in Cowork today — invoke the skill by saying *"run session handoff"* or *"session handoff, aggressive"*. The skill description matches those phrasings.

### Claude in Chrome / Design plugins

Same as Cowork — install the skill folder under the plugin's skills directory. The skill detects whether a filesystem is reachable and falls back to a fenced-block output if not.

### Web/mobile chat

No install path. Paste the contents of `skills/session-handoff/SKILL.md` and `skills/session-handoff/template.md` into a Project's custom instructions. Claude will produce the artifact as a fenced markdown block for you to copy.

## File layout

```
.
├── skills/session-handoff/
│   ├── SKILL.md          ← main instructions (4-pass process, modes, env notes)
│   └── template.md       ← the artifact template
├── commands/
│   ├── session-handoff.md
│   └── session-resume.md
├── handoffs/             ← generated artifacts land here
│   └── latest.md         ← entry point for /session-resume (overwritten each handoff)
└── README.md
```

## Why a sweep pass before synthesis

A single LLM pass over 250K tokens drops things. The skill forces a structured enumeration first (every file, every command, every TODO, every dead end) before writing the polished artifact. The sweep is the safety net.

## Future enhancements

- **Token-threshold hook (Claude Code only):** a `PreToolUse` or session hook that checks accumulated token count and surfaces the handoff suggestion automatically. Not needed for v1 — the heuristic cues in the skill are sufficient.
- **Multi-handoff browser:** a small script to list `handoffs/*.md` with their goals and timestamps, for resuming an older session instead of the latest one.
- **Diff-mode resume:** for very long-running projects, `/session-resume` could compare `latest.md` against current repo state and flag drift before reporting back.
