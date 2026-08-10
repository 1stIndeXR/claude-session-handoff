---
name: session-refresh
description: Refresh the current Codex session in place by writing a comprehensive handoff, compacting context, and resuming from it. Use when the user invokes $session-refresh, asks to refresh or renew the session, or wants to continue working with a smaller context.
---

# Session Refresh

Read and follow `references/session-refresh.md` exactly.

For the handoff step, use `references/session-handoff.md` and `references/template.md`.

When native compact hooks are enabled, use the core procedure's auto-restore closing line: ask the user to compact, then stop so the `SessionStart(compact)` hook can resume automatically. If hooks are unavailable, use the no-hook closing line and direct the user to `$session-resume`.
