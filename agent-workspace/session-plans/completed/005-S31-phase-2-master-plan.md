---
plan_id: 005-S31-phase-2-master-plan
session: S31
session_type: PLAN (master-plan author; per CLAUDE.md "never mix PLAN+IMPL")
authored_at: 2026-04-30
authored_by: Claude Opus 4.7 (S31 master-planner subagent dispatch)
predecessor: agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md (Phase 1 master-plan; S25-S30 ALL DONE)
predecessor_status: Phase 1 = COMPLETE 2026-04-30; S29 verifier verdict PASS-WITH-RESIDUE; D-011 SCOPE-tier ACCEPTED user explicit Option A
phase: 2 (re-numbered per D-011 — covers original Charter Month-3 Tier 1+2 VN30 + Month-6 partial; original Charter "Phase 2 Edge Sources" Tier 3+4 = re-numbered to Phase 3 here; phase-numbering audit recommended at Phase 2 close)
scope_summary: Tier 1+2 VN30 rollout — close R2 TCBS-source blocker, scale BC-1 ingestion VHM→VN30, ship BC-2 Fundamental, ship BC-5 News stub + first scraper (CafeF), promote 9 proposals to constitution (parallel batch), expand thesis pipeline to real 3-perspective Bear/Bull/Quant per spec 001 § B.2 Phase 1 simplifications → real implementation
estimated_envelope_tokens: ~860K-1.25M (12-14 sessions; calibrated +30-40% over D-011 abstract ~600-900K based on Phase 1 actual ~888-1023K)
estimated_session_count: 12 sessions S32-S43 (1 PLAN-style sub-bundle for Track E + 1 final VERIFY)
mode: AUTONOMOUS (full; autonomous_mode=true per S15 + Phase 1 close ratification)
budget_target_self: ~80K (PLAN-only; this file is the deliverable)
---

# S31 PLAN — Phase 2 Master Plan (Tier 1+2 VN30 Rollout; S32 → S43)

> **Goal**: Decompose Phase 2 (Tier 1+2 VN30 rollout per D-011) into a 12-session sequence ending with a working `/thesis-validate` automated pipeline that produces ≥5 real thesis on VN30 stocks with end-to-end <5min latency, ≤$3 cost ceiling, real BearAgent + BullAgent + QuantAgent operational on grounded Tier 1+2 data, and Charter Month-3 + Month-6 partial success criteria honestly satisfied.
>
> **Constraints binding** (CLAUDE.md hard rules + agent-workspace/CLAUDE.md):
> - Each session ≤150K (FOCUSED_IMPL); ≤250K (MULTI_TASK_IMPL); ≤80K (PLAN); ≤150K (whole-Phase VERIFY per L-S21-1 calibrated)
> - Never mix PLAN + IMPL in same session
> - Sandwich pattern (Architect → Dev → Verifier) for non-trivial work; Phase 2 close = sandwich-verifier whole-Phase review per S29 model
> - NO LLM math; numbers from code only (Charter Principle 9; I-S1)
> - Every claim has source + as-of date (Charter Principle 1; I-1; I-S5)
> - Constitution edits route through `agent-workspace/proposals/` first; user explicit approve required (Track E)
> - Domain layer = pure stdlib + dataclasses + Enum (zero framework deps); Pydantic only in interfaces/infrastructure
> - Cross-BC communication via `packages/contracts/` only (per IMPL-S27-1 + IMPL-S27-2 doctrine)
> - Agents never `git commit` unless user explicitly requests
> - Track E (proposals batch) is fully PARALLEL — does not block IMPL sessions per D-011 § Option C analysis
> - Track A (R2 closure) is BLOCKER for Track B VN30 rollout — Rule 4 multi-source reconciliation requires ≥2 working providers for ≥80% of VN30
> - VBW pre-flight per L-S30-1 doctrine: every proposed deliverable file path must be `ls`-verified NEW or EDIT-ratify

---

## Charter Alignment

Phase 2 closes Charter Month-3 deferrals (Tier 1+2 VN30 + 50 dossiers + 5 thesis) and partially advances Charter Month-6 (Tier 1+2 ingestion for top 100 — Phase 2 scope = top 30 VN30 only; top 100 deferred to Phase 3 entry tail).

| # | Charter Criterion | Charter Phase | Phase 2 mapping (this plan) |
|---|---|---|---|
| 1 | Tier 1 + 2 data pipeline operational for VN30 | Month 3 | DONE end-S43 — BC-1 VN30 ingestion (Track B) + BC-2 Fundamental (Track C) + BC-5 News stub (Track D) operational on all 30 VN30 tickers |
| 2 | 50 companies have basic dossier in wiki | Month 3 | PARTIAL — VN30 = 30 dossiers (not 50); 20 mid-cap dossiers deferred to Phase 3 entry. Honest framing: spec 000 § A.4 already deferred Charter "50" → Phase 2; Phase 2 ships 30; remaining 20 = Phase 3 entry first sprint. |
| 3 | First 5 thesis recorded with formal structure | Month 3 | DONE end-S43 — Track F produces ≥5 REAL thesis (`real_thesis: true`) on VN30 stocks via working `/thesis-validate` pipeline; per Q-S30-1 doctrine VHM-exemplar (`real_thesis: false`) does NOT count |
| 4 | Can run `/thesis-validate` on a stock end-to-end in <5 minutes | Month 3 | DONE end-S43 — full automation via Track F (real `BearPerspectiveAgent` + `BullPerspectiveAgent` + `QuantPerspectiveAgent` + `Phase1Synthesizer` + Streamlit page); per spec 001 § A.3 AC-1 + AC-5 reproducibility + cost ceiling $3 |
| 5 | 30+ KOL channels tracked | Month 6 | OUT-OF-SCOPE Phase 2 — KOL = Tier 3 = Phase 3 (re-numbered original Charter Phase 2 Edge Sources). Spec 002 not exercised. |
| 6 | Tier 3 + 4 ingestion operational top 100 | Month 6 | OUT-OF-SCOPE Phase 2. |
| 7 | First detectable pump pattern caught | Month 6 | OUT-OF-SCOPE Phase 2. |

**Phase numbering note**: D-011 SCOPE-tier explicitly framed Phase 2 = "Tier 1+2 VN30 rollout" — this consolidates Charter Month-3 (originally Phase 1) + partial Month-6 (originally Phase 2). Original Charter "Phase 2 Edge Sources" Tier 3+4 = re-numbered to Phase 3 in the execution sequence. Phase-numbering audit recommended at Phase 2 close session (S43 + lessons-learned ceremony) — propose either (a) ratify D-011 re-numbering as durable (charter immutable; revision protocol triggered) OR (b) keep D-011 re-numbering executional-only and treat charter phase IDs as historical reference. Recommend (b) — charter immutability is sacred per Revision Protocol; D-011 lives in current-execution.md and decisions/ as the runtime authority.

---

## Track Catalog (A-F)

### Track A — R2 Closure (BLOCKER for Track B)

**Goal**: Establish ≥2 working bar-source providers for ≥80% of VN30 tickers so Rule 4 multi-source reconciliation has signal. R2 (S29 verifier residue) = TCBS public API returned 404 for VHM ingestion → SINGLE_SOURCE=248 only. Cannot ship VN30 with all 30 tickers single-source per Rule 4 + financial-data-protocol-amendment-VN.md Rule 14 sàn-tier discipline.

**Strategy options** (S32 PLAN session evaluates + picks):
- **A1**: Discover working TCBS endpoint (path/query/header probe; vendor-API archaeology)
- **A2**: Pivot to DNSE or KBS via `vnstock` 4.0.2 alternate sources (vnstock has multiple source backends per IMPL-S28-1)
- **A3**: SSI / VnDirect public API direct (skip vnstock wrapper; httpx adapter à la TcbsAdapter)
- **A4**: Accept SCOPE-tier deviation — document SINGLE_SOURCE-only Phase 2 with explicit Rule 4 waiver via proposal; rely on vnstock-only with per-ticker freshness sanity checks

**Recommended A2 first** (vnstock 4.0.2 supports VCI / TCBS / SSI / DNSE backends; lowest engineering cost; preserves existing adapter Protocol). Fall to A3 if vnstock alternate-source coverage <80% VN30. A4 = last resort (requires user SCOPE-tier approve).

**Dependencies**: NONE (Track A unblocks B).
**Estimated session count**: 1 (S32 — FOCUSED_IMPL, ~120-140K).
**Budget envelope**: ~120-140K.
**Failure mode**: If A1+A2+A3 all <80% VN30 coverage, S32 escalates to A4 SCOPE-tier user-gate before exiting.

### Track B — VN30 Universe Expansion (BC-1 ingestion)

**Goal**: Scale BC-1 ingestion from 1 ticker (VHM thin-slice) to all 30 VN30 tickers; reuse existing `vnstock_adapter.py` + `tcbs_adapter.py` (or A2/A3 substitutes from Track A); generalize CLI `apps/cli/ingest_vhm.py` to `apps/cli/ingest_vn30.py` (NEW); 1-year backfill window per Q1 query pattern in VHM exemplar; reconciliation per Rule 4 + per-Sàn tolerance per amendment-VN Rule 14.

**Key design choice**: Streaming ingestion vs nightly batch — pick **nightly batch** for Phase 2 (simpler; matches spec-T1-001 § B.7 cadence "tier_1_hard_data: eod: 16:00 daily"; streaming = Phase 3 when intraday lands). 30 tickers × 250 days ≈ 7,500 bars per source × 2 sources = ~15K rows; SQLite handles this comfortably (TimescaleDB still deferred per IMPL-S28 doctrine).

