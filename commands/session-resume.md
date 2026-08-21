---
description: Resume from the most recent session handoff artifact (hot continuation after /session-refresh, or cold resume).
---

Follow `core/session-resume.md` at the plugin root:

1. Locate `latest.md`: `<project_root>/handoffs/latest.md`, else `~/Documents/claude-handoffs/latest.md`. Neither → say no handoff found, ask where to look, stop.
2. Check `handoffs/.refresh-pending`: exists and less than 30 minutes old → **hot continuation**; otherwise → **cold resume** (delete stale marker).
3. Read the artifact in full, plus every file in section 2 ("Key Files & Documentation"). Replay any "Verbatim-Kept Threads" unchanged, preserving exact text, order, and speaker labels.
4. Hot: delete the marker, confirm in one line (`Refreshed — resuming: <next action>`), and resume the section 7 / "Refresh Continuation" next action immediately.
5. Cold: report exactly three lines — where the previous session left off, the immediate next task (section 7), active blockers (section 3) — then wait for the user. Do not begin work yet.
