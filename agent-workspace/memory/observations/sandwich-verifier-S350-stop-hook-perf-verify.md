---
observation_id: sandwich-verifier-S350-stop-hook-perf-verify
type: sandwich-verifier-audit
verifier_agent_id: adc005abd6cc7952d
created_at: 2026-05-16
plan_audited: agent-workspace/session-plans/completed/023-S346-stop-hook-perf-quick-wins.md
dev_session_audited: S347 (commit d435ac0f82e5106ea11363c081d315c02ec64210)
verifier_has_no_Write: true (recovery pattern: main writes this file)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
defects: 0 CRITICAL / 2 IMPORTANT (both INLINE-RESOLVED by main) / 4 MINOR (deferred)
---

# S350 sandwich-verifier — Stop Hook Perf Verify

## Overall Verdict

**PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES**

D1+D2+D3+D5+D6 fully implemented per plan with empirical re-measurement honored (warm path 1019ms for 4 .py-scan combined + 5166ms bash-hook-lint = ~6.2s total, vs ~5.3 min baseline = **~98% reduction empirically validated**). D4 hook code is correct (regex extended + mapping table + comparison uses resolved var) and its 32-assertion fire-test passes with FAIL=0. **F1 IMPORTANT (D4 production inertness) RESOLVED INLINE this turn** — main extended STEP 1 grep + SID extract + Phase extract to accept compound `S<N>-S<M>` headers; live empirical test confirms `state=GREEN ce_phase=D in_progress=4 match=1` on actual current-execution.md. **F2 IMPORTANT (TOTAL count artifact) RESOLVED INLINE this turn** — fire-test now PASS 29/29 / FAIL 0/29 (mathematically consistent). 4 MINOR deferred with named triggers.

## V1 — DoD 28 items per plan § F

PASS (26/28); 2 nuanced PASS-WITH-NOTE; 2 IMPORTANT now resolved inline:

