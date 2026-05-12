---
observation_id: sandwich-verifier-S234-phase3-close
type: sandwich-verifier-output
session: S234
target: Phase 3 formal close
verdict: PASS-WITH-RESIDUE
plan_reference: agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md
fresh_context: true
agent_id: adbe291b509bb8029
duration_ms: 1174652
total_tokens: 165637
---

# Phase 3 Close Verifier Report — S234 (2026-05-10)

## Verdict: PASS-WITH-RESIDUE

Phase 3 substantive code-level deliverables (BC-6 + BC-7 + BC-8 + BC-9 Track L + Track M scaffold) are structurally shipped, tested at unit level, and architecturally compliant with D-026 LLM Substrate Boundary + I-S1 NO-LLM-MATH. The LIVE 5-ticker dogfood pipeline executed end-to-end and persisted 5 theses to `data/stockforge.sqlite`. Bear-case I-S10 + I-S35 framing + per-thesis cost discipline all empirically PASS.

The verdict is PASS-WITH-RESIDUE rather than PASS because three classes of residue do NOT block transition to Phase 4 PLAN but DO bind Phase 4 IMPL entry — and they all share a common shape: Phase 3 shipped the **infrastructure to do** what the master-plan acceptance criteria describe, but the **runtime data flowing through that infrastructure** is fixture-only / mock-only / does-not-exist. This is the difference between "scaffolding ships" (binary PASS for SC-6) and "scaffolding is exercised at production scale" (numerical PARTIAL for SC-1, SC-3, SC-5).

## Acceptance criteria scoring (per master-plan §181-201)

| # | Criterion | Target | Actual | Status | Evidence |
|---|---|---|---|---|---|
| 1 | KOL coverage | ≥15 KOLs with ≥10 recs | 0 KOLs (3 fixture channels, 0 fetched live) | **FAIL on quantitative; ACCEPT per Q1 disposition** | Production sqlite (`data/stockforge.sqlite`) has 0 BC-6 tables (kols / kol_recommendations / channels NOT_FOUND). `apps/cli/ingest_kol_channels.py:43-60` ships 3 fixture channels only. Q1 (S233) accepted fixture-only path. |
| 2 | Recommendation extraction quality | ≥0.85 precision on 50 labeled samples | UNTESTED at scale | **N/A — no eval-set ≥50 samples shipped** | `eval-sets/labeled-kol-recommendations/` has only `SEED.md` + `README.md` — zero labeled JSON. 5 KOL transcript fixtures in `packages/infrastructure/influence/fixtures/vi_kol_transcripts/` are extractor unit-test inputs. |
| 3 | Calibration data accumulated | ≥150 recs with outcome reviews | 0 | **FAIL on quantitative; ACCEPT per cold-start mitigation R-P3-3** | Risk register R-P3-3 explicitly mitigates: scaffolding + first 10 recs as provisional; full activation Year 2. |
| 4 | Pump detection precision | ≥0.70 precision on 10 historical pump cycles | precision 1.000 / recall 1.000 — but on only 7 labeled pumps (2-row holdout) | **PASS (BR-5 gate) with low-N caveat** | `python -m apps.cli.backtest_pump_classifier --from-json eval-sets/labeled-pumps/` returned `BR-5 GATE: PASS`. Caveat: 7 < 10 master-plan target; 2-row holdout statistically meaningless. |
| 5 | Narrative tracking coverage | ≥20 distinct narratives | 0 narratives identified live | **FAIL on quantitative; ACCEPT per scaffolding-only scope** | Domain code defines 7 NarrativePhase enum values + classifier service. `eval-sets/historical-pumps/SEED.md` is template only. 0 BC-7 tables in production DB. |
| 6 | Outer-loop infrastructure | binary PASS — registry + recorder + store + Year-2-activation gate raises NotYetActivatedError | PARTIAL — 3 modules ship; activation gate ships but DOES NOT raise NotYetActivatedError; instead returns ActivationGateStatus dataclass | **PASS-WITH-DRIFT** | `packages/infrastructure/outer_loop/{editable_asset_registry, scalar_metric_recorder, eval_set_store}.py` ship + tests. `packages/domain/outer_loop/services/year2_activation_gate.py:42-58` returns ActivationGateStatus. `grep -rn NotYetActivated packages/` = 0 hits. Master-plan SC-6 wording drifted from spec 005 §A.2 ratified design. |
| 7 | UI dogfood acceptance | 5 KOL daily digests + 5 confluence alerts + 5 ticker sentiment views all reproducible deterministically | 8/8 dashboard smoke PASS; LIVE 5-ticker thesis pipeline PASS | **PASS with caveat** | `python -m pytest apps/dashboard/test_smoke.py -q` = 8/8 PASS in 1.63s. 5/5 LIVE thesis files written. Caveat: pages t4-t7 set `STOCKFORGE_DB=/nonexistent/no.sqlite` and assert only "Title rendered + ingest_X CLI hint shown" — they verify import + skeleton, NOT UC-1/2/3/4 data flows. |
| 8 | Phase 3 cost discipline | ≤$3/thesis | max $1.5851 (FPT) imputed; mean $1.346 imputed; actual marginal $0 (D-050 subscription) | **PASS** | dogfood-summary table + per-thesis cost frontmatter in 5 thesis files. |

