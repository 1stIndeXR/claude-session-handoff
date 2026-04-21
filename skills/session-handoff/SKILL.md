---
name: session-handoff
description: Capture the current working session into a structured handoff document so a fresh session can resume without context loss. Trigger when the user asks for a session handoff, says they want to wrap up the session, mentions context getting heavy, or invokes /session-handoff. Also trigger proactively when the conversation has accumulated significant context (many large file reads, many tool calls, long history) and the user might benefit from starting fresh.
---

# Session Handoff

Generate a state-recovery document so a fresh session can resume this work without re-reading the entire conversation. The artifact is the contract between this session and the next one.

## When to trigger

- **Explicit:** user says "handoff", "wrap up the session", "save state", or invokes `/session-handoff`.
- **Proactive (~250K token heuristic):** you cannot count your own tokens reliably. Use proxies — if any of these have happened, surface a one-line suggestion (do NOT auto-run):
  - >5 large file reads
  - >20 tool calls in this session
  - the conversation has covered 3+ distinct sub-tasks
  - the user has said "remind me what we were doing" or similar

  Suggestion phrasing: *"Context is getting heavy — worth running `/session-handoff` before continuing?"*

## Modes

Default mode is **conservative**. Switch to **aggressive** if the user passes `aggressive` (e.g. `/session-handoff aggressive`, or just says "aggressive handoff").

- **Conservative:** generate the artifact only. Identify durable facts that *could* go to long-term memory and list them in section 6 of the artifact for the user to approve later.
- **Aggressive:** also write those durable facts to the memory system directly (if one is available), then mark each saved item `[SAVED]` in section 6.

## Process

### Pass 1 — Structured sweep (no prose)

Enumerate, as raw bullet lists. Terse, one line per item:

- Every file created, edited, or read (with path).
- Every command/tool call run, with outcome (success/failure/skipped).
- Every TODO, FIXME, or "we'll come back to" mentioned by anyone.
- Every question the user asked that wasn't fully answered.
- Every approach attempted and abandoned, with the reason.

This pass exists so nothing slips through synthesis. Don't polish it — it's scaffolding.

### Pass 2 — Synthesis

Fold the sweep into the artifact template at `template.md` (sibling to this file). Use the exact section structure. Do not invent new sections or skip ones — write "None" if a section is empty.

### Pass 3 — Persist

If filesystem is available:

1. Determine `<root>`:
   - If working in a project folder → `<project_root>/handoffs/`
   - Otherwise → `~/Documents/claude-handoffs/`
2. Build slug from the artifact's "Original Goal": kebab-case, max 5 words.
3. Write artifact to `<root>/YYYY-MM-DD_HHMM_<slug>.md` (UTC).
4. Overwrite `<root>/latest.md` with the same content. This is the resume entry point.

If no filesystem (chat-only environments): output the entire artifact as a single fenced markdown block. Skip steps 1–4. Tell the user to save it manually.

### Pass 4 — Confirm and stop

Output exactly:

- File path written (or "see fenced block above" in chat-only).
- One-sentence summary of where the session ended up.
- Conservative mode: `N memory candidates flagged in section 6`.
- Aggressive mode: `N memories written, M flagged for review`.

Then stop. No further chat — the user will `/clear` or open a new session.

## Memory integration

Only write to long-term memory in **aggressive** mode, and only if a memory system is documented in the system prompt (auto-memory section will name a directory). Follow the existing memory format: separate file per entry, frontmatter with `name`/`description`/`type`, and a one-line index entry in `MEMORY.md`.

Never duplicate handoff content into memory. The split is:

- **Handoff** = in-flight task state (this bug, that next step, the file we just touched).
- **Memory** = durable facts (user preferences, project context, recurring workflows).

## Cross-environment notes

- **Claude Code / Cowork:** full filesystem flow, slash commands available.
- **Claude in Chrome / Design plugins:** may have filesystem via the workspace folder; same flow applies. If unsure, try the write and fall back to fenced output on failure.
- **Web/mobile chat:** no filesystem. Fenced-block output only.
- **Token threshold:** the 250K proactive cue is heuristic — see "When to trigger" above. Do not claim to know your context size.