**Sub-deliverables**:
- VN30 universe constants file (`packages/domain/market_data/value_objects/vn30_universe.py` — NEW; immutable list of 30 Tickers; source: HOSE VN30 index list as-of 2026-04-30)
- `apps/cli/ingest_vn30.py` (NEW; CLI; orchestrates 30 × adapter calls with rate-limit budget per Phase 2 cost profile spec-T1-001 § B.8)
- `data/vn30.sqlite` populated ≥6,000 rows post-S33 (30 tickers × ~200 days each, allowing for missing days)
- Reconciliation report per ticker `data/vn30-reconciliation/{ticker}.md` (30 files)
- Rate-limit budget enforcement: 1 req/sec default per provider per IMPL-S28 + 30s retry on 429
- Per-Sàn tolerance Sub-deliverable: `ReconciliationService.tolerance_for(bar)` extended per amendment-VN Rule 14 (HOSE ±1% / HNX ±2% / UPCoM ±5%) — but VN30 = HOSE only per Rule 14 Phase 1 lock, so tolerance stays ±1% (verify each VN30 ticker is HOSE-listed in S33 pre-flight)

**Dependencies**: Track A (R2 closure must precede); soft-depends on Track E proposal "financial-data-protocol-amendment-VN" promotion (if user-approved → reconciliation tolerance per-Sàn lands directly in constitution; else stays per-IMPL config in `reconciliation_service.py`).
**Estimated session count**: 1 (S33 — MULTI_TASK_IMPL, ~180-220K).
**Budget envelope**: ~180-220K.

### Track C — BC-2 Fundamental Ingestion + Ratio Compute

**Goal**: Per spec-T1-001 § B.1 + spec 001 § B.4 Phase1DataGatherer signature — ship BC-2 Fundamental aggregate (`FinancialStatement` entity + `Ratio` value object + `ValuationInput`) + financial-statements adapter (vnstock or Vietstock public) + ratio compute service (deterministic; pure stdlib + Decimal; no LLM math per I-S1) + peer comparables service. Target: `ratios_ttm` (P/E, P/B, ROE, Debt/Equity) + `historical_percentiles` (5-yr per-ticker + sector) per spec 001 § B.4 Phase1DataGatherer signature.

**Sub-deliverables**:
- `packages/domain/fundamental/models/financial_statement.py` (NEW; per spec-T1-001 § B.1 schema)
- `packages/domain/fundamental/value_objects/{ratio,statement_type,line_item}.py` (NEW; 3 files)
- `packages/domain/fundamental/services/{ratio_service,peer_service,percentile_service}.py` (NEW; 3 files; pure stdlib + Decimal)
- `packages/domain/fundamental/repositories/fundamental_repository.py` (NEW; Protocol per Rule 1 — `get_as_of()` + `get_latest()`; **NO** `get_all()` per Rule 1 enforcement)
- `packages/infrastructure/fundamental/{vnstock_fundamental_adapter,sqlite_fundamental_repository}.py` (NEW; 2 files)
- `apps/cli/ingest_fundamentals_vn30.py` (NEW; nightly batch; 30 tickers × 4 quarters × 3 statement types ≈ 360 rows)
- Tests ≥30 PASS in <2s (TDD ratio compute formulas verified against textbook + vnstock reference data)
- Cross-BC contract event: `financial_statement_filed` (`packages/contracts/events/financial_statement_filed.py`; emitted post-ingestion)

**Dependencies**: Soft-depends on Track A (vnstock backend choice) + Track B (BC-1 + Bar repository pattern as reference architecture). Hard-depends on existing `packages/contracts/types/{ticker,money,currency}.py` (S27 deliverables).
**Estimated session count**: 1 (S34 — MULTI_TASK_IMPL, ~180-220K).
**Budget envelope**: ~180-220K.

### Track D — BC-5 News Stub + First Scraper (CafeF)

**Goal**: Per spec-T1-001 § B.2 + Charter § Data Sources Phase 1 (CafeF most popular) + L-S26-1 doctrine applied to news scraping (rate-limit + ToS + provenance) — ship BC-5 News Stream aggregate (`NewsArticle` entity + `ExtractedClaim` aggregate per spec-T1-001 § B.2 schema) + CafeF first scraper (httpx + BeautifulSoup; static HTML parse; respect robots.txt + 1 req/2sec rate-limit per spec-T1-001 § B.9 privacy & legal). Tier 2 LLM extraction = claim extraction + categorical sentiment (5-class STRONGLY_BULLISH..STRONGLY_BEARISH per Rule 7 + I-S1) + entity detection (mentioned tickers via UL glossary lookup) + cluster related stories per spec-T1-001 § B.2 LLM Role.

**Phase 2 budget choice** (S36 PLAN-style decision via inline 1Q if uncertain at S36 entry; otherwise default to Postgres-only):
- R2 raw storage = DEFER Phase 3. Postgres-only Phase 2 acceptable per Charter "Ship thin slices, not perfect systems" + spec-T1-001 § B.6 "R2 for full article text (cheap storage)" can land later. Trade-off: full body excerpts capped 500 chars in Postgres `body_excerpt` column (per spec-T1-001 § B.2 schema); full body fetched on-demand from URL if needed (with re-cache if URL still live).

**Sub-deliverables**:
- `packages/domain/news/models/{news_article,extracted_claim}.py` (NEW; 2 files; ExtractedClaim per Rule 6 LLM Output Provenance — extractor_model + extractor_version + source_url + source_text_excerpt + extracted_at + confidence_extracted + verified_by_human=False)
- `packages/domain/news/value_objects/{sentiment,extractor_metadata}.py` (NEW; 2 files; Sentiment Enum 5-class STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH per Rule 7)
- `packages/domain/news/services/claim_extraction_service.py` (NEW; pure-stdlib orchestrator that calls LLM port; LLM port lives in application layer)
- `packages/domain/news/repositories/{news_repository,claim_repository}.py` (NEW; 2 files; Protocols)
- `packages/application/news/ports/llm_extractor_port.py` (NEW; Protocol abstracting Claude API)
- `packages/infrastructure/news/{cafef_scraper,sqlite_news_repository,claude_llm_extractor}.py` (NEW; 3 files)
- `apps/cli/ingest_news_cafef.py` (NEW; polls CafeF every 10 min during S37 dogfood window; not yet wired to scheduler — manual run for S43 verifier; full automation deferred to Phase 3)
- Tests ≥35 PASS in <2s (fixture-based scraper tests; LLM mocked via test fixture; NO live LLM calls in CI per Phase 0 discipline)
- Cross-BC contract event: `news_article_ingested` + `extracted_claim_published` (`packages/contracts/events/`; 2 files)

**LLM cost budget enforcement** per spec-T1-001 § B.8 + spec 001 § B.10: claim extraction ~$0.50-2 per article × 30 VN30-related articles per day × 30 days = ~$450-1800/month worst-case → MUST cap per session via `CostTrackerPort` (existing pattern from spec 001 § B.3) at $50/session sandbox; per-article ≤$0.10 (Sonnet not Opus for extraction).

**Dependencies**: Track C (Fundamental adapter pattern as reference for LLM-port pattern); Track E proposal `provenance-protocol.md` user-approved (if user moves to constitution, claim extraction enforcement becomes binding; else stays IMPL-tier convention).
**Estimated session count**: 2 (S35 PLAN-tier sub-bundle for S36 spec-author + S37 IMPL; OR S36 single MULTI_TASK_IMPL if PLAN already sufficient from this master-plan). Recommend 1 session: S36 MULTI_TASK_IMPL.
**Budget envelope**: ~200-240K (single MULTI_TASK_IMPL S36) OR ~250-340K split across S35+S36.

### Track E — 9 Proposals User-Approve Batch (PARALLEL)

**Goal**: Per D-011 § Option C analysis = "not a gate" — drain the 9-proposal queue at `agent-workspace/proposals/`. Compose AskUserQuestion bundles ≤4 per call surfacing each proposal verbatim summary; user approve = move from `agent-workspace/proposals/` to `agent-workspace/constitution/` per existing `move_when:` directive in each proposal frontmatter. Fully parallel to Tracks A-D-F; no IMPL session blocks on this. Tier classification:

| # | File | Tier | Recommendation |
|---|---|---|---|
| 1 | `provenance-protocol.md` | CHARTER | Bundle 1 |
| 2 | `autonomous-protocol.md` | CHARTER | Bundle 1 |
| 3 | `memory-tiers.md` | CHARTER | Bundle 1 |
| 4 | `decision-discipline.md` | CHARTER | Bundle 1 |
| 5 | `architecture-amendment.md` | SCOPE | Bundle 2 |
| 6 | `financial-data-protocol-amendment.md` (S16 — Hook Portability Rule 11) | SCOPE | Bundle 2 |
| 7 | `session-budgets-amendment.md` | SCOPE | Bundle 2 |
| 8 | `financial-data-protocol-amendment-VN.md` (S26 — Rules 12-15) | CHARTER | Bundle 3 |
| 9 | `invariants-amendment-VN.md` (S26 — I-S55..I-S65) | CHARTER | Bundle 3 |

**Bundle composition rule** (per L-S15-1 multi-batch packing): max 4 proposals per AskUserQuestion (Charter-tier) batch — keeps user cognitive load ≤4 questions at once. Total batches = 3.

**Sub-deliverables** (per session):
- AskUserQuestion bundle composed + posted (Bundle 1 in S38; Bundle 2 in S39; Bundle 3 in S40 — alternatively all 3 batches in 1 dedicated session S38 if user availability permits)
- Per-approval: file moved (`mv proposals/X.md constitution/X.md`) + `agent-workspace/memory/decisions/D-NNN-promote-X.md` IMPL-tier ratification + `current-execution.md` proposal-count drift correction + project.md ADR rolling-window update
- If user defers / picks "wait" — proposal stays in `proposals/` with status unchanged

**Constraint**: User picks may take a few session-turns to drain (asynchronous). Track E is NOT a gate for IMPL — sessions S33-S36 + S41-S43 proceed regardless. Worst-case Phase 2 closes with N/9 proposals still PROPOSAL — that's acceptable per D-011 § Option C analysis.

