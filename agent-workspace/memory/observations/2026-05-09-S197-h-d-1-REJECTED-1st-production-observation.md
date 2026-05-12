# S197 — D-047 H-d.1 1st Production Observation: REJECTED at 1 obs (cap is NOT settings.json registration / completion-count)

**Date**: 2026-05-09
**Trigger**: User /clear + trivial-prompt "continue" at 2026-05-09T10:16:56-58+07:00
**Session**: S197 (VERIFY+IMPL hybrid; H-d.1 verdict + settings.json revert)
**Predecessor**: S196 — D-047 H-d.1 destructive scaffold deployed (settings.json hook #5 entry surgically removed)
**Hypothesis**: H-d.1 = chain executor caps at *completion-count* (i.e., counts each registered hook entry, advancing the cap regardless of whether emit fires). If H-d.1 TRUE, removing hook #5 entry from settings.json should free a slot for ≥1 of #6/#7/#8/#9 to execute.

## Empirical Evidence (5-fold)

### 1. Settings.json revert backup confirmed (S196 pre-state)
- Hook #5 entry removed from `.claude/settings.json` UserPromptSubmit array at S196 (verbatim recorded in S196 checkpoint).
- 4-fold S196 verification: JSON parse OK + grep hook-firing-counter 0 matches + UserPromptSubmit hook count 9→8 + S196 entry baseline confirmed S195 marker-deactivation worked.

### 2. UserPromptSubmit hook chain executed at S197 trigger (10:16:58)
From `agent-workspace/memory/.session-hooks.log`:
```
[2026-05-09T10:16:58+07:00] UserPromptSubmit-injector: SKIP (trivial prompt detected)
```
- Hook #1 (userprompt-invariants-injector) FIRED → `SKIP (trivial prompt detected)` ✓
- Hooks #2/#3 silent-as-designed (only fire on non-trivial prompts; per S193+S194+S195+S196 baseline)

### 3. Hook #4 fired (in-flight-subagent-watcher)
```
[2026-05-09T10:16:58+07:00] in-flight-subagent-watcher: clean (0 stale pending dispatch)
```
Mtime `.in-flight-subagent-watcher.log` = 10:16:58 (BUMPED from 10:10:43) ✓

### 4. Hook #5 absent-by-design (settings.json removed)
- `.hook-firing-counter.log` mtime = 10:10 (S196 timestamp; UNCHANGED at 10:17 inspection)
- `.hook-firing-counter-stderr.log` mtime = 10:10 (UNCHANGED) ✓
- Confirms hook #5 entry-removal worked (no fire path in chain).

### 5. Hooks #6/#7/#8/#9 STILL ALL SILENT — H-d.1 REJECTING SIGNAL
| # | Hook | Log file | Expected if H-d.1 CONFIRMED | Observed | Verdict |
|---|---|---|---|---|---|
| 6 | effort-escalation-detector | `.effort-escalation.log` | CREATED with current SID | **MISSING** | SILENT |
| 7 | idle-escape-detector | `.idle-escape.log` | CREATED with current SID | **MISSING** | SILENT |
| 8 | phase-status-coherence | `.phase-coherence.log` | CREATED with current SID | **MISSING** | SILENT |
| 9 | harness-health-self-scan | `.harness-health.log` | APPEND with current SID | mtime 09:43:23 firing-test-smoke-8584 SID UNCHANGED | SILENT |

All 4 logs: SAME state as S196 entry baseline (no real-production trigger emit despite hook #5 entry physically excised from settings.json).

## Verdict: H-d.1 REJECTED at 1 obs

**Diagnostic logic binary-decisive**: H-d.1 = "chain executor caps at completion-count, counting registered entries" → physically removing hook #5 entry should free 1 slot. Observed: removing hook #5 entry did NOT advance chain to any of #6-#9. **Completion-count is NOT the cap mechanism.**

**12-instance evidence baseline**: S187..S196 11-instance reproduction (chain truncates at #5/#6 boundary across 4 distinct hook #5 emit-states + 3 distinct trigger types) + S197 1-instance with hook #5 ABSENT-FROM-SETTINGS = 12-instance binary-decisive evidence.

**Hypothesis stack post-S197**:
- H-c REJECTED (S189 D-044) — fail-fast set -e
- H-a REJECTED-FORMAL (S191 D-046) — stdout JSON contamination via stderr fix
- H-e REJECTED-BY-INSPECTION (S191) — Stop event ≠ chain mid-fire
- H-d.2 REJECTED-FORMAL (S195 D-047) — emit-count-cap via marker-file silent
- **H-d.1 REJECTED at 1 obs (S197)** — registration-count / completion-count cap

**Live candidates cheapest-by-RISK** (next at S198):
- **H-f** (~3 LOC remove node JSON emit at `scripts/hooks/hook-firing-counter.sh` line 120; would re-add hook #5 with stdout JSON disabled — distinct from H-a stderr-redirect because deletes the emit entirely vs redirects)
- **H-g** (~10-15 LOC restructure; full hook chain instrumentation)

## D-047 H-d.1 status transition
`SCAFFOLD-DEPLOYED-PENDING-PRODUCTION-OBSERVATION` → **`SHIPPED-1ST-PRODUCTION-OBSERVATION-REJECTED-1-OF-1-BINARY-DECISIVE`**

Single observation sufficient for verdict because:
1. Hypothesis is binary (registration-count cap exists OR not).
2. 12-instance baseline + 1 differential = decisive signal (vs H-a/H-d.2 3-observation precedent which involved emit-state ambiguity — here no ambiguity since registration is deterministic settings.json state).

## Settings.json revert executed (S197 IMPL)

1. **Edit** `.claude/settings.json` — re-inserted hook #5 entry block between hook #4 (in-flight-subagent-watcher) and hook #6 (effort-escalation-detector).
2. **Verify**: `python -m json.tool` parse OK ✓; `grep hook-firing-counter` → 1 match ✓; UserPromptSubmit hook count 8→9 ✓; hook ordering #1..#9 confirmed ✓.

Hook #5 RESTORED to operational state. Silent-hook detection signal re-armed. No other settings.json changes.

## AP-23 cheapest-by-RISK doctrine: 4-instance application VERIFIED

S192 D-047 marker scaffold (cheapest non-destructive variant) → S196 D-047 H-d.1 settings.json edit (destructive but reversible — backup + revert protocol) → S197 H-d.1 verdict + revert. 4-instance count NOW ratified across S188 D-044 + S190 D-046 + S192 D-047 + S196/S197 H-d.1 destructive cycle. Promotion candidate L-S189+-1 OVERDUE for promote-rule cycle at S198+.

## S198 NEXT ACTION
**PRIORITY 1**: H-f hypothesis — remove node JSON emit at `scripts/hooks/hook-firing-counter.sh` line 120 (~3 LOC) + 1 obs cycle. Distinct from H-a (D-046) which redirected stderr; H-f deletes the emit line entirely. If H-f also REJECTED → H-g (chain-restructure) at S199.

## Files this observation
- NEW `agent-workspace/memory/observations/2026-05-09-S197-h-d-1-REJECTED-1st-production-observation.md` (this file)
- EDITED `.claude/settings.json` (hook #5 entry restored; revert verified 3-fold)

## Hard rules binding sustained (S197)
ALL prior bindings (L-S176-1 + L-S174-1 + L-S65 + Phase 3.5 §HH-G + verify_phase_before_next_phase + harness_priority_one + autonomous_continue_no_self_pause + Charter Principle 8 + cheapest-by-RISK 4th-instance application). NO new binding rules.

**No git commits / 0 charter file edits / 0 constitution file writes / 0 hook code edits** (S197 = settings.json revert + verdict observation only).

End of S197 H-d.1 verdict observation. **REJECTED at 1 obs binary-decisive; settings.json reverted to 9-hook UserPromptSubmit chain; H-f next at S198.**
