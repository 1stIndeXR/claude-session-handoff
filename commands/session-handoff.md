---
description: Generate a session handoff artifact. Pass "aggressive" to also write memory candidates to long-term memory.
argument-hint: "[aggressive]"
---

Run the `session-handoff` skill.

Mode: $ARGUMENTS

If `$ARGUMENTS` is empty, use conservative mode (artifact only, memory candidates flagged for review).
If `$ARGUMENTS` contains "aggressive", use aggressive mode (artifact + write memory candidates directly).

Follow the skill's 4-pass process. Stop after Pass 4 — do not continue chatting.
