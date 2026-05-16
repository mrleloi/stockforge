# Observation: sandwich-architect S353 — plan-026 Vietstock adapter

**Agent**: sandwich-architect (background subagent)
**Session**: S353 (planning)
**Authored**: 2026-05-16
**Target plan**: `agent-workspace/session-plans/pending/026-S353-phase-d-vietstock-adapter.md`
**Target dev session**: S354 (sandwich-dev, FOCUSED_IMPL)
**Target verifier session**: S355 (sandwich-verifier, AP-1 fresh-context)
**Predecessor**: plan-022-S343 (NDH adapter S344-S345; F2-store_raw fix applied inline at S345 close); plan-025-S346 (planner-upgrade; first IMPL post-deployment dogfood expected = this plan)

---

## 1. What was authored

A 1148-LOC FOCUSED_IMPL plan for Vietstock adapter — the **second greenfield Strategy A direct-subclass** in BC-5 News Stream per-source rollout (after CafeF Strategy B WRAP at S337 + NDH Strategy A at S344). Plan mirrors plan-022 shape with three Vietstock-specific divergences captured in DD/RM/§E.

**Sub-tracks**: 5 (D1 adapter / D2 parser internals merged-into-D1 / D3 tests / D4 registry+CLI / D5 ADR REV-2). All 5 sub-tracks declare the NEW per-plan-025 fields: `parallel_with`, `blocks_on`, `coordination_paths_exclusive`, `estimated_wall_min`.

**Calibration summary present**: YES — CONSUMED variant per plan-025 DD-11 mandate (≥3 sub-tracks). Sample size note: `.planner-stats.tsv` header-only (cold-start per DD-1); sessions-rollup task_class="crawler-adapter-impl" sample_size=1 (NDH S344 single observation); statistically weak but directionally informative.

## 2. Key decisions made (and why)

- **DD-1 class name**: `VietstockAdapter` not `VietstockFinanceAdapter` (matrix label = "VietstockFinance" but brand = "Vietstock"; lowercase source_id = `"vietstock"`; aligns with NDH/CafeF lowercase-source_id convention).
- **DD-3 Strategy A**: greenfield direct-subclass per plan-020 § E matrix line 353 + plan-022 DD-3 precedent. The matrix hint "A primary + B (Scrapling adaptive fallback) candidate if listing AJAX" is addressed via STEP 0.4 branch (static-article-page path with HTML-listing alternative if listing-AJAX; full B fallback deferred).
- **DD-4 SelectorChain**: 2 instances (headline + body) matching NDH ndh_adapter.py:206-244 post-S344 actual; date uses fmt-string chain inside `_parse_published_at` (NDH precedent). Vietstock historically uses Vietnamese-locale dates like "%d/%m/%Y %H:%M" + ISO-8601 — dev fills from STEP 0.4.
- **DD-7 F2-aware DAY-ONE** (most-important architectural divergence from plan-022): `_fetch_with_optional_chain(url, *, store_raw: bool = True)` keyword-only param shipped from day 1, with `discover()` passing `store_raw=False`. NDH shipped pre-S345 without this param → verifier S345 caught contamination → fix applied inline. Vietstock plan promotes the lesson into upstream design (L-S345-3 candidate). Quintuple-guarded via DC-IMPL-7 + DC-IMPL-8 + tests 7+19 + DC-SMOKE-4 + DC-FILE-9.
- **DD-5 rate-limit**: 2.0s default per matrix line 353 (Vietstock is mainstream portal; not as restrictive as VietnamBiz at 3.0s on line 354).
- **DD-8 UA**: verbatim reuse of `stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)` matching CafeF + NDH.
- **DD-10 fixture strategy**: synthetic inline HTML for unit tests; one real CLI smoke recorded but NOT committed (per AQ-9 + skill § Anti-Patterns "Committing scraped data without source_url violates I-S2 citation rule").

## 3. What was rejected (and why)

