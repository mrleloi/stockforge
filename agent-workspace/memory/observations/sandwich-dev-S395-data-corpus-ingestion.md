---
observation_type: sandwich-dev-return
session_id: S395
plan_ref: 045-S393-data-corpus-ingestion-operational-plan
authored: 2026-05-17
agent: sandwich-dev (S395; fresh-context subagent dispatched from main session)
model: Claude Sonnet 4.6 (sandwich-dev subagent)
session_type: MULTI_TASK_IMPL
status: PARTIAL-COMPLETE — corpus ingestion DONE; validate_thesis BLOCKED-BY-cost-cap
---

# S395 sandwich-dev return — Data Corpus Ingestion Operational Plan-045

## (a) STEP outcomes

### STEP 0 — VBW probes (ALL PASS)
- STEP 0.1 CafeF adapter: PASS (CafeFAdapter + CafeFScraper + RateLimiter verified; robots_manager.py exists)
- STEP 0.2 SSI adapter: PASS (SsiAdapter at `:63` SSI iBoard URL; ingest_vhm.py --ticker accepts arbitrary VN30)
- STEP 0.3 vnstock fundamental adapter: PASS (VnstockFundamentalAdapter verified; --tickers CSV flag at `:63-67`)
- STEP 0.4 cold probe VHM × CafeF: PASS (exit 0; 11 articles parsed; 2 VHM mentions)
- STEP 0.5 baseline: PASS (all tables exist; all counts = 0 before ingestion)

### STEP 1 (CafeF news) — PARTIAL (gaps cleared; quality floor not met)
- 128 articles ingested across 4 section listings
- Per-ticker mention counts: VHM=3, HPG=1, VIC=6, FPT=9
- ALL 4 tickers have ≥1 article in 90d window → `no_news_90d` gap CLEARED
- DoD-quality floor (≥30 per ticker): NOT MET
- Root cause: CafeFScraper.discover() does single-page scrape (no pagination). Each section page yields ~60 article-pattern URLs. Plan's 800-article assumption relied on pagination that doesn't exist. Scraping 4 sections × ~60 = ~240 article URLs, many yielding None on fetch_article; ~128 parseable total.

### STEP 2 (SSI bars) — FULL PASS
- 114 bars per ticker (57 trading days × 2 sources: vnstock VCI + SSI iBoard)
- All 4 tickers: PASS (≥30 bars in 90d window)
- Latest bar date: 2026-05-15 (2 days before as-of; within 3-day stale threshold)
- `price_stale` gap CLEARED for all 4 tickers
- TCBS: 404 for all 4 (expected per D-012)

### STEP 3 (fundamentals) — FULL PASS
- 12 statements per ticker (4 quarters × 3 statement types: IS+BS+CF)
- All 4 tickers: PASS (≥1 of each statement type)
- Latest period: 2026-03-31 (most recent Q)
- `fundamentals_stale` gap CLEARED for all 4 tickers
- vnstock 4.0.2 community edition limits to 4 periods per statement type (confirmed)

### STEP 4 (post-fetch verification) — PASS (with PARTIAL note for news)
- Bars: all 4 tickers PASS (≥30)
- News: all 4 tickers gap-clear PASS (≥1 in 90d); DoD-floor PARTIAL (3/1/6/9 vs ≥30)
- Fundamentals: all 4 tickers PASS (IS+BS+CF ≥1 each)
- Theses: 0 (correct before STEP 5)

### STEP 5 (validate_thesis VHM) — BLOCKED-BY-cost-cap

**Root cause**: The HARD CAP `Decimal("3.00")` at `packages/application/analysis/use_cases/validate_thesis_phase1.py:189` is too tight for 6-persona V0=6 run via subagent transport.

**What happened**:
1. Data context gathered successfully — `context.has_critical_gaps()` returned FALSE
2. The 3 corpus gaps were absent from context: no `price_stale`, no `fundamentals_stale`, no `no_news_90d`
3. 6 personas started in parallel (asyncio.gather): BEAR=Sonnet, BULL=Haiku, QUANT=Opus, BUFFETT/GRAHAM/TALEB=Opus
4. BULL persona (Haiku) returned prose instead of JSON (subagent read CLAUDE.md system context and treated it as session-orchestration task)
5. 2 retry attempts for BULL; other 5 personas completed (expensive Opus calls)
6. Total cost: $4.24 > $3.00 hard cap → CostBudgetExceeded raised
7. Thesis written to thesis-log with `gaps: ['cost_budget_exceeded']` (NOT corpus gaps)
8. Thesis NOT persisted to SQLite (BR-6)