**Numerical scoring**: 3 PASS (with caveats) + 2 PASS-WITH-DRIFT + 1 N/A + 3 FAIL-on-quantitative-but-ACCEPT-by-disposition.

## Adversarial findings

### F1. Bull-role degradation 4/5 — anti-pattern violation (NOT a SC-7 fail, but Phase 4 critical)

**Evidence**: `packages/infrastructure/analysis/perspectives/bull_agent.py:157-161` — try/except json.loads silently sets `raw_points = []`. No retry, no error surface. 4 thesis files (FPT, BID, BVH, GAS) have empty Bull Case sections. Reasoning trace shows `Bull points: 0`. Three documented failure modes per dogfood-summary: JSON-parse fail on prose+table emit (FPT, BVH); haiku 300s timeout (BID — recurrence of S43b BULL-FPT failure despite haiku model swap fix); silent bull-empty (GAS).

**Verdict**: NOT a strict SC-7 FAIL because SC-7 measures Track M dashboard PAGES rendering. But IS a violation of CLAUDE.md "Adversarial by default. Single-perspective output is anti-pattern" hard rule. **#1 Phase 4 prereq.**

### F2. LIVE crowd_sentiment NOT WIRED — Phase 4 entry blocker

**Evidence**: `apps/cli/ingest_crowd_sentiment.py:162-168` — non-dry-run path: `else: # Live mode: require real implementations (not wired Phase 3 — Phase 4) ... logger.warning(...) sys.exit(1)`. Production sqlite probe: `sentiment_snapshots`, `pump_detections`, `narratives`, `kol_recommendations` — all NOT_FOUND.

**Verdict**: NOT a Phase 3 close blocker (Q1 S233 accepted; SC-2 deterministic-classifier exists at unit-test level). **#2 Phase 4 prereq.**

### F3. KOL ingest fixture-only — SC-1 quantitative target unattainable

**Evidence**: `apps/cli/ingest_kol_channels.py:43-60` ships exactly 3 fixture channels (UCkol_youtube_fixture / kol_telegram_fixture / kol_facebook_fixture). Lines 119-134: dry-run returns `fetched_count=0 (no credentials)`. Lines 136-144: live fetch requires creds. Production sqlite: 0 BC-6 tables.

**Verdict**: SC-1 FAIL on quantitative target. Q1 S233 explicitly accepted "Fixture-only KOL + LIVE crowd+LLM" disposition. **#3 Phase 4 prereq — KOL credentials onboarding flow.**

### F4. Dogfood `real_thesis: false` hardcoded

