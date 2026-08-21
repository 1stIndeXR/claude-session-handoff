---
description: Refresh the session in place — handoff, compact, then auto-restore. Pass "selective" to keep active threads verbatim; pass "aggressive" to write memory candidates.
argument-hint: "[selective] [aggressive]"
---

Run the `session-refresh` skill.

Mode: $ARGUMENTS

If `$ARGUMENTS` is empty, use conservative memory handling and comprehensive retention. If it contains "aggressive", use aggressive memory handling. If it contains "selective", classify threads into verbatim-kept, summarized, and omitted buckets. These modes may be combined.

Follow the skill fully: handoff Passes 1-3, selective sections when requested, "Refresh Continuation", the `.refresh-pending` marker, then the closing instruction to run `/compact`. Stop after that — do not continue chatting.
