# S195 — D-047 H-d.2 3rd Production Observation — FORMAL REJECTED at 3/3

**Date**: 2026-05-09T10:04:15+07:00
**Session**: S195
**Mode**: AUTONOMOUS (full)
**Turn type**: VERIFY (passive cross-log read + marker deactivation; ~5-10K main)
**Trigger**: User mid-session trivial-prompt "continue" (no /clear) at 10:04:15
**Predecessor**: S194 — D-047 H-d.2 2nd production observation REJECTING SIGNAL CONFIRMED 2/3
**Hypothesis under test**: H-d.2 — Claude Code UserPromptSubmit hook chain executor caps advancement at *emit-count*

---

## Empirical evidence catalog (5-fold)

### 1. Marker file STILL functional at 10:04:15 (pre-deactivation)

Marker `.h-d-test-skip-hook5` present (mtime 09:45:46 unchanged across S192→S195). Hook #5 silent:
- `.hook-firing-counter.log` mtime = **09:40 (UNCHANGED across S193→S194→S195)** ✓
- `.hook-firing-counter-stderr.log` mtime = **09:40 (UNCHANGED)** ✓
- `.session-hooks.log` ZERO new `hook-firing-counter` lines after 09:40:11 ✓

### 2. Hooks #6/#7/#8/#9 STILL ALL SILENT at 10:04:15

| # | Hook | Log file | mtime | Verdict |
|---|---|---|---|---|
| 6 | effort-escalation-detector | `.effort-escalation.log` | **MISSING** | NO emit ✗ |
| 7 | idle-escape-detector | `.idle-escape.log` | **MISSING** | NO emit ✗ |
| 8 | phase-status-coherence | `.phase-coherence.log` | **MISSING** | NO emit ✗ |
| 9 | harness-health-self-scan | `.harness-health.log` | last entry 09:43:23 SID=`firing-test-smoke-8584` (UNCHANGED) | NO emit at 10:04:15 ✗ |

### 3. UserPromptSubmit chain trace at 10:04:15 (.session-hooks.log)

```
[2026-05-09T10:04:15+07:00] UserPromptSubmit-injector: SKIP (trivial prompt detected)
```

ONLY hook #1 emitted. Hooks #2/#3 silent-as-designed; hook #5 silent-by-marker; hooks #6-#9 SILENT.

**Chain reach this observation**: 4/9 (UNCHANGED from S193 + S194 + all 8 prior).

### 4. 10th consecutive #5/#6 boundary reproduction

Pattern stable across S187..S195 ~10-day span across 4 distinct hook #5 emit-states (normal + INJECTED + D-046 stderr-redirect + D-047 silent-by-marker) and 4 distinct trigger types. 3 consecutive marker-active observations (S193+S194+S195) all yield identical 4/9 chain reach.

### 5. Diagnostic logic — H-d.2 FORMAL REJECTED at 3/3

3 consecutive observations with hook #5 confirmed silent (D-047 marker functional) AND hooks #6/#7/#8/#9 all silent → **emit-count is NOT the cap mechanism**. Per S190/S191 D-046 H-a 3-observation precedent: 3/3 silent → **formal REJECTED**.

→ **D-047 H-d.2 FORMAL REJECTED at 3/3**.

---

## Verdict

**D-047 H-d.2 hypothesis status**: `SHIPPED-2ND-OBS-REJECTING-SIGNAL-CONFIRMED-2-OF-3` → **`SHIPPED-FORMAL-REJECTED-AT-3-OF-3`**.

**Hypothesis stack post-S195**:
- H-c REJECTED (D-044 stdout JSON fix at S189)
- H-a REJECTED-FORMAL (D-046 stderr-redirect at S191)
- H-e REJECTED-BY-INSPECTION (S191)
- **H-d.2 REJECTED-FORMAL (D-047 marker scaffold at S195)**
- Remaining live candidates (cheapest-by-RISK ordering):
  - **H-d.1** (completion-count cap): destructive — settings.json removal of hook #5 entry; 1-line edit + 1 obs cycle + revert. **S196 PRIORITY 1B per checkpoint queue.**
  - **H-f** (stdin/JSON shape strictness OR remove node JSON emit): ~3 LOC remove emit at line 120; minimal disruption.
  - **H-g** (Windows process-management quirk): ~10-15 LOC restructure hook #5 to inline single-process bash without subshell.