**Evidence**: `apps/cli/validate_thesis.py:220` has the literal `"real_thesis: false",` string — single line, hardcoded, no flag override. All 5 thesis frontmatters confirm.

**Verdict**: SC-7 wording does NOT require `real_thesis: true`. Master-plan §187 is binary-PASS on deterministic-reproduction. NOT a Phase 4 hard prereq, but a **Charter SC-3 prereq**. Phase 4 should design composite flip rule (likely: calibration_grade ≥ C AND bull_points ≥ 3 AND live_crowd_sentiment_present AND data_gaps==[]).

### F5. Master-plan SC-6 wording drift — `NotYetActivatedError` does not exist

**Evidence**: `grep -rn NotYetActivated packages/` = 0 matches. `packages/domain/outer_loop/services/year2_activation_gate.py:42-58` ships `def evaluate(counts) → ActivationGateStatus` — returns status object, never raises.

**Verdict**: PASS-WITH-DRIFT on SC-6. Spec 005 §A.2 was the binding design and it returns a status object. Master-plan §186 wording drifted from spec. Recommend Phase 4 amend master-plan retro OR add thin `optimize()` entrypoint that raises a domain error on shortfalls.

### F6. Dashboard smoke tests verify import + skeleton, NOT data flows

**Evidence**: `apps/dashboard/test_smoke.py:235-246` test_t4_kol_daily_digest: `monkeypatch.setenv("STOCKFORGE_DB", "/nonexistent/no.sqlite")` then asserts `any("ingest_kol_channels" in i for i in info_texts)`. Same pattern for t5/t6/t7.

**Verdict**: NOT a hard SC-7 fail. Phase 4 should add at-least-one happy-path test per dashboard page against minimal seeded DB.

## Cross-cutting drift signal checks

| Signal | Result |
|---|---|
| DR1 (domain framework imports) | PASS — confirmed by S64 BC-6 verifier; spot-checked BC-7 + BC-9 same posture |
| DR6 (Any types in domain) | PASS per S64 verifier; no regression |
| DR8 (cross-BC imports) | PASS per S64 verifier |
| D10 (anthropic SDK) | PASS — S230 production probe = 0 violations; firing-test 6/6 PASS |
| I-S1 (No LLM Math) | PASS — `narrative_phase_classifier.py:19` deterministic; `pump_phase_classifier.py:101` deterministic; calibration_service uses scipy.stats.beta only |
| I-S2 (Source citation) | PASS in 5/5 dogfood theses |
| I-S3 (Bear case ≥3 distinct) | PASS 5/5 (5/6/6/7/5 = avg 5.8 bear points) |
| I-S35 (research-aid framing) | PASS 5/5 (4× watch + 1× investigate; 0 buy/sell) |
| I-S10 / Adversarial-by-default | **DEGRADED 1/5** — only CTG has both bear AND bull. F1 above. |
| D-026 LLM Substrate Boundary | PASS — cited by name in `llm_recommendation_extractor.py:6-56` (S64 verifier) |
| AP-1 (Same-agent self-review) | PASS — fresh-context subagent invocation |

## Phase 4 prereq enumeration (ranked)

1. **PRIORITY-CRITICAL — Bull-role degradation hardening.** Mitigation candidates: (a) strict-JSON-mode flag, (b) bull-output-validator with retry-on-parse-fail max-2, (c) bull model swap haiku→sonnet under parallel load, (d) pre-flight prompt-fixture validation. **Cannot enter Phase 4 IMPL of any thesis-pipeline-touching feature until fixed.**
2. **PRIORITY-HIGH — LIVE crowd_sentiment write path wiring.**
3. **PRIORITY-HIGH — KOL credentials onboarding flow** (3-platform env-var setup + at-least-one live channel ingest end-to-end).
4. **PRIORITY-MED — Eval-set seeding** (labeled-pumps 7→20+; labeled-kol-recommendations 0→growth roadmap; historical-theses 0→roadmap).
5. **PRIORITY-MED — `real_thesis: false` doctrine codification** (composite flip rule).
6. **PRIORITY-LOW — Master-plan §186 SC-6 wording drift** (retro-amend or add `optimize()` entrypoint).
7. **PRIORITY-LOW — Dashboard happy-path tests.**
8. **PRIORITY-LOW — UL glossary stale entries** (per S64 verifier).
9. **PRIORITY-LOW — D-027 ADR path drift** (per S64 verifier).
10. **PRIORITY-LOW — BC-6 events defined but not published** (per S64 verifier).

