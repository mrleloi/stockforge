---
observation_id: 2026-05-08-S189-autonomous-loop-revival
type: empirical-investigation + harness-fix-ship + production-verification-finding
created_at: 2026-05-08
phase: 3.5
session: S189
related_decisions: D-045 (this S189 ship; HH-H.1 threshold relaxation 300s→1800s) / D-044 (S188 predecessor; H-c REJECTED at 14:55:44 production observation)
related_observations: 2026-05-07-S188-userprompt-chain-stop-discrimination.md
status: SHIPPED-PENDING-PRODUCTION-VERIFICATION + D-044-H-c-REJECTED
---

# S189 — autonomous-loop revival via HH-H.1 threshold relaxation + D-044 H-c REJECTED at production

## User trigger

User prompt at 2026-05-08T14:55:44+07:00 (26+ hours after S188 close): "sao không autonomous run tiếp. lỗi harness à. fix"

Translation: "Why isn't autonomous running anymore? Harness bug? Fix it."

## Root cause analysis (2-fold finding)

### Finding 1 — Autonomous loop dead since S188 close

**Empirical evidence chain:**

1. `.auto-reboot-BLOCKED-stale-checkpoint` marker present at session entry (mtime 2026-05-07T12:25 = S188 close):
   ```
   AUTO-REBOOT BLOCKED at 2026-05-07T12:25:23+07:00
   Reason: checkpoints/latest.md mtime is 709s old (>300s threshold; HH-H.1 guard).
   Action: write a fresh checkpoint via /handoff-prep before reboot fires.
   Override: set STOCKFORGE_FORCE_REBOOT=1 to bypass.
   ```

2. `.session-hooks.log` shows: `[2026-05-07T12:25:23+07:00] WIND_DOWN auto-reboot firing on Stop tokens=207318` followed by ZERO subsequent spawn entries until `[2026-05-08T14:55:44+07:00] UserPromptSubmit-injector: invariants reminder injected (prompt_len=55)` — first user prompt 26+ hours later.

3. Source inspection at `scripts/session-self-reboot.sh:32-37` reveals HH-H.1 guard: `if [ "$CHECKPOINT_AGE" -gt 300 ]; then ...BLOCKED...`. 300s = 5min threshold.

4. S188 turn timeline reconstruction:
   - 12:03:01 UserPromptSubmit (turn start)
   - ~12:14 latest.md slim rewrite Edit (during budget-trim work)
   - ~12:24 last memory artifact edit (session log)
   - 12:25:23 Stop fire → checkpoint mtime ~660s old > 300s → BLOCKED

**Verdict**: HH-H.1 300s threshold is systematically too aggressive for typical IMPL turn duration. S188 was a clean FOCUSED_IMPL turn that wrote checkpoint EARLY then continued IMPL work for ~11 more minutes — exactly the use-case where 300s threshold false-positives.

### Finding 2 — D-044 H-c REJECTED at 1st production verification

**Empirical evidence at S189 entry UserPromptSubmit 14:55:44:**

| Hook | Standalone .log status at 14:55:44 | Verdict |
|------|------------------------------------|---------|
| #1 userprompt-invariants-injector | session-hooks.log INJECTED ✓ | EMIT |
| #2 stale-prompt-detector | session-hooks.log "clean (no stale refs)" ✓ | EMIT |
| #3 correction-rate-tracker | (silent on no-match path) | EXPECTED-SILENT |
| #4 in-flight-subagent-watcher | .in-flight-subagent-watcher.log [14:55:44] ✓ | EMIT |
| #5 hook-firing-counter | .hook-firing-counter.log [14:55:44] ✓ (D-044 fix verified emit) | EMIT |
| #6 effort-escalation-detector | .effort-escalation.log MISSING | UNDETECTABLE |
| #7 idle-escape-detector | .idle-escape.log MISSING | NO EMIT |
| #8 phase-status-coherence | .phase-coherence.log MISSING | NO EMIT |
| #9 harness-health-self-scan | .harness-health.log last 12:16:38 yesterday firing-test SID | NO EMIT |

