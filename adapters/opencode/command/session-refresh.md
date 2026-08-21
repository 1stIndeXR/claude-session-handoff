---
description: Refresh the session in place — write a handoff, then compact, then resume from it.
---

Refresh this session in place so we can continue with a small context. If the user passed `aggressive`, write durable memory candidates to long-term memory when available; otherwise only flag them. If the user passed `selective`, use the three retention buckets below. The modes may be combined.

Do the following, then stop:

1. **Structured sweep (no prose):** enumerate every file created/edited/read, every command run with outcome, every TODO/FIXME, every unanswered user question, every abandoned approach with the reason.

2. **Synthesize** into sections 1–7 (write "None" if empty): Where We Started & Decisions Logged; Key Files & Documentation; Running State & Verification; Dead Ends; Deferred Items & Open Questions; Memory Candidates; Pick Up From Here. In `selective` mode, classify each thread exactly once, keeping uncertain material verbatim: 8. Verbatim-Kept Threads — active work, unresolved constraints, and current state copied exactly with speaker labels and required tool results; 9. Summarized Threads — completed threads reduced to outcomes and constraints; 10. Omitted Material — confirmed dead ends, redundant verbosity, and side-tracking listed by one-line title only. Append Refresh Continuation as section 11 in selective mode or section 8 otherwise. On restore, replay verbatim-kept threads unchanged and resume the immediate next action.

3. **Persist** to `<project_root>/handoffs/` (fallback `~/Documents/claude-handoffs/`): `YYYY-MM-DD_HHMM_<slug>.md` (UTC), `latest.md` (overwrite), and `.refresh-pending` containing only the current UTC ISO-8601 timestamp.

4. **Output exactly:** the file path; a one-sentence summary of where the session is; then: **"Now run `/compact`, then `/session-resume` — or just ask me to resume from the handoff."** Do not continue chatting.
