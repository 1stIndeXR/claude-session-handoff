# Session Refresh — core procedure (harness-agnostic)

Purpose: continue working in the *same* session with a small context. Three steps: write a comprehensive handoff, let the user compact the conversation, restore state from the handoff afterwards. This file is the single source of truth; harness adapters (Claude Code skill, Codex prompt, OpenCode command) wrap it without changing the procedure.

Modes:

- Memory handling defaults to **conservative**. If the argument contains `aggressive`, pass that through to the handoff step (memory candidates are written to long-term memory, not just flagged).
- Retention defaults to a comprehensive synthesized handoff. If the argument contains `selective`, preserve active threads verbatim while compressing finished threads and omitting confirmed noise. `selective` and `aggressive` are independent and may be combined.

## Steps

### 1. Generate the handoff

Follow the session-handoff procedure, Passes 1–3 (see `skills/session-handoff/SKILL.md` and its `template.md` in this repository — or, if installed standalone, apply the same structure):

- **Pass 1 — structured sweep:** enumerate every file touched, every command run with outcome, every TODO, every unanswered question, every abandoned approach. Raw bullets, no prose.
- **Pass 2 — synthesis:** fold the sweep into the handoff template (sections 1–7). Write "None" for empty sections; never skip sections.
  - In `selective` mode, also inventory each conversation thread and classify it into exactly one bucket. When uncertain, keep it verbatim.
    - **Keep verbatim:** active work threads, unresolved constraints, and current task state. Copy the complete thread exactly, in original order, with speaker labels and any tool result needed by the active thread. Do not paraphrase, reformat, correct, or truncate it.
    - **Summarize:** completed threads whose outcome matters but whose process does not. Record the outcome, durable decisions, and resulting constraints concisely.
    - **Omit:** confirmed dead ends, redundant verbosity, and unrelated side-tracking. Record only a one-line title for each omitted thread; include no content or rationale.
- **Pass 3 — persist:** write to `<root>/handoffs/` where `<root>` is the project folder (fallback `~/Documents/claude-handoffs/`):
  - `handoffs/YYYY-MM-DD_HHMM_<slug>.md` (UTC, slug from original goal, kebab-case, max 5 words)
  - `handoffs/latest.md` (overwrite; this is the restore entry point)

### 2. Append selective retention sections when requested

In `selective` mode, append sections 8–10 from the handoff template to both files. Every classified thread must appear in exactly one bucket. Preserve the text in section 8 byte-for-byte from the conversation; section 10 is an audit trail of one-line titles only.

In the default retention mode, do not append sections 8–10.

### 3. Append the "Refresh continuation" section

Add to the *end* of the artifact (both files):

```markdown
## {{8 in default mode | 11 in selective mode}}. Refresh Continuation

This handoff was written for an in-session refresh, not a session end.
After compaction, resume section 7 immediately — do not wait for user confirmation.
Confirm the restore to the user in one line, then continue working.

**Immediate next action (verbatim):** <the exact next step you were about to take>
```

### 4. Write the refresh marker

Write the current UTC timestamp (ISO 8601, e.g. `2026-07-08T14:30:00Z`) as the sole content of:

```
<root>/handoffs/.refresh-pending
```

This marker tells the restore mechanism (hook, AGENTS.md rule, or resume command) that a refresh is in flight. A marker older than 30 minutes is treated as stale.

### 5. Tell the user how to finish — then stop

Output exactly three things and nothing more:

1. The handoff file path written.
2. One-sentence summary of where the session is.
3. The harness-appropriate closing line:
   - Harness with a post-compact auto-restore hook installed (Claude Code or Codex with this plugin): **"Now run `/compact` — state will be restored automatically after compaction."**
   - Harness without auto-restore (standalone Codex, OpenCode, others): **"Now run `/compact` (or clear the context), then run `/session-resume` — or just ask me to resume from the handoff."**

Do not continue chatting. The refresh completes when the user compacts.

## Restore behavior (what happens after compaction)

Defined in `core/session-resume.md`. Summary: if `handoffs/.refresh-pending` exists and is fresh, this is a *hot* continuation — read `latest.md`, replay any "Verbatim-Kept Threads" unchanged, delete the marker, and resume the "Refresh Continuation" action immediately with a one-line confirmation. Otherwise it is a *cold* resume — report state and wait for the user.
