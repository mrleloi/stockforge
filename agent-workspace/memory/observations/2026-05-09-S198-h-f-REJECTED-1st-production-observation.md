# S198 — D-048 H-f 1st Production Observation: REJECTED at 1 obs (cap is NOT stdout-bytes/content)

**Date**: 2026-05-09
**Trigger**: User trivial-prompt "continue" at 2026-05-09T10:29:58+07:00 (~4.5 min after S197 H-f deploy at 10:25:26)
**Session**: S198 (VERIFY+IMPL hybrid; H-f verdict + scaffold revert)
**Predecessor**: S197 — D-047 H-d.1 REJECTED + D-048 H-f scaffold deployed via marker-file gate
**Hypothesis (H-f)**: Chain executor caps at stdout-emit byte/content threshold — silencing the node JSON stdout emit at `scripts/hooks/hook-firing-counter.sh` line 130 should free chain to advance to ≥1 of #6/#7/#8/#9.

## Empirical Evidence (5-fold)

### 1. UserPromptSubmit hook #1 fired (10:29:58)
From `.session-hooks.log`:
```
[2026-05-09T10:29:58+07:00] UserPromptSubmit-injector: SKIP (trivial prompt detected)
```
Hook #1 (userprompt-invariants-injector) FIRED → trivial-prompt SKIP path. ✓

### 2. Hook #4 fired (in-flight-subagent-watcher)
- `.in-flight-subagent-watcher.log` mtime = 10:29 (BUMPED) ✓

### 3. Hook #5 fired internally — counter increment + log writes (stdout JSON gated by marker)
- `.hook-firing-counter.log` mtime = 10:29 (BUMPED — counter still increments via append-only log writes)
- `.hook-firing-counter-stderr.log` mtime = 10:29 (BUMPED — stderr alert content still routed to file per D-046)
- Marker `.h-f-test-skip-stdout-json` was present at trigger time (created 10:25:26; removed 10:30:08 post-verdict) → node JSON stdout emit suppressed by H-f gate.

✓ Hook #5 ran to completion BUT emitted ZERO stdout bytes (H-f scaffold active per design).

### 4. Hooks #6/#7/#8/#9 STILL ALL SILENT — H-f REJECTING SIGNAL
| # | Hook | Log file | Expected if H-f CONFIRMED | Observed | Verdict |
|---|---|---|---|---|---|
| 6 | effort-escalation-detector | `.effort-escalation.log` | CREATED with current SID | **MISSING** | SILENT |
| 7 | idle-escape-detector | `.idle-escape.log` | CREATED with current SID | **MISSING** | SILENT |
| 8 | phase-status-coherence | `.phase-coherence.log` | CREATED with current SID | **MISSING** | SILENT |
| 9 | harness-health-self-scan | `.harness-health.log` | APPEND with current SID | mtime 09:43:23 firing-test-smoke-8584 SID UNCHANGED | SILENT |

ALL 4 logs: SAME state as S197 H-d.1 baseline. Silencing stdout JSON emit had ZERO effect on chain advancement.