**Verdict**: D-044 H-c additive stdout JSON fix at hook #5 did NOT advance chain past #5/#6 boundary. Hooks #7/#8/#9 still silent at production cadence. Per D-044 verified_by step 5: H-c REJECTED — S190 escalates to H-a (suppress hook #5 stderr) test.

**Preliminary S190 H-a test design (non-destructive variant)**: redirect hook #5 stderr printf at lines 100-101 from `>&2` to APPEND `.hook-firing-counter-stderr.log` instead. This:
- Preserves silent-hook alert content (file-readable for diagnosis)
- Suppresses stderr emission to chain executor (tests if stderr specifically triggers truncation)
- Reverts cleanly via 1 LOC edit if rejected

If hooks #7/#8/#9 emit at next /clear+trivial-prompt event post-S190 H-a fix → H-a CONFIRMED.

## Recovery + Fix shipped this turn

### Step 1 — Recovery (Task #7)

```bash
rm /c/htdocs/stockforge/agent-workspace/memory/.auto-reboot-BLOCKED-stale-checkpoint
# verified absent post-rm
```

Wrote fresh `checkpoints/latest.md` with S189 entry state (mtime current; 81s age at verification).

### Step 2 — HH-H.1 threshold relaxation 300s → 1800s (Task #8, D-045)

Modified `scripts/session-self-reboot.sh:15-39`:
- Replaced hardcoded `300` with `HH_H1_THRESHOLD_S="${STOCKFORGE_HH_H1_THRESHOLD_S:-1800}"` parameterized variable
- Updated condition `if [ "$CHECKPOINT_AGE" -gt "$HH_H1_THRESHOLD_S" ]`
- Updated BLOCKED marker text to cite runtime-formatted threshold (not hardcoded 300s)
- Expanded inline comment with S189 D-045 root-cause rationale

Net production code: +10 LOC. NO companion firing-test added (Step 2 skip rationale in D-045: not a hook; sibling auto-reboot-handoff-verify-fire-test.sh covers same threshold-vs-mtime pattern; keystroke-sender resists safe isolated testing).

### Step 3 — Verification

| Mechanism | Result |
|-----------|--------|
| `bash -n scripts/session-self-reboot.sh` | PASS (parse OK) ✓ |
| grep verification of HH_H1_THRESHOLD_S declaration + condition | PASS ✓ |
| Checkpoint freshness post-write (mtime 81s age) | PASS (within new 1800s + old 300s) ✓ |
| Production validation | DEFERRED to next auto-reboot fire |

## M-S189-1 NEW HIGH

| Field | Value |
|-------|-------|
| ID | M-S189-1 |
| Session | S189 |
| Severity | HIGH |
| What happened | HH-H.1 stale-checkpoint guard blocked auto-reboot at S188 close 12:25:23 → autonomous loop silently dead for 26+ hours until user manually re-prompted at S189 entry 14:55:44 |
| Root cause | 300s threshold too aggressive for typical IMPL turn duration (10-25min FOCUSED_IMPL); S188 wrote checkpoint at 12:14, continued IMPL work, Stop fired 12:25 with checkpoint mtime ~660s > 300s → BLOCKED marker written → autonomous loop dies |
| Prevention rule | Threshold relaxed 300s → 1800s with env override (D-045 SHIPPED). Defense-in-depth via HH-H.4 outer fence 7200s preserved. |
| Where applied | scripts/session-self-reboot.sh +10 LOC (lines 15-44 modified); D-045 ADR + this observation |
| Recurrence class | Same as M-S171-1 (idle-escape pattern) + M-S176-1 (file-pattern hook fail-silent) — harness design-time threshold tuning has bitten StockForge multiple times |

Promotion candidate L-S189+-1 IF a 2nd instance of harness-guard-too-strict surfaces in S190+ (1st instance = HH-H.1 300s; promotion threshold = 2 instances per AP-23).

## Files this turn (S189-specific)

**NEW**:
- `agent-workspace/memory/decisions/045-S189-hh-h1-threshold-relaxation.md` (D-045 full 12-field; ~280 LOC; 6 options A-F considered; A chosen)
- `agent-workspace/memory/observations/2026-05-08-S189-autonomous-loop-revival.md` (this file; ~180 LOC)
- `agent-workspace/memory/sessions/2026-05-08-session-189.md` (forthcoming)

