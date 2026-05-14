# URGENT notifications stream

_Auto-rotated 2026-05-13T14:38:44+07:00 — previous content archived to urgent-archived-2026-05-13.md (14620 bytes)._

_Append-only stream; rotates when size > 4096 bytes via urgent-md-rotate.sh Stop hook._

---

## [2026-05-14T09:15:00+07:00] Q-INT mega-bundle RATIFIED + Ritual Demotion BINDING + Block-surface policy ACTIVE

**Per AskUserQuestion 4-question batch fired S310 (2026-05-14T02:05:00Z)**, user ratified:

1. **Q-INT (12 questions)**: blanket-A (Q-INT-1=C; Q-INT-4=B; all others A). Decision D-058 written. Wave 0/1/2 IMPL UNBLOCKED.
2. **Ritual demotion**: BINDING (L-S310-1). Sync-grilling cadence + ROUTINE-IDLE close ritual SUSPENDED. Agent emits one-line ack instead of 4-file housekeeping.
3. **Block-surface policy**: auto-fire AskUserQuestion when SCOPE+CHARTER bundle pending >24h AND no unblocked product work. UP-06 "NO-Silent-Default" applies to agent→user direction too.
4. **Next action**: Wave 0 W0-1 FSM IMPL (FOCUSED_IMPL, ~150-300K tokens; closes L-S258-2 4th-instance URGENT).

**Pending agent action on next "continue"**: dispatch sandwich-dev for Wave 0 W0-1 IMPL session via session plan (will be written this turn).

**Charter-tier deferred**: Q-INT-9 I-S1-1 sub-rule + confidence-field-grep.sh hook SHIP IN WAVE 0 but charter amendment goes through D-055-style cool-down before binding.

---

## [2026-05-14T09:00:00+07:00] PROPOSAL FILED — Ritual Demotion (busy-work loop)

**Trigger**: User-surfaced observation (this turn, in Vietnamese): main session đang dành phần lớn budget cho harness housekeeping; product work hầu như không tiến triển; agent dispatch song song không đáng kể.

**Empirical finding (S270-S309 = 40 sessions)**:
- 0% PRODUCT work (thesis / IMPL / VN stock analysis / W0-1 nautilus / G.1+G.2 SDK removal)
- 62.5% ROUTINE-IDLE (24 consecutive idle closes; catch-rate 0/24)
- 35% SYNC-GRILLING mechanical cadence (18 fires; catch-rate 0/18; SCOPE drift +5pt purely from cadence)
- 2.5% HARNESS-FIX (S290 //neew)

**Applicable rule** (CLAUDE.md § Hard Rules — Ritual demotion clause): catch-rate=0 over 3+ consecutive sessions ⇒ demote/retire. Both rituals exceed threshold by 8× / 6×.

**Proposal**: `agent-workspace/proposals/ritual-demotion-2026-05-14-busy-work-loop.md`

**Ratification options**: A=apply both demotions / B=sync-grilling only / C=routine-idle only / D=reject / E=alternative

**Behavioral hold ACTIVE immediately pending ratification**: S310+ will emit one-line state ack instead of running idle close ritual; sync-grilling cadence on hold (event-driven only — triggers (a)-(d) in proposal still authorized).

---

## [2026-05-14T07:03:47+07:00] HH-H.4 AUTO-REBOOT BLOCKED — STALE CHECKPOINT

**Session**: unknown
**Tokens**: 366274 (wind_down=180000 cliff=220000)
**Checkpoint age**: 35539 seconds (>7200 threshold)

**Action required**: write a fresh `agent-workspace/memory/checkpoints/latest.md` BEFORE the next reboot fires. Auto-reboot path is blocked until the marker `.auto-reboot-PRE-BLOCKED-stale-checkpoint` is cleared — happens automatically once checkpoint mtime is within 2h.

**Override**: set `STOCKFORGE_FORCE_REBOOT=1` env to bypass HH-H.1 strict guard if manual reboot needed.

## ESCALATION — 2026-05-14T09:30:58+07:00 — 3 HIGH-severity items (event=Stop)

Fired by: scripts/hooks/escalation-engine.sh
Action required from agent: fire AskUserQuestion to surface these to user.

- `agent-workspace/memory/decisions/034-S173-T8-charter-revision-v1.1-principle-11-proposal.md` (age=170h, action=ESCALATE-ASKUSERQUESTION)
- `agent-workspace/memory/mistake-log.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/2026-05-13T07-53-24Z-D-053-empirical-divergence.md` (age=18h, action=ESCALATE-ASKUSERQUESTION)

Per L-S310-1 rule 3: agent MUST fire AskUserQuestion when SCOPE+CHARTER bundle pending >6h with no user signal.

---

## ESCALATION — 2026-05-14T09:39:33+07:00 — 3 HIGH-severity items (event=UserPromptSubmit)

Fired by: scripts/hooks/escalation-engine.sh
Action required from agent: fire AskUserQuestion to surface these to user.

- `agent-workspace/memory/decisions/034-S173-T8-charter-revision-v1.1-principle-11-proposal.md` (age=170h, action=ESCALATE-ASKUSERQUESTION)
- `agent-workspace/memory/mistake-log.md` (age=0h, action=ESCALATE-ASKUSERQUESTION)
- `human-workspace/notifications/2026-05-13T07-53-24Z-D-053-empirical-divergence.md` (age=18h, action=ESCALATE-ASKUSERQUESTION)

Per L-S310-1 rule 3: agent MUST fire AskUserQuestion when SCOPE+CHARTER bundle pending >6h with no user signal.

---
