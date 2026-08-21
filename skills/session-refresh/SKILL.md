---
name: session-refresh
description: Refresh the current session in place — write a comprehensive handoff, have the user compact, then auto-restore state so work continues in the same session with a small context. Trigger when the user invokes /session-refresh or $session-refresh, says "refresh the session", "renew the session", or wants to keep working but context is getting heavy (30%+ used). Distinct from session-handoff, which ends a session.
---

# Session Refresh

Follow the core procedure in `core/session-refresh.md` (sibling of `skills/` at the plugin root) exactly. Plugin behavior:

- **Modes:** conservative memory handling and comprehensive retention by default. `aggressive` passes through to the handoff step; `selective` triggers the three-bucket retention pass. The arguments may be combined.
- **Closing line (step 5):** this plugin ships a `SessionStart(compact)` hook that auto-injects `handoffs/latest.md`, so use the auto-restore variant: *"Now compact the conversation — state will be restored automatically afterward."*
- **Marker:** write `handoffs/.refresh-pending` (step 4) — both the PreCompact guard and the restore hook key off it.
- After the closing line, **stop**. The restore hook takes over after the user compacts; you will receive the handoff as injected context, replay any verbatim-kept threads unchanged, and resume the "Refresh Continuation" immediate next action with a one-line confirmation.
