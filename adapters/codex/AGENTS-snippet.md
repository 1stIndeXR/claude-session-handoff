# AGENTS.md snippet — paste into your project's AGENTS.md

Gives Codex best-effort auto-restore after compaction (AGENTS.md survives compaction; the rule re-triggers in the fresh context).

```markdown
## Session refresh restore

At the start of a session or right after the context has been compacted, check for
`handoffs/.refresh-pending` in the project root. If it exists and its timestamp is
less than 30 minutes old: read `handoffs/latest.md` in full, delete the marker,
confirm the restore to the user in one line, and immediately resume the
"Immediate next action" from section 8 (or section 7) of the handoff without
waiting for confirmation. If the marker is stale or absent, do nothing.
```