**Inline-fix scope**: The fix requires increasing `limit_usd` at `validate_thesis_phase1.py:189` OR making it configurable. This file is in `packages/application/analysis/use_cases/` = `packages/**` = FORBIDDEN per plan § F without AP-1 escalation to human. The `--max-cost-usd` CLI flag is ignored (use_case_builder.py:109: `_ = max_cost_usd # cost cap is the use-case's $3 hardcoded ceiling per BR-6`) — by-design per BR-6.

**PFP-DONE-7 status**: NOT MET (thesis NOT persisted)
**PFP-DONE-8 status**: PARTIAL (LLM WAS called; corpus WAS assembled without corpus gaps; cost cap hit after data-gather)

**Key evidence that corpus IS ready** (DoD from plan § G.5):
- thesis-log frontmatter `gaps: ['cost_budget_exceeded']` — does NOT contain `price_stale`, `fundamentals_stale`, `no_news_90d`
- The INCOMPLETE-corpus early-return at `validate_thesis_phase1.py:213-214` did NOT fire
- The corpus conditions are met; the only blocker is BR-6 $3.00 hard cap vs. 6-persona cost

### STEP 6 (optional HPG/VIC/FPT re-runs) — SKIPPED
Per DD-7 + DD-6: STEP 5 VHM mandatory failed (cost-cap, not corpus). Optional re-runs for HPG/VIC/FPT skipped since the same cost-cap issue would repeat.

### STEP 7 (commit) — PARTIAL
- Committed ingestion artifacts (bars/news/fundamentals)
- thesis-log/2026-05-17-VHM.md committed (INCOMPLETE; cost_budget_exceeded)
- verification report committed
- current-execution.md: NOT updated (PFP-DONE-7+8 NOT flipped; blocked)

---

## (b) Per-cell fetch counts

| Source | VHM | HPG | VIC | FPT |
|---|---|---|---|---|
| Bars (rows) | 114 | 114 | 114 | 114 |
| News (total articles) | 3 | 1 | 6 | 9 |
| News (in 90d window) | 3 | 1 | 6 | 9 |
| Statements IS | 4 | 4 | 4 | 4 |
| Statements BS | 4 | 4 | 4 | 4 |
| Statements CF | 4 | 4 | 4 | 4 |

**Delta from baseline** (all counts started at 0):
- Bars delta: +114 per ticker (total +456 rows)
- News delta: +3/+1/+6/+9 (total +128 rows in news_articles; +0 extracted_claims since --skip-llm)
- Fundamentals delta: +12 per ticker (total +48 rows)

---

## (c) thesis-log evidence + cost-ledger

**VHM thesis-log**: `agent-workspace/memory/thesis-log/2026-05-17-VHM.md`
- thesis_id: incomplete
- status: incomplete
- gaps: `['cost_budget_exceeded']`
- cost_usd: 0 (incomplete thesis reports 0; actual spend tracked via SubagentStop hook)
- NOTE: cost_usd in thesis-log is 0 for incomplete theses; actual Anthropic spend was $4.24 (reported by CostBudgetExceeded exception)

**Cost-ledger**: Stop hook auto-populates `agent-workspace/memory/cost-ledger.tsv`; S395 IMPL session cost TBD (current context token count unavailable to dev agent; will be populated by Stop hook)

**Actual LLM spend** (from validate_thesis output):
- VHM dogfood attempt 1: $4.24 (exceeded $3.00 cap; not logged in cost-ledger as a separate thesis entry)

---

## (d) PFP-DONE-7+8 flip evidence

- PFP-DONE-7 (thesis persisted to SqliteThesisRepository): **NOT MET** — thesis in DB: 0 rows
- PFP-DONE-8 (live LLM empirical validation): **PARTIAL** — LLM called; corpus gaps absent; cost cap hit post-data-gather

The 3 corpus gaps from S384 thesis-log are CLEARED:
```
S384: gaps: ['price_stale', 'fundamentals_stale', 'no_news_90d']
S395: gaps: ['cost_budget_exceeded']  <- corpus gaps ABSENT
```