**EDITED**:
- `scripts/session-self-reboot.sh` (+10 LOC; HH-H.1 threshold parameterized 300s→1800s default; env override STOCKFORGE_HH_H1_THRESHOLD_S; comment expansion with S189 root-cause)
- `agent-workspace/memory/checkpoints/latest.md` (full rewrite for S189 entry state; mtime fresh 81s)
- `agent-workspace/memory/current-execution.md` (S189 row prepend)
- `agent-workspace/memory/project.md` (top header update + Recent ADRs prepend D-045)
- `agent-workspace/memory/mistake-log.md` (M-S189-1 NEW HIGH digest entry prepend)

**REMOVED**:
- `agent-workspace/memory/.auto-reboot-BLOCKED-stale-checkpoint` (stale marker from S188 12:25:23 yesterday)

## S190 NEXT ACTION priority

1. **PRIORITY 1**: H-a test for chain-stop discrimination at #5/#6 boundary (D-044 H-c REJECTED at S189 verification). Non-destructive variant: redirect hook #5 stderr printf at lines 100-101 from `>&2` to APPEND `.hook-firing-counter-stderr.log` (preserves alert content; tests if stderr emission specifically triggers chain truncation). Wait for next /clear+trivial-prompt event. If hooks #7/#8/#9 emit → H-a CONFIRMED. ~30-50K main.
2. **PRIORITY 1B (CONFIRMED-only)**: Option A retro-fit hooks #6-#9 with stderr-redirect-to-log pattern + verify chain reaches 9/9.
3. **PRIORITY 2**: Production verify D-045 — observe successful auto-reboot fire at next WIND_DOWN/CLIFF crossing. If still BLOCKED → check marker content for actual mtime; consider further relaxation to 3600s (60min) for MULTI_TASK_IMPL turns.
4. **PRIORITY 3** (L-S80-2 retro-fit): 4 hooks `VAR=$(grep -c ...)` capture trap fix.
5. **PRIORITY 4** (T8 charter edit): cool-down opens ≥2026-05-09 ~05:30 ICT (~14h from S189 entry).
6. **PRIORITY 5**: HH-2 / M-S173-1 / Phase 3.5 exit prep.

## Hard rules binding sustained (S189)

ALL prior bindings: L-S176-1 + L-S174-1 + L-S65 + Phase 3.5 §HH-G + verify_phase_before_next_phase + harness_priority_one + autonomous_continue_no_self_pause + Charter Principle 8.

NO new binding rules surface this S189 (clean harness-recovery + threshold-fix execution; HH-H.1-too-tight refinement captured in observation NOT promoted per AP-23 1st-instance rule — promotion candidate L-S189+-1 IF 2nd instance surfaces).

## Hard locks honored (S189)

- 0 git commits ✓ (CLAUDE.md hard rule + autonomous_no-commit policy)
- 0 charter file edits ✓ (T8 cool-down still active until 2026-05-09 ~05:30 ICT)
- 0 constitution writes ✓ (M-S173-1 deny holds)
- 0 new hooks authored ✓ (modified existing script)
- 0 new firing-tests authored ✓ (Step 2 skip rationale; not-a-hook + sibling-pattern-covered)

## Self-track

S189 ~25-35K main turn (FOCUSED_IMPL envelope ~30-50K; on-target low-mid). Outputs: 1 NEW ADR (~280 LOC; D-045) + 1 NEW observation (this file ~180 LOC) + 1 NEW session log (forthcoming) + 5 EDITED memory + 1 REMOVED stale marker; production code +10 LOC; 0 new hooks; 0 new firing-tests; 0 commits; 0 charter edits; 0 constitution writes.

End of S189 observation. **D-045 HH-H.1 threshold relaxation SHIPPED at unit level pending production verification at next auto-reboot fire (S190+ when budget hits WIND_DOWN/CLIFF). D-044 H-c REJECTED at S189 1st production observation; S190 PRIORITY 1 = H-a test (non-destructive stderr-redirect variant). Phase 3.5 IN-PROGRESS-PARTIAL-S173 unchanged (T8 cool-down ≥2026-05-09 ~05:30 ICT, ~14h from S189 entry).**
