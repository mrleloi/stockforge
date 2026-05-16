# Confidence Score Index — sync-tracker

> **Auto-generated** by `scripts/hooks/sync-tracker-render.sh`. Do NOT edit by hand.
> **Last rendered**: 2026-05-16T06:16:49Z
> **Source**: D-006 (Track 8a) + Charter Principle 8 (Calibration over confidence)
> **Storage**: bash+TSV flat-file MVP per IMPL-S17-1; SQLite migration deferred Phase 1+

## Current State (5 categories)

| Category | Score | Tier | Sample Count | Last Updated | Must-Grill Remaining |
|---|---|---|---|---|---|
| LANGUAGE | 51.5 | 🟡 MED              (0.50-0.69) | 32 | 2026-05-12T14:00:03Z | 0 |
| DOMAIN_UBIQUITOUS | 56.7 | 🟡 MED              (0.50-0.69) | 32 | 2026-05-05T10:00:00Z | 0 |
| DESIGN_THINKING | 55.7 | 🟡 MED              (0.50-0.69) | 39 | 2026-05-14T07:31:23Z | 0 |
| SCOPE | 78.4 | 🟢 MED-HIGH         (0.70-0.89) | 168 | 2026-05-16T06:16:49Z | 0 |
| DECISION_ROUTING | 44.5 | 🟠 MED-LOW          (0.30-0.49) | 87 | 2026-05-15T13:20:49Z | 0 |

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
| 2026-05-16T02:02:36Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-16T02:02:38Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-16T04:09:08Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-16T04:09:10Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-16T05:40:49Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-16T05:40:51Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-16T05:40:53Z | SCOPE | charter_match | 0.2 | auto-S-adr-3 | auto-detected new ADR mtime <6h |
| 2026-05-16T06:16:45Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-16T06:16:47Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-16T06:16:49Z | SCOPE | charter_match | 0.2 | auto-S-adr-3 | auto-detected new ADR mtime <6h |

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