The Wave 1 MVP READY transition is BLOCKED-BY-cost-cap (not BLOCKED-BY-corpus).

---

## (e) LOC count (exact integers per L-S389-1)

New files created:
- `agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md`: 113 lines
- `agent-workspace/memory/observations/sandwich-dev-S395-data-corpus-ingestion.md`: this file
- `agent-workspace/memory/sessions/2026-05-17-session-395.md`: TBD

Modified files:
- `data/stockforge.sqlite`: binary DB (not committed; gitignored)
- `agent-workspace/memory/thesis-log/2026-05-17-VHM.md`: 31 lines (overwritten by validate_thesis; same as S384 INCOMPLETE exemplar)

Production code changes: 0 LOC (operational session — no .py changes)

---

## (f) Deviations from plan

1. **News DoD-quality floor not met**: plan assumed ≥30 articles per ticker via 800-article scrape across 2 listings. Actual: 128 articles total (CafeF single-page discovery, no pagination). Gap-clear requirement MET (≥1 in 90d), quality floor NOT MET. Scraper architecture limitation (single-page discover, no pagination support). Resolution: per DD-6 continue-and-flag; news PARTIAL does not block bars/fundamentals/validate_thesis.

2. **Column name**: `news_articles.mentioned_tickers_json` (actual) vs `mentioned_tickers` (plan STEP 5 SQL). All queries adjusted.

3. **Shell path expansion (Windows)**: Git Bash expands `/thi-truong-chung-khoan.chn` to C:/Program Files/Git path. Workaround: use subprocess.run() with list args from Python.

4. **validate_thesis cost-blocker**: $3.00 BR-6 hard cap exceeded by 6-persona V0=6 run ($4.24 actual). This is NOT an inline-fixable deviation — the limit_usd is hardcoded in packages/application/analysis/use_cases/validate_thesis_phase1.py:189 (packages/** forbidden scope).

5. **dogfood_session hardcoded to S384**: validate_thesis.py:241 has `"dogfood_session: S384"` hardcoded. Thesis written with S384 instead of S395. Minor cosmetic issue; does not affect PFP-DONE-7+8 assessment.

---

## (g) Escalation to main session

**HARD BLOCKER for PFP-DONE-7**: `validate_thesis_phase1.py:189` hardcodes `limit_usd=Decimal("3.00")` which is insufficient for 6-persona V0=6 run ($4.24 actual cost). To flip PFP-DONE-7, one of these actions is required:

**Option A (preferred)**: Increase or make configurable the `limit_usd` in `validate_thesis_phase1.py:189`. Suggested value: `Decimal("6.00")` or `Decimal("12.00")`. This is a `packages/**` change requiring separate IMPL session.

**Option B**: Reduce personas to 3 (BEAR/BULL/QUANT only) by removing BUFFETT/GRAHAM/TALEB from `_build_subagent_agents()` in `apps/_shared/use_case_builder.py`. This is in `apps/_shared/` (NOT packages/**) — potentially inline-fixable. Would reduce per-run cost to ~$2-3 range.

**Option C**: Accept PARTIAL status — wave 1 MVP READY-DATA-PENDING with corpus-gap clearance evidence; PFP-DONE-8 PARTIAL (live LLM validated corpus-ready path, not full thesis); PFP-DONE-7 deferred to Phase F.5-V2 with higher cost cap.

Main session decides which option. This observation surfaces the finding per plan § H RM4 escalation trigger.

---

## Handoff Notes for S397 verifier (if dispatched)

1. Verify STEP 5 SQL queries by re-running `data-corpus-ingestion-S395-verification-report.md` SQL battery against `data/stockforge.sqlite`
2. Confirm `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` gaps field = `['cost_budget_exceeded']` (NOT corpus gaps)
3. Confirm `SELECT COUNT(*) FROM theses WHERE ticker='VHM'` = 0 (not persisted per BR-6)
4. Confirm bars count: `SELECT ticker, COUNT(*) FROM bars WHERE ticker IN ('VHM','HPG','VIC','FPT') GROUP BY ticker` → 114 per ticker
5. Confirm fundamentals: all 3 statement types per ticker present
6. Review ESCALATION § (g) above — main session decision required before PFP-DONE-7 can be flipped
