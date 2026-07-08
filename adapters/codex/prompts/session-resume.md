---
description: Resume from the most recent session handoff (hot continuation after /session-refresh, or cold resume).
---

Resume from the most recent session handoff:

1. Locate `latest.md`: `<project_root>/handoffs/latest.md`, else `~/Documents/claude-handoffs/latest.md`. Neither → say no handoff found, ask where to look, stop.
2. Check `handoffs/.refresh-pending`: exists and less than 30 minutes old (by its timestamp content or mtime) → **hot continuation**; otherwise → **cold resume** (delete a stale marker).
3. Read `latest.md` in full, plus every file listed in section 2 ("Key Files & Documentation").
4. **Hot:** delete the marker, confirm in one line (`Refreshed — resuming: <immediate next action from section 8>`), then resume that action immediately without waiting.
5. **Cold:** report exactly three lines — where the previous session left off; the immediate next task (section 7); active blockers (section 3) — then wait for the user. Do not begin work yet.
