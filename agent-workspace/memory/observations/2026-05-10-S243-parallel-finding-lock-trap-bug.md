---
observation_id: 2026-05-10-S243-parallel-finding-lock-trap-bug
type: harness-defect
created_at: 2026-05-10T20:13:00+07:00
session: S243 (parallel to verifier dispatch aafc85ad872aa699b)
severity: HIGH
status: OPEN
related: drift-detector-S241b-phantom-dispatch-RC.md, M-S238-2, L-S239-4, L-S240-5
---

# S243 parallel finding — single-claude-instance-lock.sh EXIT trap removes lock immediately

## Empirical evidence

Pre-flight check at 20:13:00 ICT:
- `claude_processes=1` ✓
- Lock file at `agent-workspace/memory/.claude-instance.lock` — **ABSENT** despite SessionStart having fired ~30s earlier (UserPromptSubmit-injector log entry at 20:12:51)

## Root cause (source inspection)

`scripts/hooks/single-claude-instance-lock.sh`:

```bash
29: echo "session=${CLAUDE_SESSION_ID:-unknown}:${SELF_PID}:$(date +%s)" > "$LOCK"
30: trap 'rm -f "$LOCK"' EXIT
31: exit 0
```

The EXIT trap fires when the bash script itself exits at line 31. The lock is created at line 29 and removed by the trap microseconds later. The block-check at lines 20-27 is dead code — sibling claude.exe SessionStart will NEVER see a lock from a prior claude.exe, because the prior's hook already cleaned it up.

## Design-intent vs implementation mismatch

Checkpoint § Phantom-dispatch RC line 48 says: "Wired into `.claude/settings.json` SessionEnd chain to clean lock file". This confirms the design intent was a SESSION-lifetime lock (created by SessionStart, persisted across the parent claude.exe lifetime, cleaned by SessionEnd).

The line-30 trap defeats that design. Likely introduced during S241b wiring as a copy-paste from short-lived script idioms.

**S244 sandwich-dev confirmation (post-fix)**: SessionEnd cleanup at `.claude/settings.json:239` (`rm -f "${CLAUDE_PROJECT_DIR:-.}/agent-workspace/memory/.claude-instance.lock" 2>/dev/null; exit 0`) was already correctly wired. My initial read of the symptom (lock absent post-SessionStart) suggested SessionEnd cleanup was the source of removal — that was wrong. The trap on line 30 of the hook was the SOLE defect. SessionEnd cleanup is the correct mechanism and remains untouched by S244 fix.

## Counter-factual recovery

Remove line 30 trap entirely. Rely on SessionEnd hook (already wired per checkpoint line 48) to clean the lock. A 2nd claude.exe SessionStart will then see the lock from the 1st, the holder-pid alive check at lines 20-27 will detect it, and `STOCKFORGE_AUTONOMOUS_DISABLE=1` + exit 2 will fire.

## S244 LIVE re-run gating

S244 GO/NO-GO depends on phantom-dispatch protection. Verifier brief at S243 dispatch said "lock active" — that claim is empirically false. S244 should be NO-GO until this trap is removed AND a real 2-instance reproduction confirms the block-path fires.

Suggested S244 entry sequence:
1. Edit `single-claude-instance-lock.sh` line 30: remove trap
2. Verify SessionEnd hook still cleans `.claude-instance.lock` 
3. Reproduction smoke test: spawn 2nd claude.exe in same project, observe BLOCK message + exit 2
4. THEN proceed with 5-ticker LIVE re-run

## Why parked, not fixed this turn

- Sandwich-verifier `aafc85ad872aa699b` is in-flight on D-054 ratification (orthogonal scope)
- Editing harness while verifier reads packages/ files = no conflict, but harness fix needs its own dedicated turn with companion firing-test per Phase 3.5 §HH-G
- Per `harness_priority_one`, this surfaces as S244 PRIORITY 1 ABOVE the LIVE 5-ticker re-run

## Promotion candidate

This is the 2nd instance of trap-eats-state defect class (1st was M-S189-1 HH-H.1 threshold). If a 3rd surfaces → promote to formal lesson L-S243+-1: "trap on EXIT in SessionStart-tier hooks defeats persistent state" (Charter Principle 8 + AP-23 1st-instance rule does NOT yet promote this to formal binding).

---

## AMENDMENT 2026-05-10T20:55+07:00 — empirical IN-SESSION race confirmation

While drafting this observation and dispatching S244 sandwich-dev, **the harness empirically reproduced the phantom-dispatch race** that the broken lock was supposed to prevent:

- I dispatched ONE sandwich-verifier (`aafc85ad872aa699b`) at S243 entry.
- TWO completion notifications arrived: `aafc85ad872aa699b` AND `aec691ba7fea92b3e` (distinct agent IDs, distinct duration metrics).
- Both wrote to the canonical observation path `agent-workspace/memory/observations/sandwich-verifier-S243-d054-ratification.md`, producing a composite Sections A-I file (per the 2nd verifier's own F-Operational-1 self-report).
- Both reached identical D-054 = ACCEPTED verdict (no contradiction in semantic output, but the race is real).

This is the **4th instance of L-S240-5 phantom-dispatch class** (M-S238-2 + L-S239-4 + L-S240-5 + S243 IN-SESSION). AP-23 promotion threshold MET for L-S240-5.

**Finding upgraded**: the lock-trap defect documented above is not theoretical — it's actively misfiring in real-time. The S244 PRIORITY 1 fix is now URGENT, not merely BLOCKING.

**New scope for S244+** (out of original sandwich-dev brief):
- F-Operational-1 from verifier indicates single-claude-instance-lock (cross-process) does NOT cover IN-SESSION parallel subagent dispatch. Even after the trap fix, parallel `Agent` tool calls within the same parent claude.exe could still race on canonical paths. Mitigation candidates: (a) per-subagent-dispatch unique observation paths (suffix with agent_id), (b) write-once enforcement at observation file level, (c) sandwich-verifier role hard-rule to write to `<base-name>-<agent-id>.md` not canonical.
- This expansion is documented here NOT actioned this turn — S244 sandwich-dev is already in flight on the trap-fix scope; expanding mid-flight = scope creep.

**Promotion now triggered (2 separate classes)**:
- L-S240-5 (phantom-dispatch) — AP-23 4-instance threshold MET; format formal lesson at S245 entry retrospectively
- L-S243+-1 (trap-eats-state) — still 1st-instance per AP-23; needs 2nd to promote

**Parent action**: noted for promote-rule subagent dispatch at S245 entry; do NOT block S244 sandwich-dev mid-flight on this finding.