**Dependencies**: NONE (fully parallel).
**Estimated session count**: 1-3 sessions (S38 + S39 + S40 if 3 batches OR S38 alone if user picks all 9 in single bundle dispatch — hybrid; actual count = function of user response cadence).
**Budget envelope**: ~30-50K per AskUserQuestion bundle × 3 = ~90-150K total. Total mostly user-time-bound, not token-bound.

### Track F — Thesis Pipeline 3-Perspective Real Implementation

**Goal**: Per spec 001 § B.2 Phase 1 simplifications → real Phase 2 implementation. Ship `BearPerspectiveAgent` + `BullPerspectiveAgent` + `QuantPerspectiveAgent` (real LLM calls; not stub) + `Phase1Synthesizer` (per § B.6 trade-off matrix + disagreement detection) + `ValidateThesisPhase1UseCase` orchestration (per § B.3) + Streamlit page `apps/dashboard/pages/validate_thesis.py` (per § B.7 — NEW path; `apps/dashboard/` does not yet exist per Glob check). All system_prompts grounded per § B.5 (categorical confidence Phase 1 heuristic per § B.2; cost budget enforcement $3 per validation per § A.3 AC-1; reproducibility per AC-5: same `(ticker, as_of, model_version, prompt_hash)` → same thesis).

**Sub-deliverables**:
- BC-8 Analysis domain: `packages/domain/analysis/{models,value_objects,services,repositories}/` (NEW; ~10 files; `Thesis` aggregate per spec 001 § A.4 + `PerspectiveAnalysis` + `Synthesis` + `TradeOffMatrix` + `GroundedPoint` + `ThesisRepository` Protocol)
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (NEW; per spec 001 § B.3 ValidateThesisPhase1UseCase)
- `packages/application/analysis/ports/{llm_perspective_port,cost_tracker_port}.py` (NEW; 2 files; LLM port abstracts Claude API; cost-tracker port enforces $3 ceiling)
- `packages/infrastructure/analysis/perspectives/{bear_agent,bull_agent,quant_agent}.py` (NEW; 3 files; per spec 001 § B.5)
- `packages/infrastructure/analysis/{phase1_data_gatherer,phase1_synthesizer,claude_llm_perspective_adapter,sqlite_thesis_repository}.py` (NEW; 4 files)
- `apps/dashboard/__init__.py` + `apps/dashboard/pages/validate_thesis.py` + `apps/dashboard/main.py` (NEW; 3 files; Streamlit entry per § B.7)
- `apps/cli/validate_thesis.py` (NEW; CLI alternative to Streamlit; same use case wired)
- Tests ≥40 PASS in <3s (mock LLM + mock data gatherer; NO live LLM in CI)
- Cross-BC contract event: `thesis_recorded` (`packages/contracts/events/thesis_recorded.py`)
- ≥5 REAL thesis output (Charter Month-3 SC-3): VN30 stocks; manual run via Streamlit; `real_thesis: true` frontmatter; saved to `agent-workspace/memory/thesis-log/YYYY-MM-DD-{ticker}.md`

**Hard-depends on**: Track B (multi-ticker BC-1 data) + Track C (Fundamental ratios for Quant agent) + Track D (news + claims for Bull/Bear agents).
**Soft-depends on**: Track E proposal `decision-discipline.md` user-approved (if approved → IMPL-tier sub-decisions in Track F land cleaner per Rule 2; else stays current ratification path).

**Estimated session count**: 3 sessions (S41 PLAN — spec-author and architect for BC-8 design + perspective-agent system prompts + LLM-port architecture; S42 MULTI_TASK_IMPL — domain + adapters + use case; S43a FOCUSED_IMPL — Streamlit page + CLI + 5-thesis dogfood run before final S43 VERIFY).
**Budget envelope**: ~50-80K (S41 PLAN) + ~200-240K (S42 MULTI_TASK_IMPL) + ~120-140K (S43a FOCUSED_IMPL) = ~370-460K cumulative for Track F.

---

## Dependency Graph

```
                          ┌──────────────────┐
                          │   S31 PLAN       │
                          │  (this file)     │
                          └────────┬─────────┘
                                   │
                                   ▼
        ┌──────────────────────────────────────────────┐
        │  S32 — Track A (R2 TCBS closure)             │  BLOCKER for B
        │  FOCUSED_IMPL ~120-140K                      │
        └────────────────────────┬─────────────────────┘
                                 │
              ┌──────────────────┼─────────────────────┐
              │                  │                     │
              ▼                  ▼                     ▼
   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
   │ S33 Track B     │  │ S34 Track C     │  │ S36 Track D     │
   │ VN30 BC-1       │  │ BC-2 Fund       │  │ BC-5 News stub  │
   │ MULTI ~180-220K │  │ MULTI ~180-220K │  │ MULTI ~200-240K │
   └────────┬────────┘  └────────┬────────┘  └────────┬────────┘
            │                    │                    │
            └────────────────────┼────────────────────┘
                                 │
                                 │   (B+C+D feed F)
                                 ▼
        ┌──────────────────────────────────────────────┐
        │  S41 — Track F PLAN (BC-8 architect)         │
        │  PLAN ~50-80K                                │
        └────────────────────────┬─────────────────────┘
                                 │
                                 ▼
        ┌──────────────────────────────────────────────┐
        │  S42 — Track F IMPL (BC-8 + agents)          │
        │  MULTI_TASK_IMPL ~200-240K                   │
        └────────────────────────┬─────────────────────┘
                                 │
                                 ▼
        ┌──────────────────────────────────────────────┐
        │  S43a — Track F UI + 5-thesis dogfood        │
        │  FOCUSED_IMPL ~120-140K                      │
        └────────────────────────┬─────────────────────┘
                                 │
                                 ▼
        ┌──────────────────────────────────────────────┐
        │  S43 — Phase 2 VERIFY (sandwich-verifier)    │
        │  VERIFY ~100-150K (per L-S21-1 calibrated)   │
        └──────────────────────────────────────────────┘

                  PARALLEL TRACK (does not gate any IMPL):
                  ┌─────────────────────────────────────┐
                  │ S38 / S39 / S40 — Track E proposals │
                  │ AskUserQuestion bundles 3 × 4 max   │
                  │ ~30-50K each session                │
                  └─────────────────────────────────────┘
```

