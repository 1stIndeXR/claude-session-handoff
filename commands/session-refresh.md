---
description: Refresh the session in place — handoff, then compact, then auto-restore. Pass "aggressive" to also write memory candidates to long-term memory.
argument-hint: "[aggressive]"
---

Run the `session-refresh` skill.

Mode: $ARGUMENTS

If `$ARGUMENTS` is empty, use conservative mode. If it contains "aggressive", use aggressive mode.

Follow the skill fully: handoff Passes 1-3, section 8 "Refresh Continuation", the `.refresh-pending` marker, then the closing instruction to run `/compact`. Stop after that — do not continue chatting.
