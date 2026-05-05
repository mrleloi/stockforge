---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL
samples_count: 5
sample_sessions: [S26, S28, S30, S32, S35]
last_updated: 2026-05-01T00:00:00Z
source: manual session log review
---

# Profile — Opus 4.7 × max × FOCUSED_IMPL

## 1. Capabilities

- 1-3 task focus within 100-150K budget envelope (S26 VN-domain proposals; S28 Tier 1 ingestion adapter; S30 Phase 1 closure; S32 Track A R2 closure; S35 meta-loop recovery).
- Cosmetic cleanup + refactor + deferred-residue resolution single-pass.
- Live-smoke + reconciliation discipline (S28 248 VHM bars; S32 248 vnstock + 248 SSI = 496 rows reconciled; S30 VHM exemplar thesis with 15 deterministic SQL queries).
- IMPL-tier decision file authoring per L-S15-1 inline doctrine when needed (D-006, D-007, D-008, D-012).

## 2. Known limitations

- Subagent overrun risk when nested under FOCUSED_IMPL — S25 architect subagent ~220K vs 150-180K envelope (M-S25-1; L-S25-1 calibrated).
- Self-track closer to budget ceiling than MULTI_TASK_IMPL (S20 292K; S35 ~ pending close).
- DR-DEFER soft-flagged residue tends to accumulate; 5 lessons batched without promotion across S25-S30.

## 3. Recommended task_class allocation

- **PRIMARY** for FOCUSED_IMPL 1-3 tasks at 100-150K — explicit single-track scope.
- ALSO for short META_LOOP_RECOVERY (S35 type) when cleanup spans multiple deterministic edits + 2 subagent dispatches.
- AVOID for >3-track wiring → upgrade to MULTI_TASK_IMPL.

## 4. Recent corrections + drift events

- M-S25-1 subagent budget overrun
- M-S28-1 vendor-API drift
- M-S29-1 verifier residue R1-R4 (S30 fixed R1)
- M-S31-1 master-plan LOC over advisory cap
- M-S35-1..5 cognitive failures (this session = recovery)

## 5. Calibration

- Budget actual: S26 ~? / S28 ~110-140K / S30 ~85-110K / S32 ~80-110K (all favorable); S20 ~292K (over).
- Hit rate: 5/5 deliverables shipped; 100% test-PASS (0 regressions).
- Decision-file LOC adherence: D-012 +46% over advisory; D-007 +? — IMPL-tier doc-density bias accepted.

## 6. Notes

S35 is a META_LOOP_RECOVERY variant of FOCUSED_IMPL — added to test if recovery sessions need a separate type or fit under FOCUSED_IMPL. Recommend keeping under FOCUSED_IMPL with `META_LOOP_RECOVERY` tag.
