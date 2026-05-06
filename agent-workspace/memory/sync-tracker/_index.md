# Confidence Score Index — sync-tracker

> **Auto-generated** by `scripts/hooks/sync-tracker-render.sh`. Do NOT edit by hand.
> **Last rendered**: 2026-05-05T06:35:57Z
> **Source**: D-006 (Track 8a) + Charter Principle 8 (Calibration over confidence)
> **Storage**: bash+TSV flat-file MVP per IMPL-S17-1; SQLite migration deferred Phase 1+

## Current State (5 categories)

| Category | Score | Tier | Sample Count | Last Updated | Must-Grill Remaining |
|---|---|---|---|---|---|
| LANGUAGE | 51.4 | 🟡 MED              (0.50-0.69) | 31 | 2026-05-05T15:00:00Z | 0 |
| DOMAIN_UBIQUITOUS | 56.7 | 🟡 MED              (0.50-0.69) | 32 | 2026-05-05T10:00:00Z | 0 |
| DESIGN_THINKING | 54.8 | 🟡 MED              (0.50-0.69) | 30 | 2026-05-05T13:30:00Z | 0 |
| SCOPE | 50.7 | 🟡 MED              (0.50-0.69) | 30 | 2026-05-05T12:00:00Z | 2 |
| DECISION_ROUTING | 49.5 | 🟠 MED-LOW          (0.30-0.49) | 30 | 2026-05-05T14:00:00Z | 0 |

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
| 2026-05-05T13:30:00Z | DECISION_ROUTING | charter_match | 0.2 | sync-tracker-auto | sync-tracker auto-update Stop hook ship (HH-B.5) |
| 2026-05-05T12:30:00Z | DECISION_ROUTING | charter_match | 0.2 | session-end-linter | session-end checklist linter Stop hook (HH-C.1) |
| 2026-05-05T12:35:00Z | DECISION_ROUTING | charter_match | 0.2 | project-md-staleness | project.md staleness check Stop hook (HH-C.2) |
| 2026-04-29T15:00:00Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | Q-A2-routing | drift leading indicator A=LOC ceiling routing rule |
| 2026-04-29T19:00:00Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | Q-E1 | self-detect-drift D=defense-in-depth A+B+C combined |
| 2026-04-29T19:30:00Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | Q-E2 | agent-notes promotion frequency A=phase-boundary only |
| 2026-04-29T20:00:00Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | Q-E3 | promotion target priority D=Hook FIRST → Skill → Charter |
| 2026-04-29T20:30:00Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | Q-E4 | drift recovery flow C=open Q&A bundle async |
| 2026-05-04T17:30:00Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | L-S43f-1 | bundled deny-lift cycle for sibling charter proposals |
| 2026-05-05T10:30:00Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | L-S46-2 | post-/clear TaskList loss completion-check before re-dispatch |

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
