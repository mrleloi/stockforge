# Confidence Score Index — sync-tracker

> **Auto-generated** by `scripts/hooks/sync-tracker-render.sh`. Do NOT edit by hand.
> **Last rendered**: 2026-05-14T03:08:35Z
> **Source**: D-006 (Track 8a) + Charter Principle 8 (Calibration over confidence)
> **Storage**: bash+TSV flat-file MVP per IMPL-S17-1; SQLite migration deferred Phase 1+

## Current State (5 categories)

| Category | Score | Tier | Sample Count | Last Updated | Must-Grill Remaining |
|---|---|---|---|---|---|
| LANGUAGE | 51.5 | 🟡 MED              (0.50-0.69) | 32 | 2026-05-12T14:00:03Z | 0 |
| DOMAIN_UBIQUITOUS | 56.7 | 🟡 MED              (0.50-0.69) | 32 | 2026-05-05T10:00:00Z | 0 |
| DESIGN_THINKING | 54.9 | 🟡 MED              (0.50-0.69) | 31 | 2026-05-13T07:39:30Z | 0 |
| SCOPE | 67.6 | 🟡 MED              (0.50-0.69) | 114 | 2026-05-14T03:08:33Z | 0 |
| DECISION_ROUTING | 49.5 | 🟠 MED-LOW          (0.30-0.49) | 53 | 2026-05-14T03:08:34Z | 0 |

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
| 2026-05-14T00:18:56Z | SCOPE | charter_match | 0.2 | sync-grilling-S291 | S291 sync-grilling refresher (auto-tier; no AskUserQuestion fired; 3-session cadence DUE S288→S291; 12th in lineage S257/S260/S263/S266/S270/S273/S276/S279/S282/S285/S288/S291). Zero new SCOPE-tier divergence outside pending Q-INT mega-bundle (14262B sustained user-blocked since 2026-05-13T16:47Z); anti-mixing rule honored. Identity sync-007/008/013 + BC sync-015 + self-use sync-014 + UP-06 sync-008 all sustained from S257 re-stamp. Intervening session S289 (idle) + S290 (HARNESS-FIX TOCTOU rate-limit per harness_priority_one) added zero SCOPE-tier signals. D-055 cool-down ~14h27m remaining at S291 entry. |
| 2026-05-14T00:37:53Z | SCOPE | charter_match | 0.2 | sync-grilling-S294 | S294 sync-grilling refresher (auto-tier; no AskUserQuestion fired; 3-session cadence DUE S291→S294; 13th in lineage S257/S260/S263/S266/S270/S273/S276/S279/S282/S285/S288/S291/S294). Zero new SCOPE-tier divergence outside pending Q-INT mega-bundle (14262B sustained user-blocked since 2026-05-13T16:47Z); anti-mixing rule honored. Identity sync-007/008/013 + BC sync-015 + self-use sync-014 + UP-06 sync-008 all sustained from S257 re-stamp. Intervening sessions S292 (idle 13th-cluster) + S293 (idle 14th-cluster) added zero SCOPE-tier signals. HH-H.4 self-resolving classification VALIDATED 3rd-cycle (S292+S293+S294 marker-absence stable) — promotion-eligibility OPENS per AP-23; downgrade-execution still DEFERRED. D-055 cool-down ~14h08m remaining at S294 entry. |
| 2026-05-14T00:53:58Z | SCOPE | charter_match | 0.2 | sync-grilling-S297 | S297 sync-grilling refresher (auto-tier; no AskUserQuestion fired; 3-session cadence DUE S294→S297; 14th in lineage S257/S260/S263/S266/S270/S273/S276/S279/S282/S285/S288/S291/S294/S297). Zero new SCOPE-tier divergence outside pending Q-INT mega-bundle (14262B sustained user-blocked since 2026-05-13T16:47Z); anti-mixing rule honored. Identity sync-007/008/013 + BC sync-015 + self-use sync-014 + UP-06 sync-008 all sustained from S257 re-stamp. Intervening sessions S295 (idle 15th-cluster) + S296 (idle 16th-cluster) added zero SCOPE-tier signals. HH-H.4 self-resolving classification VALIDATED 5th-cycle (S292+S293+S294+S295+S296 marker-absence stable; firmly entrenched well beyond AP-23 3rd-cycle promotion-eligibility threshold); downgrade-execution still DEFERRED to consolidated promote-rule cycle. D-055 cool-down ~13h52m remaining at S297 entry. |
| 2026-05-14T01:08:56Z | SCOPE | charter_match | 0.2 | sync-grilling-S300 | S300 sync-grilling refresher (auto-tier; no AskUserQuestion fired; 3-session cadence DUE S297→S300; 15th in lineage S257/S260/S263/S266/S270/S273/S276/S279/S282/S285/S288/S291/S294/S297/S300; milestone 300th session). Zero new SCOPE-tier divergence outside pending Q-INT mega-bundle (14262B sustained user-blocked since 2026-05-13T16:47Z); anti-mixing rule honored. Identity sync-007/008/013 + BC sync-015 + self-use sync-014 + UP-06 sync-008 all sustained from S257 re-stamp. Intervening sessions S298 (idle 17th-cluster) + S299 (idle 18th-cluster) added zero SCOPE-tier signals. HH-H.4 self-resolving classification VALIDATED 8th-cycle (S292-S299 marker-absence stable; firmly entrenched well beyond AP-23 3rd-cycle promotion-eligibility threshold); downgrade-execution still DEFERRED to consolidated promote-rule cycle. D-055 cool-down ~13h37m remaining at S300 entry. |
| 2026-05-14T01:25:38Z | SCOPE | charter_match | 0.2 | sync-grilling-S303 | S303 sync-grilling refresher (auto-tier; no AskUserQuestion fired; 3-session cadence DUE S300→S303; 16th in lineage S257/S260/S263/S266/S270/S273/S276/S279/S282/S285/S288/S291/S294/S297/S300/S303). Zero new SCOPE-tier divergence outside pending Q-INT mega-bundle (14262B sustained user-blocked since 2026-05-13T16:47Z); anti-mixing rule honored. Identity sync-007/008/013 + BC sync-015 + self-use sync-014 + UP-06 sync-008 all sustained from S257 re-stamp. Intervening sessions S301 (idle 19th-cluster post-S300 milestone) + S302 (idle 20th-cluster) added zero SCOPE-tier signals. HH-H.4 self-resolving classification VALIDATED 12th-cycle (S292-S302 marker-absence stable; firmly entrenched well beyond AP-23 3rd-cycle promotion-eligibility threshold); downgrade-execution still DEFERRED to consolidated promote-rule cycle. D-055 cool-down ~13h20m remaining at S303 entry. |
| 2026-05-14T01:38:09Z | SCOPE | charter_match | 0.2 | sync-grilling-S306 | S306 sync-grilling refresher (auto-tier; no AskUserQuestion fired; 3-session cadence DUE S303→S306; 17th in lineage S257/S260/S263/S266/S270/S273/S276/S279/S282/S285/S288/S291/S294/S297/S300/S303/S306). Zero new SCOPE-tier divergence outside pending Q-INT mega-bundle (14262B sustained user-blocked since 2026-05-13T16:47Z); anti-mixing rule honored. Identity sync-007/008/013 + BC sync-015 + self-use sync-014 + UP-06 sync-008 all sustained from S257 re-stamp. Intervening sessions S304 (idle 21st-cluster) + S305 (idle 22nd-cluster) added zero SCOPE-tier signals. HH-H.4 self-resolving classification VALIDATED 15th-cycle (S292-S305 marker-absence stable; firmly entrenched well beyond AP-23 3rd-cycle promotion-eligibility threshold); downgrade-execution still DEFERRED to consolidated promote-rule cycle. D-055 cool-down ~13h07m remaining at S306 entry. |
| 2026-05-14T01:50:31Z | SCOPE | charter_match | 0.2 | sync-grilling-S309 | S309 sync-grilling refresher (auto-tier; no AskUserQuestion fired; 3-session cadence DUE S306→S309; 18th in lineage S257/S260/S263/S266/S270/S273/S276/S279/S282/S285/S288/S291/S294/S297/S300/S303/S306/S309). Zero new SCOPE-tier divergence outside pending Q-INT mega-bundle (14262B sustained user-blocked since 2026-05-13T16:47Z); anti-mixing rule honored. Identity sync-007/008/013 + BC sync-015 + self-use sync-014 + UP-06 sync-008 all sustained from S257 re-stamp. Intervening sessions S307 (idle 23rd-cluster) + S308 (idle 24th-cluster) added zero SCOPE-tier signals. HH-H.4 self-resolving classification VALIDATED 18th-cycle (S292-S308 marker-absence stable; firmly entrenched well beyond AP-23 3rd-cycle promotion-eligibility threshold); downgrade-execution still DEFERRED to consolidated promote-rule cycle. D-055 cool-down ~12h54m remaining at S309 entry. |
| 2026-05-14T03:08:31Z | SCOPE | charter_match | 0.2 | auto-S-adr-1 | auto-detected new ADR mtime <6h |
| 2026-05-14T03:08:33Z | SCOPE | charter_match | 0.2 | auto-S-adr-2 | auto-detected new ADR mtime <6h |
| 2026-05-14T03:08:34Z | DECISION_ROUTING | q_and_a_resolution | 0.1 | auto-S-qa | auto-detected 1 Q&A in answered/ <6h |

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
