# Generic adapter — any harness (ZCode, Cursor, Aider, plain chat, ...)

The whole system is just **files + markdown instructions**. No hooks required.

## The file contract

- `handoffs/latest.md` — always-current handoff (sections 1–7 plus "Refresh Continuation"; selective mode also includes "Verbatim-Kept Threads", "Summarized Threads", and "Omitted Material")
- `handoffs/YYYY-MM-DD_HHMM_<slug>.md` — history
- `handoffs/.refresh-pending` — marker (UTC ISO-8601 timestamp inside) meaning "refresh in flight; restore me after compaction". Stale after 30 minutes.

## Setup

1. **Refresh:** put the contents of [`core/session-refresh.md`](../../core/session-refresh.md) wherever your harness accepts custom prompts, commands, or rules (a saved prompt, a rules file, a snippet you paste). Invoke it when context gets heavy.
2. **Compact:** use your harness's compact/summarize/clear command.
3. **Restore:** put [`core/session-resume.md`](../../core/session-resume.md) the same way, or simply tell the agent: *"Read `handoffs/latest.md`, replay any verbatim-kept threads unchanged, and resume from Refresh Continuation."*

If your harness has a persistent rules file that survives compaction (like Codex's `AGENTS.md` or a `.cursorrules`), add the auto-restore rule from [`adapters/codex/AGENTS-snippet.md`](../codex/AGENTS-snippet.md) to get best-effort automatic restore.