**Critical path**: S32 → S33 → (S34 // S36 parallel-eligible) → S41 → S42 → S43a → S43.
**Parallel windows**: S34 + S36 may run interleaved (they don't share files; both depend on S33 only for cross-BC contract pattern reference). S38/S39/S40 fire on user-availability; do NOT block IMPL critical path.
**No-overlap rule**: S33 and S34 should NOT run in same calendar session-turn (high mypy/ruff concurrent-edit collision risk per L-S20-1 file-cycle hazard). S36 may follow either.

---

## Session Breakdown

### S32 — Track A R2 Closure (TCBS pivot)

| Field | Value |
|---|---|
| Type | FOCUSED_IMPL |
| Agent | main (Dev role) |
| Budget | ~120-140K |
| Predecessor | S31 (this plan) |
| Successor | S33 |
| Tier | IMPL — adapter pivot is library-choice IMPL-tier per D-003 doctrine; if A4 SCOPE-tier waiver triggers → escalate AskUserQuestion |

**Goal**: Discover/establish ≥2 working bar-source providers for ≥80% of VN30 (24/30 tickers). Execute strategy pick A1→A2→A3→A4 in order.

**Pre-flight reads** (≤5):
1. `agent-workspace/memory/checkpoints/latest.md` (S30 close — preconditions)
2. `agent-workspace/memory/checkpoints/phase-1-thin-slice-S29-verdict.md` § R2 (S29 verifier residue diagnosis)
3. `packages/infrastructure/market_data/{vnstock_adapter,tcbs_adapter}.py` (existing S28 deliverables; live behavior reference)
4. `agent-workspace/constitution/financial-data-protocol.md` Rule 4 (multi-source reconciliation binding)
5. context7 fetch `vnstock` 4.0.2 docs § alternative sources (DNSE / KBS / SSI backends)

**Deliverables** (file paths VBW-verified):
1. **EDIT** `packages/infrastructure/market_data/tcbs_adapter.py` ≤230 LOC (current 190 + ~40 LOC fix; A1 path probe OR replace with new backend if A2/A3) — VBW: file EXISTS at S28 close
2. **NEW** (if A2 picked) `packages/infrastructure/market_data/dnse_adapter.py` OR `kbs_adapter.py` OR (A3) `ssi_adapter.py` ≤180 LOC — implements `BarProviderPort`; same Protocol contract as vnstock_adapter
3. **EDIT** `apps/cli/ingest_vhm.py` ≤140 LOC (current 127 + ~13 LOC) — wire new backend into existing CLI for VHM smoke validation; VBW: file EXISTS at S28 close
4. **NEW** `data/vn30-coverage-S32.md` ≤80 LOC — coverage probe report: per-ticker per-source success/fail; total %; A2/A3/A4 pick rationale; sample 3 successful tickers + 3 failing tickers
5. **EDIT** `packages/infrastructure/market_data/test_adapters.py` ≤340 LOC (current 290 + ~50 LOC fixtures for new adapter); VBW: file EXISTS at S28 close
6. **NEW** `agent-workspace/memory/decisions/012-track-A-source-pivot.md` ≤140 LOC — 12-field schema; status ACCEPTED via IMPL-tier (or SCOPE-tier if A4 waiver triggers)
7. **EDIT** `agent-workspace/memory/current-execution.md` § Active Focus Track — append S32 row + R2 disposition

**Success criteria**:
- [ ] ≥2 backends operational on VHM (re-run S28 smoke; reconciliation report shows DUAL_SOURCE not SINGLE_SOURCE)
- [ ] Coverage probe ≥80% VN30 for ≥2 sources (or A4 waiver explicit)
- [ ] All existing 21 S28 tests still PASS (no regression on vnstock_adapter)
- [ ] mypy --strict + ruff: 0 errors on Phase 2 surface (ignore R1 Phase 0 baseline)
- [ ] D1 baseline still 0
- [ ] R2 disposition documented in D-012

**Risks**:
- A2 vnstock alt-sources also dropped (vendor drift L-S28-1 expanded) → escalate A3
- A3 SSI/VnDirect rate-limit aggressive (<1 req/2sec) → reduces effective throughput; document
- A4 SCOPE-tier waiver requires user-gate AskUserQuestion mid-session

### S33 — Track B VN30 Universe Expansion (BC-1)

| Field | Value |
|---|---|
| Type | MULTI_TASK_IMPL |
| Agent | main (Dev role) |
| Budget | ~180-220K |
| Predecessor | S32 |
| Successor | S34 (or parallel S36) |
| Tier | IMPL — universe constants + CLI generalization; SCOPE escalation only if VN30 list as-of needs verification beyond Glob+HOSE-portal-fetch |

**Goal**: Scale BC-1 ingestion VHM (1 ticker) → VN30 (30 tickers); 1-year backfill; nightly batch CLI; per-ticker reconciliation reports; ≥6,000 bars on disk.

**Pre-flight reads** (≤5):
1. S32 close + D-012 (which backends operational)
2. `packages/infrastructure/market_data/{vnstock_adapter,tcbs_adapter,reconciliation_service,sqlite_bar_repository}.py` (S28 deliverables — generalize patterns)
3. `apps/cli/ingest_vhm.py` (current single-ticker CLI; scale pattern reference)
4. `agent-workspace/proposals/financial-data-protocol-amendment-VN.md` Rule 14 (Sàn-tier reconciliation tolerance — proposal-only; reference for IMPL config defaults)
5. HOSE VN30 index list as-of 2026-04-30 (web fetch or vnstock `vn30()` endpoint) — cited in deliverable #1

**Deliverables** (VBW-verified):
1. **NEW** `packages/domain/market_data/value_objects/vn30_universe.py` ≤120 LOC — frozen list of 30 Tickers; source: HOSE VN30 listing as-of 2026-04-30; each entry has `(ticker, sàn=HOSE, sector, listing_date, vốn_hóa_tỷ_VND)` per amendment-VN Rule 14; VBW: directory EXISTS, file does NOT exist (NEW)
2. **NEW** `apps/cli/ingest_vn30.py` ≤180 LOC — CLI; `--start --end --output --rate-limit-rps`; orchestrates 30 × adapter calls with rate-limit budget (default 1 RPS per provider; 30s 429 backoff); writes to `./data/vn30.sqlite`; VBW: directory EXISTS, file does NOT exist (NEW)
3. **EDIT** `packages/infrastructure/market_data/sqlite_bar_repository.py` ≤230 LOC (current 205 + ~25 LOC) — extend to accept multi-ticker batched inserts (transaction per ticker; partial-failure tolerance); VBW: file EXISTS
4. **EDIT** `packages/infrastructure/market_data/reconciliation_service.py` ≤170 LOC (current 152 + ~18 LOC) — add `tolerance_for(bar)` method per amendment-VN Rule 14; default ±1% if amendment-VN not yet promoted; VBW: file EXISTS
5. **NEW** `data/vn30-reconciliation-summary.md` ≤120 LOC — table 30 rows ticker × source × bars-loaded × divergent-rows × confidence; produced by ingest_vn30.py at run-end
6. **EDIT** `packages/infrastructure/market_data/test_adapters.py` ≤400 LOC (extend with 10 NEW VN30-multi-ticker tests); VBW: file EXISTS
7. **NEW** `apps/cli/test_ingest_vn30.py` ≤140 LOC — CLI smoke tests; mocked adapters; VBW: directory EXISTS, file does NOT exist (NEW)
8. **EDIT** `agent-workspace/memory/current-execution.md` § Active Focus Track — S33 row

**Success criteria**:
- [ ] `python apps/cli/ingest_vn30.py --start 2025-04-30 --end 2026-04-29 --output ./data/vn30.sqlite --rate-limit-rps 1` exits 0; ≥6,000 bars on disk; ≥27/30 tickers populated (≥90% coverage)
- [ ] Reconciliation summary shows ≥80% rows DUAL_SOURCE (Rule 4 satisfied per ticker)
- [ ] All existing tests PASS (no regression); 10 NEW tests PASS
- [ ] mypy --strict + ruff: 0 errors on Phase 2 surface
- [ ] No vnstock or httpx import inside `packages/domain/**` or `packages/contracts/**` (grep returns 0)
- [ ] D1 baseline still 0
- [ ] cross-BC import grep: 0 hits
- [ ] BC-1 Bar entity unchanged (constructor signature stable; only repo + adapter scaling)

**Risks**:
- Rate-limit budget exceeded on 30-ticker × 250-day backfill = 7,500 calls per source × 2 sources at 1 RPS = ~4 hours; document acceptable for nightly batch
- 1-3 VN30 tickers may have data gaps (suspended periods, dividend-adjustment lookups) — log + continue per Q-S28-3 doctrine
- IMPL-S28-2 advisory ceiling expansion (some files already over master-plan ceilings) — accept; note in S43 verifier per IMPL-S28-2 documented

### S34 — Track C BC-2 Fundamental Ingestion + Ratio Compute

| Field | Value |
|---|---|
| Type | MULTI_TASK_IMPL |
| Agent | main (Dev role) |
| Budget | ~180-220K |
| Predecessor | S33 (or parallel-eligible S33+S34 same week) |
| Successor | S36 (or S41 if S36 already done parallel) |
| Tier | IMPL — adapter + service patterns mirror S27/S28 doctrine; ratio formulas IMPL-tier (textbook + audit comments) |

**Goal**: Ship BC-2 Fundamental aggregate + adapter + ratio compute service + repository per spec-T1-001 § B.1 + spec 001 § B.4 Phase1DataGatherer signature.

**Pre-flight reads** (≤5):
1. `specs/tier1-strategic/001-four-tier-signal-architecture.md` § B.1 (Fundamental schema)
2. `specs/tier2-feature/001-validate-investment-thesis.md` § B.4 (Phase1DataGatherer signature — `ratios_ttm` + `historical_percentiles` + `peer_comparables`)
3. `packages/domain/market_data/{models,repositories}/` (S27 BC-1 reference architecture; mirror for BC-2)
4. `agent-workspace/constitution/financial-data-protocol.md` Rule 1 (point-in-time `filing_date` ≤ as_of integrity binding for Fundamental queries)
5. context7 fetch vnstock or Vietstock financial-statements API docs

**Deliverables** (VBW-verified):
1. **NEW** `packages/domain/fundamental/models/financial_statement.py` ≤180 LOC — `FinancialStatement` entity per spec-T1-001 § B.1 (ticker + statement_type + period_end + filing_date + line_items + source_provider + adjustment_type)
2. **NEW** `packages/domain/fundamental/value_objects/{statement_type,line_item,ratio}.py` (3 files; total ≤180 LOC)
3. **NEW** `packages/domain/fundamental/services/{ratio_service,peer_service,percentile_service}.py` (3 files; total ≤350 LOC) — pure stdlib + Decimal; ratio formulas (P/E, P/B, ROE, Debt/Equity, Margin, ROA) audit-commented per textbook reference; `peer_service.get_comparables(ticker, sector_as_of)` returns 3-5 sector peers; `percentile_service.compute_historical_percentiles(ticker, years=5)` returns 5-yr distribution
4. **NEW** `packages/domain/fundamental/repositories/fundamental_repository.py` ≤80 LOC — Protocol; `get_as_of()` + `get_latest()`; NO `get_all()` per Rule 1
5. **NEW** `packages/infrastructure/fundamental/{vnstock_fundamental_adapter,sqlite_fundamental_repository}.py` (2 files; total ≤350 LOC)
6. **NEW** `apps/cli/ingest_fundamentals_vn30.py` ≤140 LOC — nightly batch
7. **NEW** `packages/contracts/events/financial_statement_filed.py` ≤60 LOC — cross-BC event
8. **NEW** Tests `packages/domain/fundamental/test_*.py` + `packages/infrastructure/fundamental/test_adapters.py` ≥30 tests total ≤500 LOC; ratio formula tests use textbook reference values
9. **EDIT** `packages/contracts/events/__init__.py` ≤30 LOC (current 9 + ~20 LOC; barrel export)

**Success criteria**:
- [ ] `python apps/cli/ingest_fundamentals_vn30.py --start 2024-Q1 --end 2026-Q1` exits 0; ≥360 statements on disk (30 tickers × 4 quarters × 3 statement types reasonable)
- [ ] All ratio service tests PASS with textbook reference values within ±0.01 tolerance
- [ ] Point-in-time integrity test: `get_as_of(ticker, 2025-06-15)` filters out filings with `filing_date > 2025-06-15` (look-ahead bias zero)
- [ ] No framework imports in domain layer
- [ ] Cross-BC import grep: 0 hits
- [ ] mypy --strict + ruff: 0 errors on Phase 2 surface
- [ ] D1 baseline still 0
- [ ] LLM-math creep grep ("approximately|around|roughly|~ %") in BC-2: 0 hits

**Risks**:
- vnstock financial-statements endpoint coverage <30/30 tickers — document; deferral acceptable on S43 verifier per Q-S28-3 doctrine
- Ratio formula off-by-one (TTM definition divergence between vnstock + Vietstock + textbook) — surface 3 candidate definitions, pick one with audit comment, defer alt-definitions to Phase 3 calibration
- Restated financials drift (per Rule 1 informational note) — Phase 2 stores latest filed; restatement tracking deferred

### S36 — Track D BC-5 News Stub + CafeF Scraper + LLM Extraction

| Field | Value |
|---|---|
| Type | MULTI_TASK_IMPL |
| Agent | main (Dev role) |
| Budget | ~200-240K |
| Predecessor | S34 (or parallel S34+S36) |
| Successor | S41 |
| Tier | IMPL for BC-5 entity + adapter + LLM port; SCOPE-tier escalation only if R2 raw-storage choice needs user-gate (recommend IMPL default = Postgres-only Phase 2) |

**Goal**: Ship BC-5 News Stream stub + CafeF first scraper + LLM claim-extraction service per spec-T1-001 § B.2 + Charter § Data Sources Phase 1.

**Pre-flight reads** (≤5):
1. `specs/tier1-strategic/001-four-tier-signal-architecture.md` § B.2 (News schema + LLM Role)
2. `agent-workspace/constitution/financial-data-protocol.md` Rule 6 (LLM Output Provenance) + Rule 7 (Sentiment Score Calibration — categorical not numeric) + Rule 8 (Anti-Look-Ahead in News)
3. `agent-workspace/constitution/invariants.md` § I-S1 (no LLM math) + I-1 (every claim has source_url)
4. `agent-workspace/proposals/provenance-protocol.md` (S2 proposal — Rule 6 enforcement reference; if user-approved Track E Bundle 1, becomes binding mid-S36)
5. CafeF robots.txt + sample article HTML (web fetch; verify scraping target stable)

**Deliverables** (VBW-verified):
1. **NEW** `packages/domain/news/models/{news_article,extracted_claim}.py` (2 files; total ≤280 LOC)
2. **NEW** `packages/domain/news/value_objects/{sentiment,extractor_metadata}.py` (2 files; total ≤120 LOC) — Sentiment 5-class StrEnum per Rule 7 categorical
3. **NEW** `packages/domain/news/services/claim_extraction_service.py` ≤150 LOC — orchestrator; calls LLM via port
4. **NEW** `packages/domain/news/repositories/{news_repository,claim_repository}.py` (2 files; total ≤120 LOC) — Protocols
5. **NEW** `packages/application/news/ports/llm_extractor_port.py` ≤80 LOC — Protocol abstracting Claude API
6. **NEW** `packages/infrastructure/news/{cafef_scraper,sqlite_news_repository,claude_llm_extractor}.py` (3 files; total ≤500 LOC)
7. **NEW** `apps/cli/ingest_news_cafef.py` ≤180 LOC — CLI; rate-limit 1 req/2sec respecting CafeF robots.txt + ToS; per-ticker filter via UL glossary mention detection
8. **NEW** `packages/contracts/events/{news_article_ingested,extracted_claim_published}.py` (2 files; total ≤120 LOC)
9. **NEW** Tests ≥35 PASS — fixture-based (recorded CafeF HTML + recorded LLM responses); NO live LLM in CI per Phase 0 discipline; total ≤600 LOC
10. **EDIT** `packages/contracts/events/__init__.py` (barrel export extension)

**Success criteria**:
- [ ] `python apps/cli/ingest_news_cafef.py --tickers VN30 --since 2026-04-01 --max-articles 100` exits 0; ≥50 articles on disk; ≥30 articles produce ≥1 ExtractedClaim each
- [ ] Every ExtractedClaim has source_url + source_text_excerpt + extractor_model + extractor_version + extracted_at + confidence_extracted (Rule 6 mandatory; schema NOT NULL enforced)
- [ ] Sentiment field is StrEnum 5-class; grep numeric-sentiment patterns: 0 hits per Rule 7
- [ ] LLM cost per article ≤$0.10 (Sonnet not Opus); session cost ≤$50 sandbox (CostTracker enforces)
- [ ] No framework imports in domain layer
- [ ] Cross-BC import grep: 0 hits
- [ ] mypy --strict + ruff: 0 errors
- [ ] D1 baseline still 0

**Risks**:
- CafeF HTML structure changes mid-Phase-2 (vendor drift hazard analogous to L-S28-1) — fixture-based tests catch regression; live re-run gracefully degrades
- ToS / robots.txt scraping legality — Charter § Data Sources Phase 1 explicitly authorizes "CafeF, NDH, VietnamBiz — news scraping" with rate-limit; document UA + contact email per spec-T1-001 § B.9
- LLM extraction hallucination (extracts ticker not actually mentioned) — Rule 6 + I-1 enforce source_text_excerpt grounding; verifier S43 spot-checks 5% of claims per Rule 6 enforcement
- Cost overrun if 30 VN30 × 50 articles/day × 30 days extraction → ~$4500/month worst-case → S36 hard-caps session at $50; full nightly automation deferred to Phase 3 with cron + budget enforcement
- Vietnamese sentiment classification accuracy — categorical 5-class is calibration-friendly but sentiment_distribution drift hazard; verifier S43 checks against eval-sets/historical-theses/SEED.md fixture

### S38, S39, S40 — Track E Proposal Promotion (PARALLEL)

| Field | Value |
|---|---|
| Type | FOCUSED_IMPL — small scope (composes AskUserQuestion + handles file-move + writes D-NNN ratification ADR per approval) |
| Agent | main |
| Budget | ~30-50K each |
| Predecessor | NONE (parallel) |
| Successor | NONE |
| Tier | CHARTER (proposal promotion = constitution edit; user explicit-approve via Charter Bundle gates) |

**Goal**: Drain 9-proposal queue. 3 bundles × 4-3-2 split per L-S15-1 multi-batch packing doctrine.

**Per-session deliverables** (VBW-verified):
1. AskUserQuestion bundle composed (Bundle 1: 4 CHARTER proposals; Bundle 2: 3 SCOPE; Bundle 3: 2 CHARTER amendment-VN)
2. Per user-approved proposal:
  - **MOVE** `agent-workspace/proposals/X.md` → `agent-workspace/constitution/X.md` (file-move via shell `mv`; preserves git history)
  - **NEW** `agent-workspace/memory/decisions/D-NNN-promote-X.md` ≤100 LOC — 12-field schema; status ACCEPTED via CHARTER-tier user-gate; references AskUserQuestion bundle + user pick
  - **EDIT** `agent-workspace/memory/project.md` § Recent ADRs (rolling 5-window update)
  - **EDIT** `agent-workspace/memory/current-execution.md` § proposal count drift correction (per S22 R1 fix doctrine)
3. Per user-deferred proposal: NO file move; status stays PROPOSAL; document deferral reason in session log

**Success criteria**:
- [ ] 0-9 proposals promoted (depending on user picks); each promotion has matching D-NNN ADR
- [ ] proposals/ directory consistent with constitution/ (no path drift)
- [ ] settings.json deny-list adjusted IF necessary (e.g., new constitution file added — CLAUDE.md hard rule binding immediately)
- [ ] Phase 2 close S43 captures final proposal queue state (residue documented)

**Risks**:
- User-deferred proposals stay in proposals/ indefinitely (R-9 from Phase 1 plan) — accept; document at Phase 2 close
- Inconsistency between proposal text and current code reality (proposal authored S2-S26; codebase evolved S23-S30) — pre-flight verify proposal target_section still applies before mv; if conflict → user decides amend vs reject

### S41 — Track F PLAN (BC-8 Architect)

| Field | Value |
|---|---|
| Type | PLAN |
| Agent | sandwich-architect subagent dispatch (~150-200K per L-S25-1 calibrated for spec+architect work; main session ~30-40K) |
| Budget | ~50-80K main + ~150K subagent dispatch |
| Predecessor | S33 + S34 + S36 (all 3 must be complete; F has hard-deps) |
| Successor | S42 |
| Tier | SCOPE — agent system_prompt designs + LLM-cost ceiling shape user-perceived behavior; recommend AskUserQuestion 1Q SCOPE-tier "QuantAgent uses Opus or Sonnet?" mid-S41 (default Opus per spec 001 § B.10) |

**Goal**: Author Phase 2 Track F implementation spec; design BC-8 Analysis aggregate; design 3 perspective-agent system_prompts grounded per spec 001 § B.5; design LLM-port + cost-tracker-port architecture; design Streamlit page wireframe.

**Pre-flight reads** (≤5):
1. `specs/tier2-feature/001-validate-investment-thesis.md` § A + § B (FULL — Phase 1 spec is now Phase 2 expansion target)
2. `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` (Phase 1 simplifications doctrine — what we kept stub vs what we now real-impl)
3. `agent-workspace/memory/thesis-log/_template.md` + `2026-04-30-VHM-exemplar.md` (existing format + 15 SQL queries pattern Track F UI must mirror)
4. `agent-workspace/constitution/invariants.md` § I-S1 + I-S10 + I-S11 + I-S12 + I-S35 (binding for BC-8)
5. `agent-workspace/memory/personal-risk-profile.md` (template; user-fill drives Track F risk-sizing — note S41 will surface this as P0 prerequisite if user has not yet filled)

**Deliverables** (VBW-verified):
1. **NEW** `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` ≤350 LOC — full SPEC_TEMPLATE structure; Part A business spec; Part B agent contract
2. **NEW** `agent-workspace/memory/decisions/D-013-track-F-architecture.md` ≤140 LOC — IMPL-tier (or SCOPE-tier if user-gate fired)
3. **NEW** `agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md` ≤300 LOC — S42+S43a deliverables matrix (per-session row format like Phase 1 plan 004)
4. **EDIT** `agent-workspace/memory/current-execution.md` — S41 row + Track F sub-plan reference

**Success criteria**:
- [ ] Spec 006 frontmatter has tier:2 + bounded_contexts:[Analysis, Market Data, Fundamental, News Stream] + ubiquitous_language_terms list
- [ ] Spec § B.5 includes 3 system_prompts (Bear, Bull, Quant) verbatim ≥40 LOC each; each has explicit "no LLM math" + "every claim cites source_url" instruction
- [ ] Spec § B.10 cost profile: target ≤$2 average, hard cap $3 per validation per AC-1
- [ ] Personal-risk-profile prerequisite surfaced (if user has not filled, S41 fires AskUserQuestion 1Q "fill now or proceed with default")
- [ ] D-013 has all 12 fields populated

**Risks**:
- Sub-plan over-scopes Track F → S42 budget overrun (calibrate against S27 actual ~150-180K vs S27 master-plan ~180-220K)
- QuantAgent Opus vs Sonnet choice = SCOPE-tier; user may pick Sonnet to halve cost (per spec § B.10 Opus = $0.70/run vs Sonnet ~$0.20/run)
- AskUserQuestion personal-risk-profile fill triggers user dialogue session-turns S41 may exit pending answer

### S42 — Track F IMPL (BC-8 Domain + Adapters + Use Case)

| Field | Value |
|---|---|
| Type | MULTI_TASK_IMPL |
| Agent | main (Dev half of sandwich; S43 Verifier closes) |
| Budget | ~200-240K |
| Predecessor | S41 |
| Successor | S43a |
| Tier | IMPL — entity design + adapter pattern follow architecture.md spec |

**Goal**: Ship BC-8 Analysis domain (~10 files) + adapters (4 files) + use case (1 file) + ports (2 files) per spec 006 deliverables matrix.

**Pre-flight reads** (≤5):
1. `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` (S41 spec)
2. `agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md` (S41 sub-plan)
3. `packages/domain/{market_data,portfolio}/` (S27 entity-pattern reference)
4. `packages/domain/news/` (S36 BC-5 reference for ExtractedClaim / Sentiment integration)
5. `agent-workspace/constitution/architecture.md` § BC-8 (existing reference)

**Deliverables** (VBW-verified) — ~16 files total (similar to S27 23-file scale; under 250K MULTI cap per L-S21 calibrated):
1. **NEW** `packages/domain/analysis/models/{thesis,perspective_analysis,synthesis}.py` (3 files; total ≤500 LOC)
2. **NEW** `packages/domain/analysis/value_objects/{trade_off_matrix,grounded_point,recommendation,confidence_level}.py` (4 files; total ≤300 LOC)
3. **NEW** `packages/domain/analysis/repositories/thesis_repository.py` ≤80 LOC
4. **NEW** `packages/application/analysis/use_cases/validate_thesis_phase1.py` ≤180 LOC (per spec 001 § B.3)
5. **NEW** `packages/application/analysis/ports/{llm_perspective_port,cost_tracker_port}.py` (2 files; total ≤120 LOC)
6. **NEW** `packages/infrastructure/analysis/perspectives/{bear_agent,bull_agent,quant_agent}.py` (3 files; total ≤450 LOC; per spec 001 § B.5 system_prompts)
7. **NEW** `packages/infrastructure/analysis/{phase1_data_gatherer,phase1_synthesizer,claude_llm_perspective_adapter,sqlite_thesis_repository}.py` (4 files; total ≤600 LOC)
8. **NEW** `packages/contracts/events/thesis_recorded.py` ≤60 LOC
9. Tests ≥40 PASS — mock LLM + mock data gatherer; total ≤700 LOC

**Success criteria**:
- [ ] `pytest packages/domain/analysis/ packages/application/analysis/ packages/infrastructure/analysis/` ≥40 PASS in <3s
- [ ] LLM port mocked in tests; NO live LLM in CI
- [ ] Bear case validation enforced (≥3 distinct points) per I-S10 — pytest constructs Thesis with 2-point bear case, expects InvariantViolation
- [ ] Disagreement preservation enforced per I-S12 — pytest constructs perspective list with opposing conclusions, asserts Synthesis carries `explicit_disagreements` non-empty
- [ ] Cost tracker enforced — pytest dispatches use case with $1 budget cap, asserts CostBudgetExceeded raised
- [ ] No framework imports in domain layer
- [ ] Cross-BC import grep: 0 hits
- [ ] mypy --strict + ruff: 0 errors
- [ ] D1 baseline still 0
- [ ] LLM-math creep grep in production code: 0 hits

**Risks**:
- 16-file MULTI risks budget overrun >250K — pre-flight projection at S42 entry; split into S42a (domain + ports) + S42b (adapters + use case) if projected >230K (mirror Phase 1 plan R1 doctrine)
- LLM perspective system_prompt prompts may need tuning post-S43a dogfood → S43 verifier surfaces; iterate at Phase 3 entry not S42
- ThesisRepository SQLite schema design may need migration support (Postgres deferred Phase 3; SQLite stable per spec 000 § A.6) — document migration path in D-013

### S43a — Track F UI + 5-Thesis Dogfood

| Field | Value |
|---|---|
| Type | FOCUSED_IMPL |
| Agent | main |
| Budget | ~120-140K |
| Predecessor | S42 |
| Successor | S43 |
| Tier | IMPL + 5 SCOPE artifact thesis (`real_thesis: true`) |

**Goal**: Ship Streamlit page + CLI alternative + run 5 real thesis on VN30 stocks; satisfy Charter Month-3 SC-3 + SC-4.

**Pre-flight reads** (≤5):
1. `specs/tier2-feature/001-validate-investment-thesis.md` § B.7 (Streamlit UI design)
2. `agent-workspace/memory/thesis-log/_template.md` + `2026-04-30-VHM-exemplar.md` (existing format)
3. `agent-workspace/memory/personal-risk-profile.md` (user-filled values inform Quant agent risk-sizing context)
4. context7 fetch Streamlit current-version docs § page navigation + caching
5. S42 close (BC-8 + use case wired)

**Deliverables** (VBW-verified):
1. **NEW** `apps/dashboard/__init__.py` ≤10 LOC + `apps/dashboard/main.py` ≤60 LOC (Streamlit entry)
2. **NEW** `apps/dashboard/pages/validate_thesis.py` ≤180 LOC (per spec 001 § B.7)
3. **NEW** `apps/cli/validate_thesis.py` ≤100 LOC (CLI alternative; same use case wired)
4. **NEW** `agent-workspace/memory/thesis-log/2026-MM-DD-{ticker}.md` × 5 files — REAL thesis (`real_thesis: true`); 5 different VN30 tickers chosen per user picks at S43a entry (recommend AskUserQuestion 1Q SCOPE-tier "Pick 5 VN30 stocks to dogfood" with default = first 5 alphabetical excluding VHM); each follows _template.md format with grounded numbers (Q1-Q15 SQL pattern from VHM exemplar)
5. Tests ≥10 PASS — UI smoke (Streamlit testapi); CLI smoke (Click CliRunner)

**Success criteria**:
- [ ] Streamlit page renders thesis card per spec 001 § A.4 schema
- [ ] CLI exits 0 for all 5 tickers; each thesis ≤5 minutes wall-clock; each thesis ≤$3 cost (CostTracker enforced)
- [ ] 5 thesis files have `real_thesis: true` + bear case ≥3 distinct points + every number traceable to SQL/tool-call audit comment
- [ ] Reproducibility: re-run 1 of 5 with same `(ticker, as_of)` → identical thesis_id + identical content (per AC-5)
- [ ] D1 baseline still 0
- [ ] LLM-math creep grep in thesis-log/ new files: 0 hits

**Risks**:
- 5-thesis × $3 ceiling = $15 sandbox; LLM cost overrun if perspective agents loop on retry — S43a hard-cap at $20 session budget
- Streamlit dependency installation (Phase 2 first frontend touch) — pin version in pyproject.toml; verify clean install
- AskUserQuestion at S43a entry blocks if user picks <5 tickers or defers — fall back to default 5

### S43 — Phase 2 VERIFY (Sandwich-Verifier Whole-Phase Review)

| Field | Value |
|---|---|
| Type | VERIFY |
| Agent | sandwich-verifier subagent dispatch (separate context per CLAUDE.md "same-agent self-review = echo chamber") |
| Budget | ~100-150K (per L-S21-1 calibrated whole-Phase verifier band; S29 actual ~98K reported) |
| Predecessor | S43a (final IMPL session) |
| Successor | Phase 3 entry (S44+) |
| Tier | read-only — verifier emits findings, doesn't decide |

**Goal**: Adversarial review of S32-S43a deliverables; verify zero LLM-math creep, zero charter violations, zero direct cross-BC imports; verify Phase 2 BC additions (BC-2, BC-5, BC-8) satisfy invariants by construction; confirm Track F use case satisfies spec 001 AC-1..AC-6; produce PASS / PASS-WITH-RESIDUE / FAIL verdict gating Phase 3 entry.

**Pre-flight reads** (≤5):
1. `agent-workspace/memory/checkpoints/latest.md` (S43a close — verifier's input snapshot)
2. `specs/tier2-feature/001-validate-investment-thesis.md` § A + § B (Phase 2 expansion target)
3. `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` (S41 spec — verifier checks Track F output)
4. `agent-workspace/constitution/architecture.md` + `invariants.md` + `financial-data-protocol.md` (binding rules)
5. 5 newly-shipped REAL thesis files at `agent-workspace/memory/thesis-log/` (S43a evidence)

**Deliverables** (VBW-verified):
1. **NEW** `agent-workspace/memory/observations/sandwich-verifier-S43-phase2-final.md` ≤300 LOC — full verifier return text mirror
2. **NEW** `agent-workspace/memory/checkpoints/phase-2-tier-1-2-S43-verdict.md` ≤180 LOC — checkpoint with verdict; if PASS-WITH-RESIDUE, enumerate residue items + Phase 3 disposition
3. **EDIT** `agent-workspace/memory/current-execution.md` — S43 row + Phase 3 entry preview

**V dimensions** (10 + Track-F-specific):
- V1 spec alignment (Phase 2 deliverables match spec 001 + spec-T1-001 + spec 006)
- V2 LLM-math creep = 0 (grep in BC-2 + BC-5 + BC-8 production code)
- V3 cross-BC import = 0 (grep)
- V4 invariant enforcement (BC-2 Rule 1 + BC-5 Rule 6/7/8 + BC-8 I-S10/I-S11/I-S12)
- V5 deterministic risk (BC-9 RiskRule unchanged)
- V6 source attribution (every News article + ExtractedClaim + FinancialStatement has source_provider non-null)
- V7 test count ≥120 NEW (S33 ~10 + S34 ~30 + S36 ~35 + S42 ~40 + S43a ~10 = ~125); combined Phase 1+2 ≥300 PASS in <5s
- V8 mypy --strict + ruff: 0 errors on Phase 2 surface
- V9 D1 baseline still 0
- V10 charter md5 stable (or 0-N proposals promoted via Track E with explicit user-gate trace per D-NNN ratifications)
- VF-1 Track F real thesis: 5 files; `real_thesis: true`; ≥3 bear points each; all numbers tool-call sourced
- VF-2 cost ceiling: 5 thesis cost ≤$15 total (per spec 001 § B.10 average ~$1.30 × 5 = $6.50; budget ceiling 5 × $3 = $15)
- VF-3 reproducibility: re-run 1 thesis → identical output

**Success criteria**:
- [ ] Verdict ∈ {PASS | PASS-WITH-RESIDUE | FAIL}
- [ ] All 10 V dimensions + 3 VF dimensions sampled with evidence
- [ ] If FAIL: gate Phase 3 entry; require RECOVERY session before Phase 3 PLAN
- [ ] Charter Month-3 SC-1..SC-4 mapping documented (spec-T1-001 SC-1 done; SC-2 partial 30/50; SC-3 done 5 thesis; SC-4 done <5min)

**Risks**:
- Verifier budget escalation per L-S21-1 (Phase 2 bigger surface than Phase 1 ~44 files; Phase 2 surface ~80-100 files) — provision 150K cap with auto-escalate via session-budgets.md `When to Escalate`
- 5-thesis dogfood quality — if any thesis has LLM-math creep or hallucinated source_url, R-class residue surfaces
- Phase 3 numbering question: S43 verifier should explicitly raise charter-numbering question for user pick (ratify D-011 re-numbering as durable OR keep executional-only)

---

## Budget Envelope

| Session | Type | Budget | Cumulative |
|---|---|---|---|
| S31 (this) | PLAN | 70-80K | 75K |
| S32 | FOCUSED_IMPL | 120-140K | 205K |
| S33 | MULTI_TASK_IMPL | 180-220K | 405K |
| S34 | MULTI_TASK_IMPL | 180-220K | 605K |
| S36 | MULTI_TASK_IMPL | 200-240K | 825K |
| S38 | FOCUSED_IMPL (parallel) | 30-50K | 865K |
| S39 | FOCUSED_IMPL (parallel) | 30-50K | 905K |
| S40 | FOCUSED_IMPL (parallel) | 30-50K | 945K |
| S41 | PLAN (subagent ~150K) | 50-80K main | 1010K |
| S42 | MULTI_TASK_IMPL | 200-240K | 1230K |
| S43a | FOCUSED_IMPL | 120-140K | 1370K |
| S43 | VERIFY | 100-150K | 1495K |

**Phase 2 envelope estimate**: **~860K-1.25M** main-session tokens + ~150K subagent dispatch (S41 architect + S43 verifier subagents combined ~250K) ≈ **~1.1M-1.4M cumulative** — calibrated +30-40% over D-011 abstract ~600-900K based on Phase 1 actual ~888-1023K (which itself was over master-plan abstract ~640-860K).

**Vs Phase 1 ~888-1023K**: Phase 2 is ~25-40% larger than Phase 1 due to:
- 3 NEW BCs activated (BC-2 + BC-5 + BC-8) vs Phase 1's 2 BCs (BC-1 + BC-9 first entities)
- VN30 scaling 30× ticker count
- LLM integration (first production LLM calls in BC-5 + BC-8)
- Full thesis pipeline UI

**Hard cap watch**:
- S33 MULTI at 220K, S34 MULTI at 220K, S36 MULTI at 240K, S42 MULTI at 240K — all approaching 250K cap; pre-flight projection at each session entry; split if projected >230K
- S43 VERIFY at 150K cap per L-S21-1 — escalate within session if exceeds (mirror S29 path)

---

## Risk Catalog

| # | Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|---|
| R1 | **Vendor API drift expansion** (L-S28-1 expanded VN30 scale) — 30 tickers × 2-3 sources × continuous backfill = surface where vnstock 4.0.x changes break ingestion mid-Phase | HIGH | MED | Pin vnstock version pyproject.toml; context7 fetch at each S32/S33/S34/S36 entry; fixture-based tests catch CI regression; per-ticker freshness sanity check in `data/vn30-reconciliation-summary.md` |
| R2 | **News scraping ToS legal surface** — CafeF + future NDH/VietnamBiz scrapers risk ToS violation if rate-limit drift or robots.txt change | MED | LOW | Charter § Data Sources Phase 1 explicit authorize; UA + contact email per spec-T1-001 § B.9; rate-limit 1 req/2sec floor; robots.txt re-check at S36 entry; pause if site terms change |
| R3 | **Claim extractor model+version drift** — LLM extractor outputs change with Claude Sonnet 4.6 → 4.7 → 5.0 transitions; reproducibility AC-5 broken silently | HIGH | MED | Rule 6 Provenance binding — extractor_model + extractor_version + extractor_prompt_hash recorded per claim; verifier S43 spot-checks 5%; calibration drift Tier 2 quality gate scheduled (charter Phase 4); pin model version in `claude_llm_extractor.py` config |
| R4 | **Tier 2 LLM cost budget overrun** — 30 VN30 × 50 articles/day × 30 days × $0.05/article ≈ $2250/month; thesis 5 × $3 = $15 dogfood; if ratio extraction adds → easily $3K+/month | HIGH | HIGH | Phase 2 cost cap session $50; nightly automation DEFER Phase 3 (manual S36 dogfood only); per-call budget enforcement via CostTracker; Sonnet not Opus for extraction; Opus only for synthesizer + Quant agent per spec 001 § B.10 |
| R5 | **R2 closure failure-mode** — Track A A1+A2+A3 all <80% VN30 coverage forces A4 SCOPE-tier waiver; Rule 4 reconciliation broken across VN30 | MED | MED | A4 waiver path documented; user-gate AskUserQuestion at S32 mid-session if A3 fails; Phase 2 ships single-source with explicit Rule 4 waiver in proposal/decision artifact; reconciliation logic unchanged (graceful single-source per IMPL-S28-3); Phase 3 hardening tasks document |
| R6 | **VN30 rate-limit pressure** — 30 tickers × 2-3 sources × 250-day backfill at 1 RPS = ~4-6 hours per nightly run; provider may throttle or 429; multi-day incomplete backfill | MED | HIGH | Provider rate-limit budget per IMPL-S28; 30s 429 backoff; resumable ingestion (per-ticker checkpoint); nightly batch tolerates partial completion (≥27/30 tickers = 90% acceptable per S33 success criterion); document IMPL-S33-N incomplete-coverage decision if <90% |
| R7 | **Thesis cost ceiling violation** (Track F dogfood) — 5-thesis × $3 cap is fragile; multi-perspective parallel calls + retry on bear-case <3 points + synthesizer Opus = easy overrun | MED | MED | CostTracker enforced per use case; per-perspective ≤$1 sub-budget; retry capped 1x; synthesizer fallback to Sonnet if Opus would breach; S43a session hard-cap $20 sandbox; if any thesis breaches $3, mark `cost_violation: true` in frontmatter and surface at S43 |
| R8 | **Personal-risk-profile.md unfilled** (Track F prerequisite) — user has not filled 33 placeholders as of S30 close; Quant agent risk-sizing context defaults; thesis quality reduced | LOW | HIGH | S41 PLAN session surfaces as P0 prerequisite via AskUserQuestion 1Q "fill now or proceed with default"; if user picks default, document IMPL-S41-N deviation; Phase 3 calibration feedback loop will re-surface |
| R9 | **9-proposal queue stale** (Track E) — user defers all 3 bundles; Phase 2 closes with 9 proposals still PROPOSAL; constitution unchanged; future amendments compound queue | MED | MED | Track E parallel non-blocking per D-011; S43 verifier captures final queue state; if queue grows >12 by Phase 3 entry, escalate as SCOPE-tier "constitution-amendment cadence broken" via dedicated AskUserQuestion |
| R10 | **Charter Month-3 SC-2 partial** (50 dossiers vs delivered 30) — honest framing acknowledged but Charter SC-2 unmet | LOW | HIGH (deterministic) | Phase 2 honest framing baked in (§ Charter Alignment); 20 mid-cap dossiers deferred to Phase 3 entry first sprint; document at Phase 2 close as carryover; not Phase 2 blocker |

---

## Anti-Patterns to Avoid

Per CLAUDE.md + Phase 1 lessons learned:
- **Mix PLAN+IMPL** in same session (Session 4 catastrophic; S31 = PLAN-only; S41 = PLAN-only; never combine with adjacent IMPL even if deliverable scope tempts) 
- **Speculative scaffolding** — Phase 2 BC-2/5/8 ship ONLY first entities + adapters per spec; full BC scope deferred Phase 3+ (per Charter "ship thin slices")
- **Write to constitution** — proposals only; user-gate via Track E per CLAUDE.md hard rule
- **Git commit** without explicit user request — stage only; report; user picks
- **Cross-BC imports** — IMPL-S27-1 doctrine binding (shared kernel via `packages/contracts/types/`)
- **Refactor adjacent unrelated code** — P3 surgical changes; touch only what task requires
- **Single-perspective thesis** (Track F) — bear case mandatory ≥3 distinct points per I-S10; `Thesis.submit()` validates
- **Same-agent self-review** — S43 = sandwich-verifier subagent dispatch; main session must NOT also verify
- **Numeric sentiment** in BC-5 — Rule 7 categorical 5-class StrEnum binding
- **Master-plan path drift** (L-S30-1 doctrine) — every deliverable path VBW-verified `ls`-checked NEW or EDIT-ratify; S31 self-applies this to Phase 2 plan

---

## Lessons-Learned Promotion Candidates

5 L-S* candidates from Phase 1 batched per Q-E2 phase-boundary doctrine — promote at Phase 2 close (S43 + lessons-learned ceremony) OR carry to Phase 3 if S43 budget tight:

| Candidate | Source | Promotion target |
|---|---|---|
| L-S25-1 | architect-spec-frame budget calibration (150-200K subagent vs 80K PLAN target) | `proposals/session-budgets-amendment.md` § "Architect subagent dispatch budget" — extends existing § Verifier sub-section |
| L-S26-1 | master-plan contradiction resolution doctrine (Option B separate proposals over master-plan abstract count) | `proposals/decision-discipline.md` § "Spec contradiction resolution" Rule 4 |
| L-S27-1 | cross-BC VO placement doctrine (ubiquitous VOs → contracts/types/) | `proposals/architecture-amendment.md` § "Cross-BC value object placement doctrine" |
| L-S28-1 | vendor-API surface drift PLAN→IMPL (vnstock 4.0.2 dropped TCBS source) | `proposals/architecture-amendment.md` § "Adapter library surface lock-in" |
| L-S30-1 | PLAN-tier deliverable VBW pre-flight (master-plan path drift bug avoidance) | `proposals/decision-discipline.md` § "Plan deliverable VBW" Rule 5 |

Phase 2 will likely add new L-S* candidates (Track A vendor pivot doctrine; Track D LLM cost-budget enforcement doctrine; Track F multi-perspective system_prompt-grounding doctrine). Inventory at S43.

---

## Phase 3 Entry Preview

**Phase 3 (re-numbered per D-011 doctrine; original Charter Phase 2 Edge Sources = Tier 3+4)**: KOL ingestion (BC-6 Influence Network) + crowd sentiment ingestion (BC-7 Crowd Sentiment) + pump detection per Charter Month-6 + Month-9 success criteria. Spec 002 (Influence Network Tracking) + spec 003 (Crowd Sentiment Pump Detection) become binding. Whisper transcription + YouTube channel monitoring + Facebook fanpage scraping + Telegram public-channel ingestion ship. Calibration database first real per-KOL hit-rate computation. Per-KOL credibility score Bayesian confidence interval. Estimated envelope ~1.0-1.5M cumulative (similar Phase 2 scale + Whisper compute infrastructure). Pre-requisite: Phase 2 verdict PASS (S43); 9-proposal queue ≤2 still PROPOSAL; vnstock + CafeF stable; Charter Month-3 SC fully satisfied except SC-2 partial.

Phase 3 ALSO carries ~20 mid-cap dossier backfill (Charter Month-3 SC-2 closeout — 30+20=50). Phase 4 (re-numbered) = full 6-perspective thesis + Karpathy outer loop per spec 004 + spec 005.

---

## Ratification Path

| Decision | Tier | Ratification path |
|---|---|---|
| **This master plan (file 005-S31-...md)** | **IMPL** | ACCEPTED-via-IMPL-tier — agent autonomous; no user-approve required; S32 starts upon next user "continue" or session-start |
| **Track A pivot pick A1/A2/A3** | **IMPL** | locked by adapter-library doctrine; S32 picks; A4 waiver = SCOPE escalation |
| **VN30 universe list (S33)** | **IMPL** | sourced from HOSE VN30 listing as-of 2026-04-30; if listing changes mid-Phase 2 → IMPL-tier rebalance |
| **Track E proposals 9-batch promotions** | **CHARTER** | each user-gated via Track E AskUserQuestion bundles S38/S39/S40 per Q-B2 doctrine "charter MUST require explicit letter pick" |
| **QuantAgent Opus vs Sonnet (S41)** | **SCOPE** | mid-S41 AskUserQuestion 1Q if budget concern; default Opus per spec 001 § B.10 |
| **5-VN30-stock thesis pick (S43a)** | **SCOPE** | mid-S43a AskUserQuestion 1Q user picks 5 VN30 stocks; default = first 5 alphabetical excluding VHM |
| **Phase 2 close → Phase 3 entry (S43)** | **SCOPE** | S43 close AskUserQuestion phase-boundary user pick |
| **D-011 re-numbering audit** (Phase 2 = D-011 vs Charter Phase 2 = Edge Sources) | **CHARTER** | S43 surfaces as user-gated 1Q "ratify re-numbering as durable OR keep executional-only"; recommend latter |

**Total user-approve gates in Phase 2**: ~3-5 (Track A SCOPE if A4 fires + S41 SCOPE QuantAgent if budget concern + S43a SCOPE 5-stock picks + S43 phase-boundary + Track E batches per user pacing).

**Default if user does not respond**: Per autonomous_mode=true, Recommended option proceeds; SCOPE-tier explicit only stalls (current-execution.md tracks status); session HALTS at user-gate point and posts to `human-workspace/q-and-a/pending/`.

---

## Files Created by This Plan (S31 deliverable)

1. `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` (this file)

That's it for S31. All session files (S32-S43 plans NOT yet authored as separate files — this master plan IS the directive; per Q-D1 keep-flat resolution, S32-S43 may author per-session plans inline at their entry OR consume this master plan directly; S41 will explicitly author `006-S41-track-F-impl-sub-plan.md` because Track F has 3-session sub-sequence S42+S43a worth its own composition).

---

## Connection to Charter + Constitution + Spec

| Source | Section | How this plan honors |
|---|---|---|
| `PROJECT_CHARTER.md` § Phase 2 (Month 6) | All 4 success criteria (1=Tier1+2 done; 2=30/50 partial; 3=5 thesis done; 4=`/thesis-validate` <5min done) | Phase 2 close (S43) maps Track A+B+C → SC-1 + 30 of 50 (SC-2 partial) + Track F → SC-3 + SC-4 |
| `PROJECT_CHARTER.md` § Core Principles | All 10 | Honored throughout: P1 evidence (every claim source_url + as-of); P2 structured (trade-off matrix); P3 adversarial (BearAgent mandatory); P4 proprietary moat (BC-5 news + BC-8 thesis log accrue); P9 NO LLM math (Quant agent tool-call only); P10 deterministic risk (RiskRule unchanged); P7 dogfood (5 real thesis at S43a) |
| `specs/tier1-strategic/001-four-tier-signal-architecture.md` | § B.1 + § B.2 + § B.6 + § B.7 + § B.8 | Track B (B.1 Tier 1 sources) + Track C (B.1 fundamentals storage) + Track D (B.2 Tier 2 news + LLM extraction roles) + Track F (B.5 cross-tier synthesis stub for Phase 1+2 simplifications); B.6 storage = Postgres-only Phase 2 (R2 deferred); B.7 cadence = Track B nightly 16:00 + Track D 10-min poll dogfood-only; B.8 cost profile honored ($10-15M VND/month max — Phase 2 dogfood capped lower) |
| `specs/tier2-feature/001-validate-investment-thesis.md` | § A + § B (FULL) | Track F real implementation; Phase 1 simplifications → Phase 2 expansion path; AC-1..AC-6 binding for S43a + S43 |
| `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` | § A.5 Out-of-Scope items | Phase 2 closes 7 of 10 (Tier 2 Fundamental + Tier 2 News + Full VN30 + LLM extraction in production + News ingestion + `/thesis-validate` automation + 5 thesis recorded); 3 still out (Tier 3 KOL = Phase 3; Tier 4 Crowd = Phase 3; multi-currency = Phase 3+) |
| `agent-workspace/constitution/architecture.md` | § BCs + Folder Conventions + Cross-BC Rules | Phase 2 activates BC-2 + BC-5 + BC-8 first entities; mirrors S27 BC-1 + BC-9 pattern |
| `agent-workspace/constitution/financial-data-protocol.md` | Rule 1, 4, 5, 6, 7, 8, 9 | Track B Rule 4 reconciliation; Track C Rule 1 point-in-time; Track D Rule 6 + 7 + 8; spec 002 (KOL Rule 9) deferred Phase 3 |
| `agent-workspace/constitution/invariants.md` | I-S1, I-S2, I-S5, I-S10, I-S11, I-S12, I-S35 | Track F enforces I-S10 + I-S11 + I-S12; Track D enforces I-1 + I-2; all tracks enforce I-S1 |
| `agent-workspace/CLAUDE.md` | Contract Rules 1-7 | All honored; Rule 1 (constitution immutable) preserved via Track E proposals/ routing; Rule 6 (no commit) preserved |

---

## Self-Track Token Estimate (S31 = this plan)

This plan ~600 LOC of markdown + 9 reads of source files (predecessor 004-S24, spec-T1-001, spec 001, spec 000, current-execution, charter, architecture, financial-data-protocol, financial-data-protocol-amendment-VN, agent-workspace/CLAUDE.md, invariants partial, proposals listing):

- Pre-flight reads ~35-40K (10 files × 3-5K each)
- Plan composition ~25-30K (600 LOC × ~40 tokens/line)
- Tool overhead ~15K
- **S31 self-track estimate**: ~75-85K (within PLAN ~80K target; slight overrun risk acceptable per L-S25-1 calibrated)

---

## End of Plan

> Next action: User runs `/session-start` (or types "continue" if autonomous) → S32 SessionStart fires (no AskUserQuestion required at S32 entry; Track A pick A1→A2→A3→A4 ladder is IMPL-tier autonomous unless A4 waiver triggers) → S32 IMPL executes per § S32 above.
