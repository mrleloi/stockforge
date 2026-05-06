---
model: claude-haiku-4-5-20251001
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL (PROBE — prefilter mode)
samples_count: 1
sample_sessions: [S47]
last_updated: 2026-05-05T13:30:00+07:00
source: S48i HH-F.1 ETL bootstrap from S47 Track-H probe results (data/track-H-probe/probe-matrix.json)
status: BIASED-PRE-REBUILD-S65 (was DRAFT-INSUFFICIENT-SAMPLES; user 2026-05-06 flagged tracking gap → mark biased; rebuild after cost-ledger.tsv accumulates ≥10 haiku samples)
---

# Profile — Haiku 4.5 × max × FOCUSED_IMPL (probe — prefilter strategy)

## 1. Capabilities

- **Track-H S3 strategy WINNER** at S47 (10 Vietnamese KOL fixtures): Haiku-4-5 prefilter + Sonnet-4-6 extract pipeline:
  - precision = 1.0
  - recall = 0.889
  - cost ~$0.27/run (full pipeline including Sonnet-4-6 extract step)
- Cost-efficiency vs full-Sonnet single-pass: significant savings on prefilter step (fast classification of which KOL transcripts are worth extracting from).
- Vietnamese-text classification competence on 10-fixture sample (insufficient for population claim but provisional positive signal).

## 2. Known limitations

- **N=1 sample**: S47 Track-H probe is single dispatch; no generalization beyond Track-H KOL prefilter scope.
- **Vendor surface drift risk**: S47 IMPL-S47-5 found claude-haiku-3-5 not available (HTTP 404 between PLAN time and IMPL time → 6h apart); claude-haiku-4-5 substituted. Future Haiku model deprecations may invalidate this card without notice.
- **Reasoning-heavy task NOT validated**: card scope is prefilter classification; Haiku NOT tested on multi-step reasoning, charter ratification, or thesis synthesis.

## 3. Recommended task_class allocation

- **PRIMARY** for prefilter / classification stages of LLM pipelines where precision/recall tradeoff is acceptable.
- ROUTE to Haiku via per-role override (BP-S43b-1 prose-tolerant pattern) when input-volume is high + per-call cost matters.
- AVOID for substrate authoring, charter amendments, ADR provenance — Opus 4.7 strictly preferred for SCOPE/CHARTER work per Charter Principle 9 (No LLM math) — Haiku output structure is too thin for 12-field ADR schema.
- AVOID for verification work (sandwich-verifier) — fresh-context Opus required per AP-1.

## 4. Recent corrections + drift events

- IMPL-S47-5 vendor drift (haiku-3-5 → haiku-4-5 substitution via _HAIKU_MODEL constant in claude_llm_perspective_adapter.py).
- D-026 LLM Substrate Boundary BP-S43b-1 per-role override applied — Haiku used as prefilter only, not as authority for any decision.

## 5. Calibration

- Track-H probe S47 result: precision=1.0 (10/10 correct positives) / recall=0.889 (8/9 true positives caught) / F1=0.941. Sample size N=10 Vietnamese KOL fixtures.
- Cost calibration: ~$0.027/fixture (Haiku prefilter only) vs Sonnet-4-6 full pipeline ~$0.16/fixture. ~6x cheaper per call but only on classification step.
- **DO NOT generalize**: 1-session probe is research signal, not statistical hit-rate.

## 6. Notes

Haiku 4.5 is a NEW model substrate as of S47 (released ~2025-10-01 per training cutoff). Sample data is exploratory. Future accumulation expected:
- S49+ Track I (Bayesian calibration) — could use Haiku for outcome-classification preprocessing.
- S52 LLM extraction proper IMPL — will accumulate samples on prefilter accuracy across multiple KOL channels.
- Phase 4 outer-loop dogfood — long-term hit rate measurement.

Promotion to STABLE pending: 2 more dispatches (≥3 total) AND aggregate precision/recall across diverse fixture sets (not just S47 KOL Vietnamese).
