---
description: Refresh the session in place — write a handoff, then compact, then resume from it.
---

Refresh this session in place so we can continue with a small context. Arguments: $ARGUMENTS ("aggressive" → also write durable facts to long-term memory if available; otherwise only flag them).

Do the following, then stop:

1. **Structured sweep (no prose):** enumerate every file created/edited/read, every command run with outcome, every TODO/FIXME, every unanswered user question, every abandoned approach with the reason.

2. **Synthesize** into a handoff with these exact sections (write "None" if empty): 1. Where We Started & Decisions Logged; 2. Key Files & Documentation; 3. Running State & Verification; 4. Dead Ends; 5. Deferred Items & Open Questions; 6. Memory Candidates; 7. Pick Up From Here; 8. Refresh Continuation — immediate next action verbatim, plus: "after compaction, resume this immediately, confirm in one line, do not wait for confirmation."

3. **Persist** to `<project_root>/handoffs/` (fallback `~/Documents/claude-handoffs/`): `YYYY-MM-DD_HHMM_<slug>.md` (UTC), `latest.md` (overwrite), and `.refresh-pending` containing only the current UTC ISO-8601 timestamp.

4. **Output exactly:** the file path; a one-sentence summary of where the session is; then: **"Now run `/compact`, then `/session-resume` — or just ask me to resume from the handoff."** Do not continue chatting.
