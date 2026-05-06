---
model: claude-sonnet-4-6
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL
samples_count: 2
sample_sessions: [S46, S47]
last_updated: 2026-05-05T13:30:00+07:00
source: S48i HH-F.1 ETL bootstrap from S46+S47 sandwich-dev dispatch records
status: BIASED-PRE-REBUILD-S65 (was DRAFT-INSUFFICIENT-SAMPLES; user 2026-05-06 flagged tracking gap → mark biased; rebuild after cost-ledger.tsv accumulates ≥10 sandwich-dev sessions)
---

# Profile — Sonnet 4.6 × max × FOCUSED_IMPL (sandwich-dev dispatch)

## 1. Capabilities

- BC-6 Track G adapter substrate ship (S46): 14 NEW files (domain VOs 7 + models 3 + application port 1 + infrastructure adapters 3 + CLI 1 + __init__.py 5) + 67 NEW tests PASS in 0.18s + mypy --strict 0 errors on 27 source files. Combined dual-dispatch cumulative ~333K (vs sub-plan 150-220K envelope; +50% overrun).
- BC-6 Track H LLM extractor ship (S47): recommendation.py domain aggregate + LLMRecommendationExtractorPort protocol + KOLContentGatherer + LLMRecommendationExtractor + ExtractionStrategyPicker. 23 NEW + 21 NEW = 44 Track H tests; full BC-6 suite 111 PASS. mypy --strict 0 errors on 33 source files. Empirical-probe-first ladder applied — 3 strategies tested on 10 Vietnamese KOL fixtures.
- mypy --strict (--explicit-package-bases on Windows Python 3.14) clean post-IMPL.

## 2. Known limitations

- **Subagent budget overrun pattern** (S46 ~333K cumulative across dual-dispatch vs 150-220K target +50%; partly attributable to redundant re-dispatch after /clear-induced TaskList loss — L-S46-2 candidate).
- **Bug surface** during dev IMPL — 4 real test-failure bugs in S46 caught only via re-dispatch Read-and-verify pass (future-timestamp in Telegram/Facebook tests; wrong Vietnamese diacritic assertion; Facebook auth-error path not raised on mock). Subagent fresh-context single-pass dev does NOT guarantee bug-free IMPL.
- **Vendor-API drift detection gap** — S47 IMPL-S47-5 found claude-haiku-3-5 not available (HTTP 404); substituted claude-haiku-4-5; gap exists between PLAN model recommendation and IMPL availability check.

## 3. Recommended task_class allocation

- **PRIMARY** for sandwich-dev FOCUSED_IMPL dispatch when test-first IMPL surface ≤30 NEW files + ≤80 NEW tests (S46 14+67 fits; S47 fitness pending Track H suite reconciliation).
- AVOID for charter/SCOPE-tier work (Charter Principle 3: adversarial — separate context required).
- Pair with mandatory sandwich-verifier dispatch at phase boundary per AP-1 (no S47 sandwich-verifier ran — verification consolidated within S47 IMPL session via main-session re-run).

## 4. Recent corrections + drift events

- **L-S46-2 candidate**: post-/clear TaskList loss does NOT mean dispatch failed — check for completion artifacts (file timestamps, current-execution rows) before re-dispatching to prevent budget overrun.
- **IMPL-S46-1..4 deviations** all under D1: dir naming (`influence/` vs `influence_network/`), respx in dev, mypy `--explicit-package-bases` flag on Windows Python 3.14, YouTube subtitle URL ref deferred to S47.
- **IMPL-S47-1..5 deviations**: vendor model substitution (haiku-3-5 → haiku-4-5).

## 5. Calibration

- Test delta: S46 +67 tests / S47 +44 tests = mean ~+55 tests/session.
- Test-PASS rate post-IMPL: 100% (0 regressions across 2 samples after re-dispatch bug-fix on S46).
- Budget actual vs target: S46 ~333K cumulative (re-dispatch overhead) vs 150-220K = +51% over; S47 ~tbd within 100-150K target (probe budget ~$1.63 USD additional).
- Probe efficiency (S47): 3 strategies tested; S3 Haiku-4-5 prefilter + Sonnet-4-6 extract WINS — precision=1.0, recall=0.889, cost=~$0.27/run.

## 6. Notes

This card is DRAFT until samples_count ≥ 3 (per profile-template anti-pattern "DON'T ship profile cards before sessions-rollup.tsv has ≥3 (model × effort) samples"). S46 + S47 = 2 samples; one more sandwich-dev FOCUSED_IMPL dispatch promotes to STABLE. Sample shape is BC-6 IMPL only — task_class generalization to other domains is provisional.

L-S46-2 candidate (post-/clear TaskList loss → re-dispatch budget overrun) is the most actionable lesson from this profile — relevant to ALL subagent dispatch types, not just sonnet-46-max-FOCUSED_IMPL. Promotion target: agent-notes.md or hook-tier dispatch-completion-detector if recurring.