### 5. 13-instance evidence baseline
S187..S197 (12 instances across 5 distinct hook #5 emit/registration states: normal emit / S188 D-044 stdout-add / S190 D-046 stderr-redirect / S192 D-047 marker silent / S196 settings.json absent / S197 settings.json restored) + S198 H-f stdout-emit silenced = 13-instance pattern stable. Cap mechanism mathematically narrowed.

## Verdict: H-f REJECTED at 1 obs

**Diagnostic logic binary-decisive**: H-f = "chain executor caps at stdout-bytes/content threshold" → silencing stdout JSON emit at hook #5 should free chain. Observed: silencing stdout had ZERO effect. **Cap is NOT stdout-emit content/bytes.**

Single observation decisive: hypothesis binary on deterministic marker-file state; 13-instance pattern + 1 differential.

**Hypothesis stack post-S198 ALL CHEAP-CANDIDATES EXHAUSTED**:
- H-c REJECTED (S189 D-044) — fail-fast set -e
- H-a REJECTED-FORMAL (S191 D-046) — stderr emission
- H-e REJECTED-BY-INSPECTION (S191) — Stop event mid-fire
- H-d.2 REJECTED-FORMAL (S195 D-047) — emit-count cap
- H-d.1 REJECTED at 1 obs binary-decisive (S197) — registration-count cap
- **H-f REJECTED at 1 obs binary-decisive (S198) — stdout-bytes/content cap**

**Live candidate (only remaining cheap-by-RISK)**: **H-g** (~10-15 LOC chain instrumentation; surface cap mechanism via per-hook timing+output capture).

## D-048 H-f status transition
`SCAFFOLD-DEPLOYED-PENDING-PRODUCTION-OBSERVATION` → **`SHIPPED-1ST-PRODUCTION-OBSERVATION-REJECTED-1-OF-1-BINARY-DECISIVE`**

## Revert protocol executed (S198 IMPL)

### 1. Marker removed (10:30+)
```
$ rm agent-workspace/memory/.h-f-test-skip-stdout-json
$ ls agent-workspace/memory/.h-f-test-skip-stdout-json
ls: cannot access ...: No such file or directory
```
✓ Marker file deleted; default stdout JSON emit re-armed.

### 2. Hook code reverted to pre-S197-H-f state
Edit `scripts/hooks/hook-firing-counter.sh` removed +8 LOC H-f scaffold gate (the `if [ ! -f ... ]; then ... fi` wrapper); restored line 130 to bare `node -e "..."` per D-044 contract. Preserved D-044 comment block as historical record.

### 3. 3-fold post-revert verification PASS
```
$ bash -n scripts/hooks/hook-firing-counter.sh
bash -n OK
$ bash scripts/hooks/hook-firing-counter.sh 2>/dev/null
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":""}}
$ bash scripts/hooks/firing-tests/hook-firing-counter-fire-test.sh
PASS [TC1] / PASS [TC1b] / PASS [TC2] / PASS [TC3] / PASS [TC4] / PASS [TC5] / PASS [TC6]
=== TOTAL: PASS=7 FAIL=0 (target: 7/7) ===
```

✓ Hook code clean; default stdout JSON emit restored; firing-test suite green.

## S199 NEXT ACTION
**PRIORITY 1**: H-g chain instrumentation. 13-instance evidence + 6 cheap-candidates REJECTED narrows cap mechanism to structural class. Approaches (cheapest-by-RISK):
- **H-g.1**: Reorder hooks in `.claude/settings.json` — swap hook #5 (hook-firing-counter) with hook #6 (effort-escalation-detector). If chain still stops at slot 5 regardless of which hook lives there → cap is POSITIONAL (slot-N max). If hook-firing-counter (now at slot 6) silent and effort-escalation (now at slot 5) fires → cap is STRUCTURAL on prior-hook output.
- **H-g.2**: Add a no-op shim hook between #5 and #6 (minimal `exit 0` script). If shim fires → cap counts non-trivial work. If shim silent → cap is purely positional.
- **H-g.3**: Wrap each hook in chain-position-capture (write to per-position log with timestamps). Surface cap mechanism empirically via timing.

H-g.1 cheapest (~3 LOC settings.json swap; immediate observation). H-g.2 next (~5 LOC new shim file + settings entry). H-g.3 most informative but expensive.

## AP-23 cheapest-by-RISK doctrine: 6-instance count VERIFIED (S188 D-044 + S190 D-046 + S192 D-047 + S196/S197 H-d.1 + S197 H-f + S198 H-f revert) — promotion candidate L-S189+-1 MUST-PROMOTE OVERDUE.

## Hard rules binding sustained (S198)
ALL prior bindings (L-S176-1 + L-S174-1 + L-S65 + Phase 3.5 §HH-G + verify_phase_before_next_phase + harness_priority_one + autonomous_continue_no_self_pause + Charter Principle 8 + cheapest-by-RISK 6-instance application). NO new binding rules.

**No git commits / 0 charter file edits / 0 constitution writes** (S198 = H-f verdict observation + marker removal + hook code revert; -8 LOC restoring pre-H-f state).

End of S198 H-f verdict. **REJECTED at 1 obs binary-decisive; marker removed; hook code reverted (3-fold post-revert verify PASS); cap mechanism narrowed to structural class — H-g.1 settings.json hook swap S199 NEXT.**
