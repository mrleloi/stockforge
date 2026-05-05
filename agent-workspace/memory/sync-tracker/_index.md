# Confidence Score Index — sync-tracker

> **Auto-generated** by `scripts/hooks/sync-tracker-render.sh`. Do NOT edit by hand.
> **Last rendered**: 2026-04-29T23:04:28Z
> **Source**: D-006 (Track 8a) + Charter Principle 8 (Calibration over confidence)
> **Storage**: bash+TSV flat-file MVP per IMPL-S17-1; SQLite migration deferred Phase 1+

## Current State (5 categories)

| Category | Score | Tier | Sample Count | Last Updated | Must-Grill Remaining |
|---|---|---|---|---|---|
| LANGUAGE | 49.7 | 🟠 MED-LOW          (0.30-0.49) | 1 | 2026-04-29T16:12:39Z | 0 |
| DOMAIN_UBIQUITOUS | 50.3 | 🟡 MED              (0.50-0.69) | 2 | 2026-04-29T22:18:14Z | 0 |
| DESIGN_THINKING | 50.5 | 🟡 MED              (0.50-0.69) | 5 | 2026-04-29T22:43:26Z | 0 |
| SCOPE | 47.8 | 🟠 MED-LOW          (0.30-0.49) | 5 | 2026-04-29T23:04:28Z | 2 |
| DECISION_ROUTING | 48.1 | 🟠 MED-LOW          (0.30-0.49) | 2 | 2026-04-29T22:18:14Z | 0 |

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
| 2026-04-29T16:12:50Z | SCOPE | decision_revocation | -3.0 | D-test-revoked | smoke 6: SCOPE revoked → must-grill=5 |
| 2026-04-29T16:37:05Z | DESIGN_THINKING | q_and_a_resolution | 0.1 |  | qa bundle answered |
| 2026-04-29T22:18:13Z | SCOPE | q_and_a_resolution | 0.1 | sync-013 | Stockforge identity confirmed-aligned at Phase 1 entry |
| 2026-04-29T22:18:14Z | DOMAIN_UBIQUITOUS | q_and_a_resolution | 0.1 | sync-015 | 9 BCs confirmed-aligned for Phase 1 monorepo skeleton |
| 2026-04-29T22:18:14Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | sync-016 | Calibration over Confidence Track 8a substrate confirmed-aligned |
| 2026-04-29T22:18:15Z | DESIGN_THINKING | q_and_a_resolution | 0.1 | sync-017 | Sandwich pattern confirmed-aligned post-S21-verifier |
| 2026-04-29T22:43:23Z | SCOPE | q_and_a_resolution | 0.1 | S24-sub-track | S24 sub-track master-plan Phase 1 thin slice picked |
| 2026-04-29T22:43:25Z | DESIGN_THINKING | q_and_a_resolution | 0.1 | Q-D1 | sessions folder flat-tree confirmed scale via grep+naming |
| 2026-04-29T22:43:26Z | DESIGN_THINKING | q_and_a_resolution | 0.1 | Q-D2 | Obsidian Karpathy raw/wiki pattern confirmed proven scale |
| 2026-04-29T23:04:28Z | SCOPE | q_and_a_resolution | 0.1 | Q-S25-1 | VHM exemplar confirmed for Phase 1 thin-slice S25-S30 |

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
