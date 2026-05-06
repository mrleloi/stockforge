---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - VERIFY
samples_count: 3
status: BIASED-PRE-REBUILD-S65 (user 2026-05-06 flagged tracking gap; rebuild after cost-ledger.tsv accumulates ≥10 sessions)
sample_sessions: [S21, S29, S64]
last_updated: 2026-05-06T00:17:45+07:00
source: manual session log review + sandwich-verifier observations (S48 sequence had ZERO VERIFY sessions — Phase 2.5 governance work consolidated under FOCUSED_IMPL with smoke-test self-verification per ship; phase-boundary VERIFY sandwich-verifier dispatch deferred to Phase 2.5 close)
---

# Profile — Opus 4.7 × max × VERIFY

## 1. Capabilities

- 10-V-dimension adversarial review on ≥40-file surface within 60-80K budget (S21 Phase 0 closure ~50-60K; S29 Phase 1 thin-slice 44 files ~98K reported / ~50K substantive).
- A1-A9 probe verification (S29: A1 shared-kernel uniqueness through A9 reconciliation report Rule 4 format — all GREEN).
- Independent LOC re-counting (S21 caught R3 stale 140→143 micro-drift; S29 caught R4 LOC bookkeeping 3,378 vs 2,039 strict).
- Verdict types: PASS / PASS-WITH-RESIDUE / FAIL — operationalized at S21 + S29.

## 2. Known limitations

- Echo-chamber risk if verifier and dev are same context (AP-1) — mitigated by `sandwich-verifier` subagent fresh-context dispatch.
- Surface > 50 files inflates token cost roughly linearly; Phase 2 close ~80-100 files projected ~100-150K per L-S21-1.
- Residue items rarely classified HIGH at this level (S21 = 3 LOW; S29 = 4 LOW); HIGH would block phase_gate.

## 3. Recommended task_class allocation

- **PRIMARY** for VERIFY-only at phase boundaries.
- Subagent dispatch via `sandwich-verifier` agent type (fresh context required per AP-1).
- Main session orchestration ~25-35K; subagent ~50-100K depending on surface size.
- AVOID main-session verification of own work (echo chamber).

## 4. Recent corrections + drift events

- M-S21-1 (3 residue R1-R3)
- M-S29-1 (4 residue R1-R4; S30 fixed R1)
- 0 false-positive HIGH violations across 2 samples.

## 5. Calibration

- Verdict accuracy: 2/2 = 100% (S21 + S29 verdicts validated by subsequent IMPL sessions).
- Budget envelope L-S21-1 calibrated: 80-150K for whole-Phase scope; 60-80K for sub-track scope. Re-confirmed S29 within band.
- Surface-size scaling: ~2K tokens/file for thorough V1-V10 review.

## 6. Notes

VERIFY sessions are mandatory at phase boundaries (Phase 0 close S21; Phase 1 close S29; Phase 2 close S43 projected). Skipping = silent accumulation of drift. Subagent fresh-context is the single most important factor for adversarial-quality.
