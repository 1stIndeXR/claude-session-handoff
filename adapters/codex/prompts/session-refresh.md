---
description: Refresh the session in place — write a handoff, then compact, then resume from it.
argument-hint: "[aggressive]"
---

Refresh this session in place so we can continue with a small context. Argument: $ARGUMENTS (contains "aggressive" → also write durable facts to long-term memory if available; otherwise only flag them).

Do the following, then stop:

1. **Structured sweep (no prose):** enumerate every file created/edited/read, every command run with outcome, every TODO/FIXME, every unanswered user question, every abandoned approach with the reason.

2. **Synthesize** the sweep into a handoff with these exact sections (write "None" if empty): 1. Where We Started & Decisions Logged; 2. Key Files & Documentation (paths + one-line why); 3. Running State & Verification (current state / verified working / failing); 4. Dead Ends; 5. Deferred Items & Open Questions; 6. Memory Candidates; 7. Pick Up From Here (concrete next step — file, function, question); 8. Refresh Continuation — note this is an in-session refresh, state the immediate next action verbatim, and instruct: "after compaction, resume this immediately, confirm in one line, do not wait for user confirmation."

3. **Persist** to `<project_root>/handoffs/` (fallback `~/Documents/claude-handoffs/`):
   - `YYYY-MM-DD_HHMM_<slug>.md` (UTC; slug = kebab-case of the original goal, max 5 words)
   - `latest.md` (overwrite — the restore entry point)
   - `.refresh-pending` containing only the current UTC ISO-8601 timestamp

4. **Output exactly:** the file path written; a one-sentence summary of where the session is; then: **"Now run `/compact`, then `/session-resume` — or just ask me to resume from the handoff."** Do not continue chatting.