- **Bundling Vietstock + VietnamBiz in same plan** → REJECTED per RM4 (S4 catastrophic-mix-pattern); each source needs its own STEP 0 + selectors + tests + CLI + ADR amendment; budget envelope per master plan § 6.4 caps at FOCUSED_IMPL = one source per session.
- **`VietstockFinanceAdapter` class name** → REJECTED (verbose; source_id `"vietstockfinance"` adds noise; brand alignment favours short).
- **Composing VietstockAdapter from internal `_VietstockScraper` helper class** → REJECTED (per plan-022 DD-3 same reasoning: unnecessary indirection; double-class maintenance from day 1).
- **3.0s preemptive rate-limit bump** (mirror VietnamBiz conservative) → REJECTED (matrix line 353 doesn't flag Vietstock as less lenient than CafeF/NDH; STEP 0.4 empirically verifies).
- **Two separate fetch methods `_fetch_for_article` + `_fetch_for_listing`** (no shared helper) → REJECTED per DD-7 adversarial alternate (DRY favours single helper with kw-only flag; consistency across adapters per L-S345-3 promotion candidate).
- **All-real-HTML committed to `tests/fixtures/vietstock/*.html`** → REJECTED per plan-022 DD-10 precedent (fixture-licensing concern; fixtures drift as Vietstock redesigns site).

## 4. STOP-AND-ASK clauses (4 triggers in STEP 0)

Same shape as plan-022 STOP clauses; specifically for Vietstock:
1. BOTH `vietstock.vn` AND `finance.vietstock.vn` 404 → defer adapter (AQ-5).
2. robots.txt disallows for User-agent: * or stockforge-research-bot → defer adapter (AQ-6).
3. ToS forbids automated access → defer adapter (per I-S34 charter line 110).
4. Article pages JS-rendered (require Playwright) → defer adapter (I-S34 HARD REJECT of patchright + StealthyFetcher; carve-out: if ONLY listing-page is AJAX but article pages static → PROCEED with HTML-listing alternative).

## 5. Phase 1b consumption (FIRST DOGFOOD POST-PLAN-025)

This plan is the FIRST architect dispatch post-plan-025 IMPL (commit fcc63e7) + plan-025 close (commit 2bc4904). The Phase 1b mandate per `.claude/agents/sandwich-architect.md` lines 42-65 was empirically verified consumed:

**Sources read** (cap last 30 rows each per DD-2):
- `agent-workspace/memory/.planner-stats.tsv` → header-only (first real consumption; cold-start per DD-1 graceful-degrade)
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` last 30 rows (rows 593-633) → S344 NDH session token delta 266338→375571 = ~109K real tokens spent, wall ~48 min total turn
- `agent-workspace/memory/dispatch.jsonl` last 30 rows (rows 490-539) → NDH sandwich-dev dispatch toolu_01ACd355wE7qm75tQXzFkTRt billed 34.8M tokens / duration_ms 57687777 ≈ 96 min total billed (Sonnet model)
- `agent-workspace/memory/mistake-log.md` last 200 LOC → recent: M-S347-NONE (clean MULTI_TASK_IMPL); M-S342-1 (verifier touch+rm hygiene gap; medium); M-S341-1 (dev observation overstated; low). No crawler-adapter-impl mistakes recent.

**Calibration verdict**:
- task_class match: 1 prior observation (NDH); n=1 statistically weak; cold-start adjustment minimal
- Budget recommendation: 100-150K Opus FOCUSED_IMPL = mirror NDH-actual real-tokens (~109K Sonnet) with bump for Opus rate (~30-40% more tokens per surgical line) + Phase 1b consumption overhead + new parallel_with field authoring
- Parallel opportunity DETECTED: D3+D4+D5 can run parallel post-D1; disjoint coordination_paths_exclusive; max-3-parallel ceiling per Q-PL1 RATIFIED; projected ~29% wall-time reduction vs sequential

**Phase 1b worked as designed** — first observation that grounding budget in empirical telemetry (NDH actual ~109K Sonnet) produces a different number than LLM-guess ("approximately 100K Opus" boilerplate) — the empirical anchor calibrates the boilerplate upward to absorb Opus rate + Phase 1b overhead realistically.

## 6. Parallel-dispatch declaration (FIRST INSTANCE)

This plan is the FIRST PRODUCT-tier plan to declare `parallel_with` per plan-025 DD-3 contract:
- D1: parallel_with=[], blocks_on=[], coordination_paths_exclusive=[vietstock_adapter.py], estimated_wall_min=14
- D3: parallel_with=[D4, D5], blocks_on=[D1], coordination_paths_exclusive=[test_vietstock_adapter.py], estimated_wall_min=8
- D4: parallel_with=[D3, D5], blocks_on=[D1], coordination_paths_exclusive=[__init__.py, ingest_news_vietstock.py], estimated_wall_min=8
- D5: parallel_with=[D3, D4], blocks_on=[D1], coordination_paths_exclusive=[066-bc5-crawler-adapter-contract.md], estimated_wall_min=3

**Lint contract self-verified** (per plan-025 DD-4):
- coordination_paths_exclusive disjoint across parallel_with siblings ✓ (4 disjoint file sets)
- max-3-parallel cardinality per dispatch wave ✓ (D3+D4+D5 = 3, at ceiling)
- blocks_on forms cycle-free DAG ✓ (D1 root; D3/D4/D5 all depend only on D1)

**Recommended dispatch by main S354**: D1 sequential → then single Agent-tool multi-call dispatching D3+D4+D5 in parallel. Total wall ~22 min vs sequential ~31 min = ~29% reduction.

## 7. Plan-022 ambiguities resolved by NDH lessons

NDH IMPL (S344-S345) surfaced two lessons now hard-coded into this plan:
- **F1 LOC discipline lesson** (M-S341-1 family): observation overstated claims about hooks; promotion candidate L-S342-2 ("observation files claiming 'all <X>' must be backed by empirical grep evidence"). Applied here: § F DC items name specific files for grep checks (not "all adapter files"); calibration summary cites exact row numbers + file paths.
- **F2 store_raw lesson** (S345 verifier IMPORTANT defect): NDH adapter shipped without `store_raw` parameter; discover() polluted data/raw/news/ndh/ with listing-page HTML. Fix applied inline post-S345. Vietstock plan promotes the lesson via DD-7 architected from day 1 + RM11 + DC-IMPL-7/8 + tests 7+19 + DC-SMOKE-4 + DC-FILE-9 quintuple-guard.

These two lessons converted plan-022's implicit assumptions into explicit DD/DC/test directives.

## 8. Files I targeted

Plan output:
- `agent-workspace/session-plans/pending/026-S353-phase-d-vietstock-adapter.md` (NEW — 1148 LOC)
- This observation file (NEW — ~180 LOC)

Files READ during VBW (not modified):
- `.claude/agents/sandwich-architect.md` (lines 1-252 — full template incl. Phase 1b mandate L42-65 + Sub-track template L110-126 + Calibration summary mandate L212-236)
- `agent-workspace/memory/.planner-stats.tsv` (1 line header only)
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (rows 593-633 last 30)
- `agent-workspace/memory/dispatch.jsonl` (rows 200-250 + 490-540 sampled)
- `agent-workspace/memory/mistake-log.md` (lines 1-110)
- `agent-workspace/memory/current-execution.md` (lines 1-80 INCIDENT + BEHAVIORAL HOLD context)
- `agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md` (full 1124 LOC across 3 reads)
- `agent-workspace/session-plans/completed/025-S346-planner-upgrade.md` (lines 1-180 — header + DD-1 to DD-4)
- `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` (lines 340-400 + grep matches for Vietstock — line 353 matrix row + line 487/513 references)
- `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` (lines 1-345 — full sibling reference incl. post-S345 store_raw fix at lines 159-160, 306-345)
- `packages/infrastructure/news/crawler_adapters/__init__.py` (full)
- `packages/application/news/ports/crawler_adapter.py` (full ABC contract)
- `apps/_shared/crawl/selector_chain.py` (lines 1-110 — primitive contract)

## 9. Risks I flagged

Top-3 risks for S354 dev:
- **RM2 JS-rendered Vietstock**: master plan line 353 hypothesizes "AJAX for some report listings" — STEP 0.4 empirically verifies; if article pages are JS-rendered → DEFER; if only listings are AJAX → PROCEED with HTML-listing alternative
- **RM11 DD-7 F2-aware regression** (NEW): if dev forgets store_raw=False in discover(), recreates NDH pre-S345 bug; quintuple-guarded via DC-IMPL-7 + DC-IMPL-8 + tests 7+19 + DC-SMOKE-4 + DC-FILE-9 — virtually no silent-regression path
- **RM5 rate-limit 2.0s insufficient**: STEP 0.4 sample-fetch detects 429/503 → bump to 3.0s + flag verifier

## 10. Plan stats

- LOC: 1148 (vs plan-022 1124; +24 LOC for parallel_with fields + DD-7 expansion + RM11)
- DoD count: 35 (vs plan-022 30; +5 for DC-IMPL-7/8 + DC-FILE-9 + DC-SMOKE-4 + extra ADR-REV-2 verification item)
- DD count: 10 (matches plan-022)
- AQ count: 10 (matches plan-022)
- RM count: 11 (vs plan-022 10; +1 RM11 DD-7 F2-aware regression)
- Sub-tracks: 5 (matches plan-022)
- NEW per plan-025: all 5 sub-tracks declare parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min ✓
- NEW per plan-025 DD-11: Calibration summary CONSUMED variant present in § B ✓

## 11. Surprise findings (deferred per Karpathy P3)

- **None this plan**. STEP 0 deferred to S354 dev (cannot run live HTTP from architect subagent which lacks Bash). All surprises will surface at S354 STEP 0 + S355 verifier.
- The only "surprise" was that .planner-stats.tsv is genuinely empty (header-only) — confirmed graceful-degrade per DD-1 cold-start clause; the plan correctly notes this in the Calibration summary CONSUMED variant rather than skipping to SKIPPED variant.

## 12. Compliance attestation

- 0 charter / 0 constitution / 0 production code (architect is PLAN-only; tools: [Read, Glob, Grep, Write])
- 0 commits / 0 pushes (architect has no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh)
- 0 human-workspace writes
- AP-1 honored (fresh-context dispatch from main session)
- VBW protocol applied (12 source files read end-to-end before any plan claim authored; every § cites file:line per I-S2)
- Phase 1b mandate per plan-025 honored (CONSUMED variant — all 4 tracking-log sources read; cold-start clause properly applied)
- DD-7 F2-aware design promotes S345 verifier lesson — first-instance promotion candidate L-S345-3 documented in plan § L
- No invented enhancements per Karpathy P3 — every § traces to plan-022 ancestor OR plan-025 mandate

## 13. Next-action handoff to main session

Main session should:
1. Commit this plan output (architect lacks Bash; per D-060 + pre-dispatch-architect-commit-guard.sh)
2. Dispatch S354 sandwich-dev (background; fresh-context AP-1) with brief pointing to `agent-workspace/session-plans/pending/026-S353-phase-d-vietstock-adapter.md`
3. NOTE: dev MAY use parallel-dispatch for D3+D4+D5 post-D1 per plan-025 capability — first PRODUCT-tier parallel dispatch
4. After S354 dev close, dispatch S355 sandwich-verifier (background; fresh-context AP-1; Opus) to verify against DoD
5. Calibration loop closes when S355 verifier completes — planner-feedback-loop.sh hook will append to .planner-stats.tsv at S355 Stop boundary; next architect dispatch (e.g., plan-027 VietnamBiz) consumes the now-populated stats with sample_size=2

---

**END OF OBSERVATION**
