# Calibration Data

> Empirical hit-rate records. Used to ground every confidence claim (I-S7).
> Updated by `/post-mortem` and the outer-loop job.

## Files (to be populated by pipeline)

- `kol-hit-rates.jsonl` — one line per KOL+ticker+recommendation_date with outcome verdict. Used by BC-6.
- `pattern-hit-rates.jsonl` — one line per pattern match with outcome. Used by BC-9.
- `agent-perspective-hit-rates.jsonl` — how often each adversarial perspective (bull/bear/quant/critic/behavior/macro) was vindicated. Used by BC-5.
- `tier-weights.json` — current blend weights across T1/T2/T3/T4, updated by outer loop. Used by thesis grading.

## Invariants

- **Append-only** for the `.jsonl` streams (past verdicts are history).
- **Point-in-time** — every record has as-of date of the prediction AND as-of date of the outcome.
- **Sample-size gated** — confidence claims require n ≥ threshold per source (configured per source).

## Schema notes

Each `.jsonl` line is a self-contained JSON object. Keep flat. No nested calibration-of-calibration structures.

See `agent-workspace/constitution/invariants.md` §I-S7 for calibration rules and §I-S20 for KOL tracking.