## Phase 4 backlog (nice-to-have / can defer)

- A. Pump phase classifier eval-set growth from 7 to 20+ labeled pumps.
- B. Sentiment classifier real model swap (currently dry-run returns NEUTRAL for all).
- C. KOL credentials documentation per platform + secrets-management policy.
- D. Notifications retention policy (793 files; user policy decision).
- E. Bull-role parallel-load investigation (S43b BULL-FPT recurrence on BID under 4-way fanout).
- F. Calibration-data seeding plan (0 → 150+ recs roadmap).
- G. Master-plan §186 SC-6 wording amendment.
- H. UL glossary refresh per S64 verifier findings.

## Recommendation

**ENTER PHASE 4 PLAN session — DO NOT enter Phase 4 IMPL until Prereq #1 (bull-role hardening) is empirically resolved.**

Rationale:
- All Phase 3 substantive code-level deliverables ship + pass unit tests.
- Tier 1 deterministic gates (mypy, pytest, ruff, drift-signals) PASS per S64 + S229/S230 + S231 dashboard smoke 8/8.
- Tier 2 probabilistic gate (this report) = PASS-WITH-RESIDUE.
- LIVE dogfood empirically validated end-to-end pipeline (5/5 thesis + bear-case I-S10 + cost discipline).
- Three Phase-4-blocker classes are surfaced (bull-role anti-pattern, LIVE crowd-sentiment unwired, KOL creds gap). They DO NOT block Phase 4 PLAN — they DO scope Phase 4 PLAN's first agenda items.
- Master-plan §192 explicitly defers FastAPI public endpoints, Streamlit→Next.js migration, TimescaleDB migration, and live broker integration to Phase 4-5; Phase 3 close does not need any of those.

**Specific next action**: Phase 4 PLAN session (sandwich-architect dispatch with lean brief ≤6 pre-reads per L-S43f-2). The architect's first agenda item should be the bull-role hardening sub-plan with 3 candidate strategies (strict-JSON-mode / retry-validator / model-swap) and an empirical-probe-first comparison on a 5-ticker validation set BEFORE selecting the strategy. This gates everything else in Phase 4.

## Relevant absolute file paths

- `agent-workspace/memory/observations/sandwich-verifier-S234-phase3-close.md` (this file)
- `agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md`
- `agent-workspace/memory/thesis-log/2026-05-09-dogfood-summary-S232.md`
- `agent-workspace/memory/thesis-log/2026-05-09-{FPT,BID,BVH,CTG,GAS}.md`
- `packages/infrastructure/analysis/perspectives/bull_agent.py` (silent error swallow line 157-161)
- `apps/cli/ingest_crowd_sentiment.py` (LIVE not wired line 162-168)
- `apps/cli/ingest_kol_channels.py` (3 fixture channels line 43-60)
- `apps/cli/validate_thesis.py` (real_thesis hardcoded line 220)
- `packages/domain/outer_loop/services/year2_activation_gate.py` (returns status, doesn't raise)
- `apps/dashboard/test_smoke.py` (8/8 smoke PASS, but t4-t7 only verify skeleton)
- `eval-sets/labeled-pumps/` (7 labeled pumps; SC-4 PASS with low-N caveat)
- `agent-workspace/memory/observations/sandwich-verifier-S64-BC-6.md` (prior BC-6 verifier)
- `data/stockforge.sqlite` (5 tickers in bars+fundamentals; 12 theses; 0 BC-6/BC-7/BC-9 tables)
