---
description: Refresh the session in place — write a handoff, compact, then resume. Pass "selective" to keep active threads verbatim.
argument-hint: "[selective] [aggressive]"
---

Refresh this session in place so we can continue with a small context. Arguments: $ARGUMENTS (`aggressive` writes durable facts to long-term memory if available; `selective` enables three-bucket retention; the modes may be combined).

Do the following, then stop:

1. **Structured sweep (no prose):** enumerate every file created/edited/read, every command run with outcome, every TODO/FIXME, every unanswered user question, every abandoned approach with the reason.

2. **Synthesize** the sweep into sections 1–7: Where We Started & Decisions Logged; Key Files & Documentation; Running State & Verification; Dead Ends; Deferred Items & Open Questions; Memory Candidates; Pick Up From Here. Write "None" if empty. In `selective` mode, classify every conversation thread into exactly one additional bucket, defaulting uncertain material to verbatim: 8. Verbatim-Kept Threads — active work, unresolved constraints, and current task state copied exactly in original order with speaker labels and required tool results, without paraphrasing, reformatting, correction, or truncation; 9. Summarized Threads — completed threads reduced to outcomes, durable decisions, and constraints; 10. Omitted Material — confirmed dead ends, redundant verbosity, and unrelated side-tracking listed by one-line title only, with no content or rationale. Omit sections 8–10 outside selective mode. Append Refresh Continuation as section 11 in selective mode or section 8 otherwise; state the immediate next action verbatim and instruct: "after compaction, replay verbatim-kept threads unchanged, resume this immediately, confirm in one line, do not wait for user confirmation."

3. **Persist** to `<project_root>/handoffs/` (fallback `~/Documents/claude-handoffs/`):
   - `YYYY-MM-DD_HHMM_<slug>.md` (UTC; slug = kebab-case of the original goal, max 5 words)
   - `latest.md` (overwrite — the restore entry point)
   - `.refresh-pending` containing only the current UTC ISO-8601 timestamp

4. **Output exactly:** the file path written; a one-sentence summary of where the session is; then: **"Now run `/compact`, then `/session-resume` — or just ask me to resume from the handoff."** Do not continue chatting.
