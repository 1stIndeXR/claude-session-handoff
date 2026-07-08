# Session Resume — core procedure (harness-agnostic)

Restore working state from the most recent session handoff. Used both for cold resumes (new session, days later) and hot continuations (right after a `/session-refresh` + compact cycle).

## Steps

1. **Locate the handoff.** Check in order:
   - `<project_root>/handoffs/latest.md`
   - `~/Documents/claude-handoffs/latest.md`
   - Neither exists → tell the user no handoff was found, ask where to look, stop.

2. **Check the refresh marker.** Look for `handoffs/.refresh-pending` next to `latest.md`. It contains a UTC ISO-8601 timestamp.
   - Marker exists and timestamp is **less than 30 minutes old** → **hot continuation**.
   - Marker missing, unreadable, or older than 30 minutes → **cold resume**. Delete a stale marker if present.

3. **Read** `latest.md` in full, then read every file listed in section 2 ("Key Files & Documentation").

4. **Hot continuation:**
   - Delete `.refresh-pending`.
   - Confirm to the user in one line: `Refreshed — resuming: <immediate next action from section 8>`.
   - Resume work on the section 7 / section 8 next action immediately. Do not wait for confirmation.

5. **Cold resume:**
   - Report back in exactly three lines:
     - Line 1: where the previous session left off
     - Line 2: the immediate next task (from section 7)
     - Line 3: any active blockers (from section 3 "Failing or errors")
   - Wait for the user to confirm or redirect. Do not begin work yet.