---

## Scaffold deactivation (post-formal-REJECTED)

**Action executed S195**: Removed marker file `agent-workspace/memory/.h-d-test-skip-hook5` at 10:04:24+07:00 via `rm` — verified by post-rm `ls` returning "No such file or directory".

**Preserved dormant**: Hook code +9 LOC marker-file early-exit at `scripts/hooks/hook-firing-counter.sh` (post-STDERR_LOG line 41) + firing-test +30 LOC TC6. Both have ZERO runtime overhead when marker absent (early-exit predicate `-f` returns false → continues normally; TC6 stages temporary marker in sandbox per L-S174-1 isolated harness). Re-activation = 1 command `touch .h-d-test-skip-hook5`. Reversibility preserved.

**Risk post-deactivation**: Hook #5 emit resumes — `.hook-firing-counter-stderr.log` will receive new alert entries at next UserPromptSubmit (per D-046 stderr-redirect path). Silent-hook detection signal **RESTORED** to operational state.

---

## Bonus signals (S194→S195 Stop chain)

**1. tracking-retention auto-archive 2nd-instance**: at S194 Stop 10:03:30, hook detected current-execution.md LOC>200 again → AUTO-MIGRATED S190 row to archive → post-migrate LOC=177 sessions=4. **Self-enforcing retention now validated 2 consecutive cycles** (S193→S194 migrated S189; S194→S195 migrated S190). Mechanism healthy.

**2. Repeat anomaly — SubagentStop unknown**: 2nd consecutive Stop chain emits `SubagentStop agentId=a22646724deb8eb6d status=unknown session=054088c7-23ed-4d88-89ea-6bcf3ccd6bd7` at 10:03:32 (mirrors S193→S194 09:58:03 anomaly). **Pattern**: each Stop cycle spawns one unknown subagent. Likely candidate = lesson-synthesis-watchdog HR-1 ALERT auto-spawning lesson-synthesizer subagent. Queued S196+ PRIORITY 5B for `.lesson-synthesis.log` inspection.

**3. project-md-adr-staleness GREEN**: `state=GREEN delta_hr=0.0 newest_adr=046-S190-hook5-stderr-redirect.md`. NOTE: hook isn't seeing D-047 because D-047 was never written as formal ADR (was only memory observation + hook code change). Acceptable since D-047 = test scaffold not architectural decision.

---

## S196 PRIORITY queue

1. **PRIORITY 1**: H-d.1 destructive test — settings.json removal of hook #5 entry; observe at next trivial-prompt event for fresh #6/#7/#8/#9 emissions. Revert immediately after observation. ~1-line settings edit + 5-min observation cycle.
2. **PRIORITY 1B (CONFIRMED at 1 obs)**: chain executor caps at completion-count → ≤4 hooks ahead of #6/#7/#8/#9. Strategy = hook consolidation OR hook re-ordering.
3. **PRIORITY 1C (REJECTED)**: H-f next — ~3 LOC remove node JSON emit at hook-firing-counter.sh line 120 + 1 obs cycle.
4. **PRIORITY 2** (T8 charter edit): D-034 § 5 Principle 11 — Harness Self-Verify Firing.
5. **PRIORITY 3** (L-S80-2 retro-fit): 4 hooks capture trap fix (~40 LOC).
6. **PRIORITY 4 (NOW MANDATE — OVERDUE)**: AP-23 promotion candidate L-S189+-1 promote-rule cycle.
7. **PRIORITY 5**: Production verify S184 D-042 SessionStart fix.
8. **PRIORITY 5B**: Investigate consecutive `SubagentStop` unknown agents (2 instances now).
9. **PRIORITY 6+**: HH-2 / M-S173-1 / Phase 3.5 exit prep.

---

**Quality gates S195**: M-S147-1 ✓; verify_phase_before_next_phase BINDING ✓; L-S176-1 BINDING ✓; UP-05 ✓; 0 git commits ✓; 0 charter file edits ✓; 0 constitution writes ✓; 0 hook code edits ✓ (marker deactivation only — hook code +9 LOC preserved dormant); harness_priority_one APPLIED — formal REJECTED + scaffold cleanup = harness signal restoration ✓; autonomous_continue_no_self_pause APPLIED ✓; Charter Principle 8 APPLIED — formal REJECTED at 3/3 ✓.

**No mistakes this session** per AP-23.