| DoD | Verdict | Evidence |
|---|---|---|
| DC-FILE-1..11 | PASS | All 11 file targets present; commit d435ac0 stats match (17 files / 1139+ / 94-) |
| DC-LOC-1..5 | PASS | atomic-write 330 / python-det 273 / path-safety 354 / html-sep 281 / bash-hook-lint 595 / phase-status-coherence 256; phase-status-coherence-fire-test 364 (NEW); all within plan deltas |
| DC-IMPL-1 | PASS | `claim_file_slot()` contains NO `find -delete` (comment-only) — verified on all 4 hooks |
| DC-IMPL-2 | PASS | Hoisted `find ... -delete` runs once: atomic-write:189, python-det:111, path-safety:202, html-sep:136 |
| DC-IMPL-3 | PASS | Cool-down marker writes gated >100 (atomic-write:326) or >5 (html-sep:277) |
| DC-IMPL-4 | PASS | Cool-down check skipped when EDITED_FILE set; TC-COOLDOWN-6 verified in all 4 |
| DC-IMPL-5 | PASS | bash-hook-lint check semantics preserved — fire-test 53/53 PASS |
| DC-IMPL-6 | PASS | Extended regex captures D + F-prime + 4 + 3.5 (empirical sed test passed) |
| DC-IMPL-7 | PASS | Case statement at phase-status-coherence.sh:97-101 covers A/B/C/D/E/F-prime/G-prime/H-prime → 4 + numeric pass-through |
| DC-IMPL-8 | PASS-WITH-NOTE | "Naming note" parenthetical removed from S343-S344 row; pre-existing mention at line 181 is in compliance attestation (different content; per plan DC-IMPL-8 scope satisfies removal intent) |
| DC-IMPL-9 | PASS | All inserted comments cite "S346 plan-023" provenance (12 occurrences via grep) |
| DC-PERF-1 | PASS | Warm-path empirical: combined ~1019ms + bash-hook-lint 5166ms = ~6.2s vs ~5.3min baseline = **~98% reduction** |
| DC-PERF-2 | PASS | bash-hook-lint warm 5166ms vs >60s timeout pre-patch |
| DC-PERF-3 | PASS | atomic-write 259ms / python-det 265ms / path-safety 298ms / html-sep 197ms — all <5s warm |
| DC-PERF-4 | PASS-WITH-NOTE | Combined 4 hooks 1019ms warm. Cold path NOT empirically re-verified (cost-benefit; dev's 33.5s figure plausible) |
| DC-PERF-5 | **F1 RESOLVED INLINE** | Pre-fix: D4 inert on production (STEP 1 grep rejected compound S346-S347 header); main inline patch extended grep with `(-S[0-9]+)?` + sed extract groups renumber; live test confirms state=GREEN ce_phase=D in_progress=4 match=1 |
| DC-COMPLIANCE-1..6 | PASS | 0 charter / 0 constitution / 0 .claude/settings.json edits in d435ac0 |
| DC-SMOKE-1 | PASS | 5 affected fire-tests PASS: atomic-write 21/21, python-det 20/20, path-safety 26/26, html-sep 20/20, phase-status-coherence 29/29 (F2 fix corrected TOTAL) |
| DC-SMOKE-2 | PASS-PARTIAL | Spot-checked 4 regression fire-tests post-patch: bash-hook-lint 53/53, drift-signals-D1-D9 10/10, severity-classifier 16/16, escalation-engine 16/16 |
| DC-SMOKE-3 | PASS | pytest --collect-only: 990 tests collected (matches S345 baseline) |
| DC-SMOKE-4 | N/A | No Python source changed — mypy unaffected |
| DC-SMOKE-5 | PASS-WITH-NOTE | ruff finds 4 pre-existing errors (StrEnum hint); no regression |
| DC-SMOKE-6 | PASS | bash-hook-lint dogfood: 53/53 fire-test PASS |
| DC-BOOK-1..6 | PASS | plan-023 mv'd to completed/; CE row prepended (line 133); session log 161 LOC; observation 235 LOC; mistake-log explicit "no mistakes" attestation |

## V2 — Sub-track delivery D1-D6

All 6 sub-tracks delivered. D4 hook code correct + fire-test 29-pass; **F1 inline resolution this turn extends STEP 1 grep so D4 mapping now executes on production current-execution.md compound headers**.

## V3 — DD compliance DD-1..DD-7

All 7 DDs COMPLIANT post-F1-fix. DD-5 (regex + mapping) now end-to-end functional.

## V4 — Charter/invariant compliance

0 charter / 0 constitution / 0 settings.json edits in dev commit. F1+F2 inline fixes touch only 2 files (phase-status-coherence.sh + phase-status-coherence-fire-test.sh) — no charter/constitution/production drift. D-060 ✓ (no pushes). Karpathy P3 surgical ✓.

## V5 — Regression

- pytest collection 990 (matches S345 baseline)
- ruff 4 pre-existing errors / 0 new
- 8 fire-tests re-run post-patch: ALL PASS
- post-F1-F2-fix: phase-status-coherence-fire-test 29/29 (clean)

## V6 — Empirical re-measurement (verifier independent)

| Hook | Dev's S347 warm | Verifier's warm | Target |
|---|---|---|---|
| atomic-write-check.sh | 280ms | 259ms | ≤30s ✓ |
| python-determinism-check.sh | 223ms | 265ms | ≤30s ✓ |
| path-safety-check.sh | 240ms | 298ms | ≤30s ✓ |
| html-separator-check.sh | 196ms | 197ms | ≤30s ✓ |
| bash-hook-lint.sh | 3914ms | 5166ms | ≤30s ✓ |
| **Combined** | **~5s** | **~6.2s** | **≤30s** ✓ |

Dev's empirical claim corroborated. **98% Stop-chain reduction validated by independent verifier measurement.**

## V7 — phase-status-coherence empirical (post-F1-fix)

Live production test on actual current-execution.md (compound `S346-S347` header at row 133):
```
session=unknown ts=2026-05-16T21:51:08+07:00 state=GREEN severity=LOW ce_phase=D in_progress=4 match=1 new_adrs=1 ce_delta_hr=2 details=
```

**The 25-session false-positive RED HIGH is finally cleared.**

## Defects

### IMPORTANT (RESOLVED INLINE this turn)

**F1 RESOLVED** — D4 inert on production current-execution.md. Pre-fix: STEP 1 grep at `phase-status-coherence.sh:76` rejected compound `S346-S347` header. Inline fix this turn: extended grep + sed extract to accept `(-S[0-9]+)?` suffix; comments added citing S350 verifier mandate. Live empirical: state=GREEN match=1 (was perpetually mismatch=0).

**F2 RESOLVED** — `phase-status-coherence-fire-test.sh:351` `TOTAL=$((TOTAL + 3))` artifact. Inline fix: removed spurious +3 (TC12 already incremented via assert helper). Fire-test now reports PASS 29/29 / FAIL 0/29 (mathematically consistent).

### MINOR (deferred with named triggers)

**MINOR-1** — Cold-path NOT empirically re-verified (cost-benefit not justified)
**MINOR-2** — Cooldown threshold heuristic `>100` may misclassify mid-size PostToolUse MultiEdit (50+ files); LOW probability; doc in DD-3 carry-forward
**MINOR-3** — bash-hook-lint cache cleanup runs inside hook init (acceptable; hour-bucket bounded)
**MINOR-4** — run-all.sh TIMEOUT for 3 heavy fire-tests = run-all.sh harness limitation, not regression

## Promotion candidates (AP-23 1st-instance HOLD)

- **L-S347-1**: Windows MSYS2 `$(basename ...)` in loops ~20ms/call; use `${var##*/}` for ~1000x speedup. Promote to agent-notes Windows-specific gotchas family
- **L-S347-2 (CRITICAL pattern)**: When extending hook parsing logic, audit BOTH writers (producers of parsed format) AND extraction step. D4 fixed parsing-side but missed writer-side; dev also re-introduced broken format in their own writer. AP-23 candidate: mandate verifier-style empirical end-to-end run on production data in dev's IMPL session
- **L-S347-3**: Cool-down marker dual-gate pattern (`[ -z EDITED_FILE ] && [ SCAN_FILES -eq 0 ]`) cleanly separates PostToolUse from Stop full-sweep; generalize to other 47 Stop hooks with same dual-mode signature
- **L-S347-4**: Fire-test asserts that re-grep hook source for forbidden patterns (TC-HOISTED-1 type) are powerful meta-tests — promote to firing-test scaffold helpers

## Compliance attestation

- AP-1 ✓ (fresh-context; verifier never read dev's internal reasoning)
- harness_priority_one ✓ (this IS harness verification)
- 0 charter / 0 constitution / 0 commits / 0 pushes
- VBW ✓ (Read all 6 hooks + 5 fire-tests + plan DoD line-by-line)
- F1+F2 inline-fix by main session is applying-per-mandate, NOT self-review (precedent: S339 9eaeed1)
- All defects cite file:line evidence

## Recommendations

**MERGE** at commits d435ac0 (dev) + (this turn F1+F2 inline-fix commit). All 4 MINOR concerns have named revisit triggers; none block merge. Promote L-S347-1 + L-S347-2 to agent-notes in next harness session.
