---
description: Resume from the most recent session handoff artifact.
---

Resume from the most recent session handoff:

1. Locate `latest.md`:
   - First check `<project_root>/handoffs/latest.md` if you're in a project folder.
   - Otherwise check `~/Documents/claude-handoffs/latest.md`.
   - If neither exists, tell the user no handoff was found and ask where to look.
2. Read the artifact in full.
3. Read every file listed in section 2 ("Key Files & Documentation").
4. Report back in exactly three lines:
   - Line 1: where the previous session left off
   - Line 2: the immediate next task (from section 7)
   - Line 3: any active blockers (from section 3 "Failing or errors")
5. Wait for the user to confirm or redirect. Do not begin work yet.
