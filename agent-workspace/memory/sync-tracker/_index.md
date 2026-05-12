# Confidence Score Index — sync-tracker

> **Auto-generated** by `scripts/hooks/sync-tracker-render.sh`. Do NOT edit by hand.
> **Last rendered**: 2026-05-11T13:10:36Z
> **Source**: D-006 (Track 8a) + Charter Principle 8 (Calibration over confidence)
> **Storage**: bash+TSV flat-file MVP per IMPL-S17-1; SQLite migration deferred Phase 1+

## Current State (5 categories)

| Category | Score | Tier | Sample Count | Last Updated | Must-Grill Remaining |
|---|---|---|---|---|---|
| LANGUAGE | 51.4 | 🟡 MED              (0.50-0.69) | 31 | 2026-05-05T15:00:00Z | 0 |
| DOMAIN_UBIQUITOUS | 56.7 | 🟡 MED              (0.50-0.69) | 32 | 2026-05-05T10:00:00Z | 0 |
| DESIGN_THINKING | 54.8 | 🟡 MED              (0.50-0.69) | 30 | 2026-05-05T13:30:00Z | 0 |
| SCOPE | 61.9 | 🟡 MED              (0.50-0.69) | 86 | 2026-05-10T17:03:04Z | 0 |
| DECISION_ROUTING | 48 | 🟠 MED-LOW          (0.30-0.49) | 39 | 2026-05-11T13:10:35Z | 0 |

## Decision-Class Thresholds

| Decision class | Threshold | Action when current_score < threshold |
|---|---|---|
| CHARTER | 99 | MUST grill via AskUserQuestion (charter-tier letter pick) |
| SCOPE | 90 | MUST grill via AskUserQuestion |
| ARCH | 80 | SHOULD grill; if self-decide, double-cite source_evidence |
| IMPL | 50 | OK to self-decide; subject to drift audit |

> Threshold check: `current_score >= threshold` → safe to self-decide. Below → grill.

## Recent Events (top 10 newest)

| ts | category | event_type | delta | decision_id | reason |
|---|---|---|---|---|---|
| 2026-05-10T15:00:51Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-10T15:00:52Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-10T15:00:53Z | DECISION_ROUTING | drift_signal | -0.3 | auto-S-drift | auto-detected 1672 HIGH-drift events today |
| 2026-05-10T16:00:11Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-10T16:00:12Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-10T16:00:13Z | DECISION_ROUTING | drift_signal | -0.3 | auto-S-drift | auto-detected 1763 HIGH-drift events today |
| 2026-05-10T17:03:03Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-10T17:03:04Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-10T17:03:05Z | DECISION_ROUTING | drift_signal | -0.3 | auto-S-drift | auto-detected 1956 HIGH-drift events today |
| 2026-05-11T13:10:35Z | DECISION_ROUTING | drift_signal | -0.3 | auto-S-drift | auto-detected 6 HIGH-drift events today |

## How to use

- **Before SCOPE+ decision**: invoke `sync-pull` skill OR check this file's category row.
- **If category score below decision-class threshold**: MUST grill (AskUserQuestion).
- **If `Must-Grill Remaining` > 0**: forced grill regardless of score (reversal protocol per Q&A A6).
- **Weights tunable**: edit `weights.yaml`; re-run `sync-tracker-update.sh` with any event to recompute.

## Source schema

- Categories (5): LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING
- Tier boundaries: see `weights.yaml` (`tier_*` keys)
- Asymmetric weights: see `weights.yaml` (`weight_*` keys; positive = earned confidence; negative = correction debt)

See `README.md` for full schema; `D-006` for design rationale.
