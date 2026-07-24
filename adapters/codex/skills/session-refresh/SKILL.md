---
name: session-refresh
description: Refresh the current Codex session in place by writing a comprehensive handoff, compacting context, and resuming from it. Use when the user invokes $session-refresh, asks to refresh or renew the session, or wants to continue working with a smaller context.
---

# Session Refresh

Read and follow `references/session-refresh.md` exactly.

For the handoff step, use `references/session-handoff.md` and `references/template.md`.

Codex does not provide the Claude Code post-compaction restore hook. Use the core procedure's no-hook closing line, replacing slash-command references with the Codex skill invocation `$session-resume`.
