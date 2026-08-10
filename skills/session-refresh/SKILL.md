---
name: session-refresh
description: Refresh the current session in place — write a comprehensive handoff, have the user compact, then auto-restore state so work continues in the same session with a small context. Trigger when the user invokes /session-refresh or $session-refresh, says "refresh the session", "renew the session", or wants to keep working but context is getting heavy (30%+ used). Distinct from session-handoff, which ends a session.
---

# Session Refresh

Follow the core procedure in `core/session-refresh.md` (sibling of `skills/` at the plugin root) exactly. Plugin behavior:

- **Mode:** conservative by default; `aggressive` argument passes through to the handoff step.
- **Closing line (step 4):** this plugin ships a `SessionStart(compact)` hook that auto-injects `handoffs/latest.md`, so use the auto-restore variant: *"Now compact the conversation — state will be restored automatically afterward."*
- **Marker:** write `handoffs/.refresh-pending` (step 3) — both the PreCompact guard and the restore hook key off it.
- After the closing line, **stop**. The restore hook takes over after the user compacts; you will receive the handoff as injected context and must resume section 8's immediate next action with a one-line confirmation.
