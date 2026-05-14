# URGENT notifications stream

_Auto-rotated 2026-05-14T09:48:34+07:00 — previous content archived to urgent-archived-2026-05-14.md (4607 bytes)._

_Append-only stream; rotates when size > 4096 bytes via urgent-md-rotate.sh Stop hook._

---

## [2026-05-14T10:59:15+07:00] HH-H.4 AUTO-REBOOT BLOCKED — STALE CHECKPOINT

**Session**: unknown
**Tokens**: 439023 (wind_down=180000 cliff=220000)
**Checkpoint age**: 7586 seconds (>7200 threshold)

**Action required**: write a fresh `agent-workspace/memory/checkpoints/latest.md` BEFORE the next reboot fires. Auto-reboot path is blocked until the marker `.auto-reboot-PRE-BLOCKED-stale-checkpoint` is cleared — happens automatically once checkpoint mtime is within 2h.

**Override**: set `STOCKFORGE_FORCE_REBOOT=1` env to bypass HH-H.1 strict guard if manual reboot needed.

## ESCALATION — 2026-05-14T11:16:07+07:00 — 5 HIGH-severity items (event=UserPromptSubmit)

Fired by: scripts/hooks/escalation-engine.sh
Action required from agent: fire AskUserQuestion to surface these to user.

- `human-workspace/notifications/20260514-033933-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-035633-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040026-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040113-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040210-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)

Per L-S310-1 rule 3: agent MUST fire AskUserQuestion when SCOPE+CHARTER bundle pending >6h with no user signal.

---

## ESCALATION — 2026-05-14T11:19:31+07:00 — 5 HIGH-severity items (event=Stop)

Fired by: scripts/hooks/escalation-engine.sh
Action required from agent: fire AskUserQuestion to surface these to user.

- `human-workspace/notifications/20260514-033933-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-035633-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040026-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040113-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040210-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)

Per L-S310-1 rule 3: agent MUST fire AskUserQuestion when SCOPE+CHARTER bundle pending >6h with no user signal.

---

## ESCALATION — 2026-05-14T12:15:02+07:00 — 6 HIGH-severity items (event=UserPromptSubmit)

Fired by: scripts/hooks/escalation-engine.sh
Action required from agent: fire AskUserQuestion to surface these to user.

- `human-workspace/notifications/20260514-033933-python-determinism-warn.md` (age=1h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-035633-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040026-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040113-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-040210-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/20260514-041726-python-determinism-warn.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)

Per L-S310-1 rule 3: agent MUST fire AskUserQuestion when SCOPE+CHARTER bundle pending >6h with no user signal.

---
