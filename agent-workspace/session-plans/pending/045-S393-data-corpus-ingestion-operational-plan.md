---
plan_id: 045-S393-data-corpus-ingestion-operational-plan
target_session: S395 (or S394 if S392 G.1 architect returns first; either-order parallel-eligible per parent plan-040 § N + main session orchestration)
type: OPERATIONAL (NOT new code; uses existing crawlers/adapters; sub-plan to Wave 1 MVP CODE-READY-DATA-PENDING → READY transition; PARALLEL with Phase G-prime sub-plans 041-044 per § N below)
budget: ~150-180K Opus PLAN authoring envelope THIS session (architect; operational-plan-author tends lighter than architect-design-plan per L-S369-1 — fewer DDs + more procedural STEPs; aim ≤180K target within 150-230K Opus PLAN cap). IMPL session = MULTI_TASK_IMPL Opus 200-330K envelope (4 tickers × 3 sources × cold-probe per-cell = ~15-30min estimated wall-clock plus per-persona LLM validate_thesis re-run at HARD CAP $3/ticker per Charter calibration); alternatively split into 2 FOCUSED_IMPL Opus 100-150K sessions (1=ingest only / 2=validate_thesis re-run + thesis-log) — DD-7 below.
phase: Phase F-prime Wave 1 MVP DATA-CORPUS (operational track; CODE-READY-DATA-PENDING → READY transition; flips PFP-DONE-7 (thesis persistence) + PFP-DONE-8 (live LLM empirical validation) from PENDING to GREEN; SEPARABLE from Phase G-prime per architect-design intent at plan-038 § A.3 + AQ-3)
track: Wave 1 MVP — Real-API data corpus ingestion for VHM+HPG+VIC+FPT × (CafeF news + R2/SSI bars + BC-2 fundamentals); satisfies Charter Principle 7 user-gate via S391 Q1=A authorization captured at current-execution.md:140
parent_master_plan: Wave 1 MVP CODE-DONE-DATA-PENDING attestation at current-execution.md § "S383-S386 — Phase F-prime Wave 1 MVP CODE-READY-DATA-PENDING" (lines 189-216); operational-track separation per plan-038 § A.3 (DATA-PENDING legitimate per AQ-3); user-authorization at current-execution.md:140 (S391 Q1=A)
predecessor: 038-S383-phase-f5-cli-dogfood-vhm-thesis (F.5 SHIPPED at S384 commit 94030a0; INCOMPLETE-corpus path legitimate per AQ-3; thesis-log/2026-05-17-VHM.md INCOMPLETE with gaps ['price_stale', 'fundamentals_stale', 'no_news_90d']); 039-S387-harness-stabilization-sweep-N1 (SHIPPED at S388 commit 78089ba; harness sweep enables this operational session without HARD-BLOCK)
successor_candidate: NONE explicit — operational sub-plan; on PASS = PFP-DONE-7+8 flip to GREEN = Phase F-prime FULLY DONE = Wave 1 MVP READY; main session may then dispatch Phase H-prime / Phase 2 entry per master plan § 6
architect: S393 sandwich-architect (background; THIS plan-authoring session — parallel with S392 G.1 architect per current-execution.md:143-146)
dispatched_by: main session orchestrating Phase F-prime DATA-PENDING gate satisfaction per S391 user-authorization Q1=A; parallel with S392 architect-tier per architect-tier precedent S345 4-parallel
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; operational-plan task_class; Phase 1b ≥3 sub-tracks INVOKED but COLD-START declared for task_class="data-corpus-operational" — no precedent in .planner-stats.tsv; nearest analog crawler-adapter-impl n=3 from S338+S344+S354 patterns existing-CLI-driver-runs)
executing_agent: N/A this session (architect); S395 (or S394) sandwich-dev executes per § E sub-tracks STEP 1-7
status: partial-complete (S395 executed 2026-05-17; corpus ingestion DONE; validate_thesis BLOCKED-BY-cost-cap; escalation in human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md; PFP-DONE-7 NOT MET; PFP-DONE-8 PARTIAL; plan stays in pending/ until main session resolves cost-blocker)
executing_agent: S395 sandwich-dev (Claude Sonnet 4.6; dispatched by main session per plan-045 § N)

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"
  - "STOCKFORGE_SKIP_PRECOMMIT_PYTEST env bypass available per S388 D2 promote (use only if dev commit times out on full pytest re-run; default OFF — operational session expected to add 0 production code lines, so regression risk is LOW)"

depends_on:
  - "Phase F-prime F.5 SHIPPED at S384 commit 94030a0 — apps/cli/validate_thesis.py at 410 LOC + --run-mode=dogfood flag + V0=6 markdown render (see apps/cli/validate_thesis.py:97-103 click option `--run-mode`); INCOMPLETE-corpus early-return at packages/application/analysis/use_cases/validate_thesis_phase1.py:213-214 `if context.has_critical_gaps(): return Thesis.incomplete(...)` bypasses Step 6 save at :280 → no Thesis aggregate persisted in current state; corpus-ready re-run flips this GREEN"
  - "Phase F-prime CODE-DONE-DATA-PENDING attestation at S386 (current-execution.md:191-199); PFP-DONE-1..6+9 GREEN; PFP-DONE-7 PENDING (thesis NOT persisted) + PFP-DONE-8 PARTIAL (I-S35 PASS empirical; live LLM empirical validation at corpus-ready re-run) + PFP-DONE-10 PENDING-this-commit; corpus-ready re-run is the trigger to flip 7+8 to GREEN"
  - "S391 user-authorization Q1=A captured at current-execution.md:140 — Full corpus 4 tickers × 3 sources AUTHORIZED for VHM+HPG+VIC+FPT × (CafeF news + R2/SSI bars + BC-2 fundamentals); Charter Principle 7 dogfood + real-API-budget user-gate satisfied"
  - "S391 user-authorization Q2=D captured at current-execution.md:141 — Continue UNCALIBRATED-V0 path; calibration_grade='D' default per validate_thesis.py:52 preserved; no calibration-cycle work blocks this operational session"
  - "Existing apps/cli/ingest_vhm.py (full 143 LOC; per-ticker VHM bars driver via VnstockAdapter + SsiAdapter + TcbsAdapter + ReconciliationService; default --output=./data/vhm.sqlite — STEP 0.2 MANDATES override to data/stockforge.sqlite for validate_thesis consumption)"
  - "Existing apps/cli/ingest_news_cafef.py (full 325 LOC; CafeF news driver via CafeFAdapter wrapping CafeFScraper; default --output=./data/vn30-news.sqlite — STEP 0.1 MANDATES override to data/stockforge.sqlite; supports --tickers VHM,HPG,VIC,FPT subset per :180-192 _resolve_universe; --listing CSV per :202-216 _scrape_articles; coarse ticker-mention scan per cafef_scraper.py:135-160 to_news_article — NEWS IS PER-LISTING NOT PER-TICKER, so reaching ≥30 articles per ticker requires large --max-articles cap covering multiple section listings)"
  - "Existing apps/cli/ingest_fundamentals_vn30.py (read first 100 LOC; vnstock VCI driver via VnstockFundamentalAdapter; default --output=./data/vn30-fundamentals.sqlite — STEP 0.3 MANDATES override to data/stockforge.sqlite; supports --tickers VHM,HPG,VIC,FPT subset per :64-67; QUARTERLY frequency only per vnstock_fundamental_adapter.py:15 docstring — ANNUAL deferred to Phase 3)"
  - "Existing packages/infrastructure/news/cafef_scraper.py (read offset 60-160; discover() at :75-99 listing-page-scrape pattern; fetch_article() at :101-133 graceful-fail on parse failure per L-S28-1; to_news_article() at :135-160 coarse VN-ticker mention scan — ticker.symbol verbatim case-sensitive match in title+body_text)"
  - "Existing packages/infrastructure/news/crawler_adapters/cafef_adapter.py (full 238 LOC; CrawlerAdapter ABC implementation Strategy B WRAP per plan 020; rate_limiter + robots_manager + raw_html_sink optional injections; I-S34 compliance NO patchright/playwright_stealth/StealthyFetcher per :73-76; Rule 16 ZERO numeric fields per :78-82)"
  - "Existing packages/infrastructure/market_data/ssi_adapter.py (read first 100 LOC; SsiAdapter at :88-100 with fetch_daily(ticker, start, end) at :125 — TradingView-style endpoint at iboard-api.ssi.com.vn returns THOUSAND VND prices; HARD CAP +1 retry on 429/503 via SsiApiError; S32 Track A R2 closure D-012 — SSI iBoard primary alternate when TCBS 404s)"
  - "Existing packages/infrastructure/fundamental/vnstock_fundamental_adapter.py (read first 100 LOC; VnstockFundamentalAdapter with fetch_statements() at :143 — vendor-key→canonical LineItemKey mapping at :54-90 covers IS+BS+CF; vnstock 4.0.2 Finance API QUARTERLY only)"
  - "Existing packages/infrastructure/fundamental/sqlite_fundamental_repository.py (read offset 100-160; INSERT OR REPLACE INTO financial_statements at :101 → idempotency by-construction; get_as_of() at :116-146 returns ASC ordered by period_end+statement_type; count() at :156-159)"
  - "Existing packages/infrastructure/market_data/sqlite_bar_repository.py (Grep verified; INSERT OR REPLACE INTO bars at :101 → idempotency by-construction; save_many() at :94 + save_many_by_ticker() at :113)"
  - "Existing packages/infrastructure/news/sqlite_news_repository.py (Grep verified; INSERT OR REPLACE INTO news_articles at :93 + extracted_claims at :203 → idempotency by-construction; both tables 'INSERT OR REPLACE so idempotent re-runs converge' per :15 docstring; get_known_as_of() at :103 + get_for_ticker() at :217)"
  - "Existing apps/_shared/use_case_builder.py:_SubagentDataGatherer (read offset 370-490; reads bars via SqliteBarRepository.get_as_of + statements via SqliteFundamentalRepository.get_as_of + news via SqliteNewsRepository.get_known_as_of with 90d post-filter at :456-462 + claims via SqliteClaimRepository.get_for_ticker; gaps detection at :465-471 → 'price_stale' if bars empty OR (as_of - bars[-1].period_end).days > 3 / 'fundamentals_stale' if statements empty / 'no_news_90d' if recent_news empty — these are the exact 3 gaps in S384 thesis-log/2026-05-17-VHM.md:13)"
  - "Existing data/stockforge.sqlite (canonical DB consumed by validate_thesis per validate_thesis.py:65 `--db` default; populated by S43a Stage A ingest patterns per use_case_builder.py:374 docstring; STEP 0.5 baseline `sqlite3 .tables` + COUNT(*) WHERE ticker IN ('VHM','HPG','VIC','FPT') before STEP 1)"
  - "Existing apps/_shared/crawl/rate_limiter.py (read first 50 LOC; per-domain RateLimiter with exponential backoff + jitter; DomainState; D-059 R1 compliant via time.monotonic(); ported from crawl4ai Apache-2.0 + Attribution per :1-3; BC-5 reliability skill skill .claude/skills/crawler-reliability/SKILL.md applies)"
  - "Existing apps/_shared/crawl/robots_manager.py + raw_html_sink.py (Glob verified existence; BC-5 reliability substrate available for STEP 2 CafeF bulk fetch IF the dev decides to wire it for raw-HTML preservation per skill § Storage)"
  - "S384 thesis-log/2026-05-17-VHM.md (full 33 LOC; INCOMPLETE-corpus exemplar shows gaps=['price_stale', 'fundamentals_stale', 'no_news_90d'] = EXACTLY 3 gaps to close in this operational session; status=incomplete; thesis_id=incomplete; cost_usd=0 because no LLM call fired post-early-return)"
  - "S391 dispatch context at current-execution.md:143-150 — S392 G.1 architect dispatched in parallel (file scope=packages/_shared/pdf/**); S393 (THIS) architect file scope=data/stockforge.sqlite + apps/cli/; disjoint per current-execution.md:147-150"
  - "D-060 commit-policy-agent-may-commit (current-execution.md:183) — dev MAY git commit at coherent checkpoints; agent MUST NOT git push; commits each thesis-log file + optional ADR D-080 IF cost-attestation per-ticker warrants per DD-8 below"
  - "Charter v1.1 Principle 1 (NO LLM math — operational ingestion preserves this; LLM only runs during validate_thesis re-run which already enforces I-S1 by-construction via Phase1Synthesizer deterministic aggregation; no new LLM-math surface) + Principle 2 (every claim has source + as-of date — ingested news/bars/statements all preserve source_url + as_of via existing UPSERT schemas) + Principle 7 (dogfood mandatory — THIS IS THE DOGFOOD; Wave 1 MVP READY transition) + Principle 8 (calibration over confidence — per S391 Q2=D continue UNCALIBRATED-V0; thesis cost+quality observation files capture per-persona empirical evidence for future calibration cycle)"
  - "I-S1 (NO LLM math) BY-CONSTRUCTION preserved — operational; no new compute path / I-S2 (citation discipline — ingested rows already carry source_url + period_end + filing_date + ingested_at per existing schemas) / I-S10 (bear case ≥3 distinct points) BY-CONSTRUCTION at validate_thesis use case enforcement / I-S12 (Disagreement Surfaced) BY-CONSTRUCTION at synthesizer / I-S20 (calibration over confidence — Q2=D applies) / I-S34 (public sources only — CafeF + SSI iBoard + vnstock VCI guest tier; all free-tier public APIs; ZERO paid/insider channels; STEP 0.1-0.3 re-verifies per Charter) / I-S35 (research-aid framing — thesis output already enforced via apps/cli/validate_thesis.py:46-53 _DISCLAIMER_MD)"
  - "L-S32-1 SKILL.md empirical-probe-first doctrine (.claude/skills/empirical-probe-first/SKILL.md) APPLIES — STEP 0.4 mandates cold-probe ONE ticker (VHM smallest expected) × ONE source (CafeF) before bulk-fetch to verify wire works + capture empirical baseline wall-clock + row count"
  - "L-S385-2 attestation-vocabulary discipline (CODE-DONE-DATA-PENDING / READY-DATA-PENDING / BLOCKED-BY-X) APPLIES — IMPL session attestation MUST use this vocabulary; e.g. POST-IMPL = 'Wave 1 MVP READY' if all DoDs PASS / 'BLOCKED-BY-rate-limit' if RM1 fires / 'PARTIAL-WAVE1' if some tickers fail per DD-6 continue-others policy"
  - "L-S345-1 architect-LOC-drift-target ≤25 LOC per file claim (n=11 evidence at S385; main session inline-fix path) — operational plan touches mostly data/ + thesis-log/ markdown files; LOC drift discipline less load-bearing for operational than code-plan; apply best-effort"
  - "L-S369-1 ADR empirical close-verify spot-check (PROMOTED at S388 D5) — IF ADR D-080 ships in this operational session per DD-8 below, dev MUST run scripts/hooks/adr-empirical-close-verify-spot-check.sh + spot-check ≥3 close-claims (e.g. row-count claims, cost-attestation claims) for divergence-vs-actual"
  - "L-S366-3 cultural-anchor frozenset audit-trail (PROMOTED at S388 D6) — N/A this operational session (no new cultural-anchor frozenset additions expected)"
  - "L-S382-1 ctor-signature-change discipline (PROMOTED at S388 D2) — N/A this operational session (zero new production .py classes expected per § F file scope; ctor changes only if RM3 forces inline-fix per AP-1 mandate)"
  - "skill .claude/skills/crawler-reliability/SKILL.md (BC-5 News reliability substrate — Rate Limiting + Selector Robustness + Storage R2 layout; STEP 2 CafeF bulk-fetch SHOULD use RateLimiter with base_delay=2.0 per CafeFScraper:69 _RATE_LIMIT_SECONDS; raw_html_sink OPTIONAL per dev preference; robots_manager OPTIONAL per dev preference — CafeF robots.txt allows /thi-truong-chung-khoan.chn historically)"
  - "skill .claude/skills/empirical-probe-first/SKILL.md (probe-then-commit doctrine; STEP 0.4 cold-probe gate)"

binding_decisions:
  - "OPERATIONAL TRACK (NOT new code) — this plan ships zero production .py code changes; all work via existing CLI drivers (apps/cli/ingest_vhm.py + apps/cli/ingest_news_cafef.py + apps/cli/ingest_fundamentals_vn30.py) writing to canonical data/stockforge.sqlite via existing repositories; ZERO touches to packages/** per § F file scope; minor touches OK to apps/cli/validate_thesis.py ONLY if RM-bug surfaces during re-run per AP-1 mandate (separate inline-fix commit if so)"
  - "CANONICAL DB = data/stockforge.sqlite (per validate_thesis.py:65 + use_case_builder.py:374); 3 existing ingest CLIs default to DIFFERENT files (vhm.sqlite + vn30-news.sqlite + vn30-fundamentals.sqlite) → DEV MUST USE --output data/stockforge.sqlite EVERY invocation; STEP 1 + STEP 2 + STEP 3 + STEP 4 all enforce this override"
  - "4-TICKER SCOPE = VHM + HPG + VIC + FPT (per S391 Q1=A authorization at current-execution.md:140); both HOSE-listed VN30 blue-chips; SSI iBoard available for all 4 (HOSE coverage standard); vnstock VCI guest tier covers all 4 (Phase 2 thin slice scope)"
  - "VALIDATE_THESIS RE-RUN SCOPE = VHM MANDATORY + HPG/VIC/FPT OPTIONAL per DD-7 below; STEP 6 mandatory; STEP 6.2-6.4 optional per dev/main-session decision; cost-bounded by validate_thesis HARD CAP $3.00/ticker per validate_thesis_phase1.py:189 scoped_budget(limit_usd=Decimal('3.00'))"
  - "EMPIRICAL-PROBE-FIRST gate at STEP 0.4 — cold-probe VHM × CafeF (smallest expected size + earliest-shipped adapter) BEFORE STEP 2 bulk fetch; verifies wire works + captures empirical baseline; reject-and-flag if cold-probe FAILS (does NOT silently proceed — RM6 vendor-schema-change canary)"
  - "IDEMPOTENCY BY-CONSTRUCTION — all 3 SQLite repositories use INSERT OR REPLACE (verified: sqlite_bar_repository.py:101 + sqlite_news_repository.py:93+203 + sqlite_fundamental_repository.py:101); re-running ingestion converges to same state; STEP 0.5 baseline 'before' counts + STEP 5 'after' counts validate this"
  - "FAILURE-POLICY per DD-6 = CONTINUE-OTHERS-AND-FLAG-END-OF-RUN (not abort) — one-ticker-one-source failure logs + continues; STEP 5 verification report enumerates per-cell PASS/FAIL; STEP 7 thesis-log files only authored for tickers with FULL corpus (all 3 sources non-zero); PARTIAL tickers flagged in dev observation"
  - "PUBLIC SOURCES ONLY — I-S34 + Charter Principle 'No insider information' preserved by-construction (CafeF public website + SSI iBoard public chart API + vnstock VCI guest tier public); ZERO paid leaks / ZERO insider channels / ZERO scraping bypass; STEP 0.1-0.3 re-verifies adapter source-attribution"
  - "VBW protocol mandatory — every architect claim cites source file:line; dev STEP 0 re-verifies before any execution"
  - "Karpathy P2 simplicity-first — operational session = bare minimum; reuse existing CLIs as-is; only add --output override flags; no refactoring; no new abstractions"
  - "Karpathy P3 surgical-changes — touch only data/ + thesis-log/ + (conditionally) ADR D-080; ZERO touches to packages/** or .claude/ or constitution/"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN+IMPL; architect tools: [Read, Glob, Grep, Write])"
  - "no commits in THIS plan-session by architect (sandwich-architect has no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no overlap with S392 G.1 architect file scope (S392 = packages/_shared/pdf/** + packages/application/fundamental/** + packages/infrastructure/fundamental/pdf_*.py; THIS S393 = data/stockforge.sqlite + apps/cli/ + agent-workspace/memory/thesis-log/ + optional D-080) — disjoint per current-execution.md:147-150"
  - "no modification of existing plans in pending/ or completed/ (plan-040 master plan + plan-038 F.5 + others) — read-only references"
  - "no reuse of plan numbers 040-044 (reserved by plan-040 § N); use 045 only — verified via `Glob agent-workspace/session-plans/pending/*.md` → next free = 045"
  - "no /master-plan or any Skill invocation per Q-2.1=B (skills only in SUPERVISED mode; this is autonomous-full operational dispatch)"
  - "no Bash execution by architect (architect tools per .claude/agents/sandwich-architect.md: [Read, Glob, Grep, Write]); STEP 0 probes are READ-only via Read tool; dev IMPL session executes Bash"
  - "no Phase G-prime sub-plan file touches (041/042/043/044 reserved by plan-040 § N parallel-architect file scope)"
  - "no charter amendment from THIS plan — operational uses existing user-authorized adapters; no I-S<N>-tier surface; § J below explicitly attests NONE expected"
  - "no harness/hook changes — operational session ships data ingestion; surface any harness gaps in observation; do NOT fix here (harness in steady-state per S390 commit e5f17cf)"
  - "every plan claim cites source file:line (per I-S2 + AOM + VBW protocol)"
  - "actual files read via Read tool, not from memory (VBW protocol; this session read validate_thesis.py 1-410 + use_case_builder.py 370-490 + validate_thesis_phase1.py 200-300 + ingest_vhm.py 1-143 + ingest_news_cafef.py 1-325 + ingest_fundamentals_vn30.py 1-100 + 3 SQLite repos via Grep + cafef_scraper.py 60-160 + cafef_adapter.py 1-238 + ssi_adapter.py 1-100 + vnstock_fundamental_adapter.py 1-100 + rate_limiter.py 1-50 + thesis-log/2026-05-17-VHM.md 1-33 + plan-040 frontmatter + plan-038 1-150 + current-execution.md 1-230)"
  - "ZERO new external dependencies — all 3 ingest CLIs use existing pyproject.toml deps (httpx + vnstock + click + bs4); ZERO new dep adds in this operational session"
  - "READ-ONLY on agent-workspace/research/ + agent-workspace/master-plans/ + PROJECT_CHARTER.md + AGENT_OPERATING_MANUAL.md (referenced for context only)"
---

# S393 — Data-Corpus Operational Ingestion for Wave 1 MVP READY transition (PLAN)

> **One-sentence intent**: Execute real-API ingestion of VHM+HPG+VIC+FPT × (CafeF news + R2/SSI bars + BC-2 fundamentals) into canonical `data/stockforge.sqlite` via existing CLI drivers, verify non-zero corpus per (ticker × source) cell, and re-run `apps/cli/validate_thesis.py --ticker VHM --run-mode=dogfood` so that the INCOMPLETE-corpus early-return at `validate_thesis_phase1.py:213-214` does NOT fire, the Step 6 save at `:280` fires, the Thesis aggregate persists to SqliteThesisRepository, and PFP-DONE-7+8 flip from PENDING to GREEN — unlocking Wave 1 MVP READY without writing new production code.

---

## A. Goal & Scope

### A.1 Goal

Ship the **Wave 1 MVP CODE-READY-DATA-PENDING → READY transition** via real-API ingestion populating `data/stockforge.sqlite` for 4 VN30 blue-chip tickers (VHM, HPG, VIC, FPT) × 3 data sources (CafeF news, R2/SSI bars, BC-2 vnstock fundamentals), producing:

- **Non-zero corpus per (ticker × source) cell** — 12 cells (4 tickers × 3 sources) ALL non-zero rowcount in `data/stockforge.sqlite` (verified via `SELECT COUNT(*) ... WHERE ticker IN ('VHM','HPG','VIC','FPT')`)
- **Per-cell quality thresholds** — ≥30 CafeF news articles per ticker (sentiment-meaningful baseline; DD-3); ≥30 trading days SSI bars per ticker (TWAP-meaningful; DD-2 = 90d default); ≥1 fundamental statement per ticker (most-recent quarter per DD-4)
- **Non-INCOMPLETE validate_thesis VHM re-run** — `python apps/cli/validate_thesis.py --ticker VHM --run-mode=dogfood --as-of <today>` completes WITHOUT hitting the INCOMPLETE-corpus early-return at `validate_thesis_phase1.py:213-214 (if context.has_critical_gaps())`; Step 6 save at `:280` fires; Thesis aggregate persists to SqliteThesisRepository; new `agent-workspace/memory/thesis-log/2026-05-XX-VHM.md` written with `status: submitted` (or legitimate `incomplete` for non-corpus-related reason like I-S10 bear-case-invariant-failed)
- **PFP-DONE-7+8 GREEN flip** — Phase F-prime DONE-grid items 7 (thesis persisted) + 8 (live LLM empirical validation) attested GREEN per `current-execution.md:197-198` revision
- **Optional per-ticker re-runs for HPG/VIC/FPT** — per DD-7, OPTIONAL; main session decides at dispatch time
- **Optional ADR D-080 cost-attestation** — per DD-8, IF ≥2 ticker re-runs ship, ADR D-080 captures per-ticker $ + tokens + wall-clock cost rollup for future calibration cycle; OTHERWISE single-ticker (VHM) cost recorded only in thesis-log frontmatter `cost_usd:` field

### A.2 In-scope (this operational sub-plan ships)

This sub-plan ships:

1. **STEP 0 — Empirical-probe-first VBW probes + cold-probe gate** (target: 5 probe sub-steps STEP 0.1-0.5 verifying existing adapter code paths + DB baseline BEFORE bulk-fetch begins; cold-probe ONE cell (VHM × CafeF) gates STEP 2-4 bulk; reject-and-flag if cold-probe fails per RM6 vendor-schema-change canary; ~10-15 min wall-clock; 0 production code changes)

2. **STEP 1 — STEP 0 probes + cold-probe gate execution** (target: dev runs all STEP 0.1-0.5 probes + collects baseline `sqlite3 data/stockforge.sqlite '.tables'` + `SELECT COUNT(*) FROM bars WHERE ticker IN ('VHM','HPG','VIC','FPT')` + same for `news_articles` + `financial_statements`; ~5 min wall-clock)

3. **STEP 2 — CafeF news bulk fetch (4 tickers)** (target: `python apps/cli/ingest_news_cafef.py --tickers VHM,HPG,VIC,FPT --max-articles 800 --output data/stockforge.sqlite --skip-llm --listing /thi-truong-chung-khoan.chn,/doanh-nghiep.chn` — multiple listings via CSV per ingest_news_cafef.py:202-216 quota-per-listing pattern; --skip-llm avoids extra Anthropic spend in pure-ingestion mode; ~10-20 min wall-clock per CafeFScraper rate_limit=2sec × ~400 articles per listing; expected ≥30 articles per ticker via coarse-mention scan over ~800 total articles)

4. **STEP 3 — R2/SSI bars bulk fetch (4 tickers)** (target: run `apps/cli/ingest_vhm.py` 4× with `--ticker {VHM,HPG,VIC,FPT} --output data/stockforge.sqlite --start <today-90> --end <today>` per DD-2 90d window; each invocation calls VnstockAdapter + SsiAdapter + (TcbsAdapter graceful-fail per D-012) + ReconciliationService + SqliteBarRepository.save_many; ~2-5 min wall-clock per ticker × 4 tickers = ~10-20 min total; expected ≥30 trading days bars per ticker for 90d window)

5. **STEP 4 — BC-2 vnstock fundamentals fetch (4 tickers)** (target: `python apps/cli/ingest_fundamentals_vn30.py --tickers VHM,HPG,VIC,FPT --output data/stockforge.sqlite --rate-limit-rps 0.3` — vnstock VCI guest tier hard cap; per-ticker partial-failure tolerance per ingest_fundamentals_vn30.py:10-11; ~3-5 min wall-clock per ticker × 3 statement types (IS+BS+CF) × 4 tickers = ~10-20 min total; expected ≥1 fundamental statement per ticker per DD-4 most-recent-quarter mandate)

6. **STEP 5 — Post-fetch DB verification queries** (target: dev runs `sqlite3 data/stockforge.sqlite` queries capturing per-(ticker × source) cell rowcounts + per-ticker MAX(period_end) for bars/statements + per-ticker COUNT(news_articles) with mentioned_tickers JSON match + writes verification report to `agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md` (~50-100 LOC markdown summary; one row per cell per DoD § G))

7. **STEP 6 — validate_thesis CLI re-run for VHM (mandatory) + optional HPG/VIC/FPT** (target: `python apps/cli/validate_thesis.py --ticker VHM --transport subagent --as-of <today> --run-mode dogfood --db data/stockforge.sqlite` MANDATORY; STEP 6.2-6.4 same for HPG/VIC/FPT OPTIONAL per DD-7; expected exit 0 OR exit 2 if I-S10 BearCaseInvariantError legitimate; expected wall-clock ~3-5 min per ticker × 6 personas × ~30s/persona LLM call; expected cost ≤ $3.00 HARD CAP per validate_thesis_phase1.py:189; new `agent-workspace/memory/thesis-log/YYYY-MM-DD-{TICKER}.md` written per validate_thesis.py:158-162)

8. **STEP 7 — Thesis-log observation files + commit** (target: 1-4 thesis-log markdown files created by STEP 6 invocations; commit via `git add agent-workspace/memory/thesis-log/2026-05-XX-VHM.md && git commit -m 'S<N>: Phase F-prime Wave 1 MVP DATA-CORPUS ingestion + VHM dogfood re-run — PFP-DONE-7+8 GREEN'` per D-060; optional ADR D-080 cost-attestation per DD-8 IF ≥2 ticker re-runs ship)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| **New code** (production .py changes) | Operational track; uses existing adapters; new code path = separate sub-plan | New-code trigger: RM-bug surfaces during STEP 2/3/4/6 → AP-1 inline-fix path with separate commit per L-S345-1 |
| CafeF crawler enhancements (per-ticker landing pages, multi-listing rotation, dedicated company-page scrape) | Phase D Theme L SHIPPED at S338-S358; existing CafeFAdapter Strategy B WRAP path proven; ≥30 articles/ticker baseline achievable via coarse-mention scan over 800 total articles | CafeF-enh trigger: STEP 2 yields <30 articles for any ticker → separate Phase D-N optimization sub-plan |
| SSI adapter direct httpx changes (multi-resolution, intraday, weekly) | Phase 1 thin slice; ingest_vhm.py uses DAILY only at SsiAdapter.fetch_daily; multi-resolution = Phase 2-3 scope | SSI-resolution trigger: Phase 2 entry + project-owner directive for intraday or weekly bars |
| vnstock fundamental adapter ANNUAL frequency expansion | vnstock_fundamental_adapter.py:15 QUARTERLY only Phase 2 thin slice; ANNUAL deferred per docstring | Annual trigger: Phase 2 percentile-service entry needs 5-yr percentile_service backfill OR PDF-extraction Phase G-prime sub-plan 044 ships first annual report path |
| New ADR (operational-track ADR-merit decision) | Per DD-8 below — optional ADR D-080 IF ≥2 ticker re-runs ship for cost-attestation; default = NO ADR (cost recorded in thesis-log frontmatter only) | ADR-trigger: dev decides at STEP 7 IF cost-attestation rollup ≥2 tickers warrants D-080 |
| Phase G-prime sub-plans G.1-G.4 (PDF + table extraction) | Plan-040 master plan § E + sub-plan 041 architect-tier dispatch in PARALLEL this turn; OUT-OF-SCOPE this operational sub-plan | Phase G-prime dispatch trigger: main session reviews S392 G.1 architect output + dispatches sub-plan 041 IMPL per plan-040 § N |
| Multi-source bar reconciliation (TCBS) | TcbsAdapter graceful-fail per D-012; ingest_vhm.py:91-96 already handles TcbsApiError graceful per existing pattern; expected SSI + VCI only contribute non-zero bars | TCBS trigger: D-012 superseded by new TCBS endpoint discovery |
| Calibration database scaffolding (per-thesis outcome tracking) | Per S391 Q2=D continue UNCALIBRATED-V0; calibration cycle deferred indefinitely per current-execution.md:141 | Calibration trigger: systematic-bias evidence in downstream E.3+ sentiment outputs per Q2 acceptance criteria |
| Streamlit dashboard rendering of dogfood thesis | Phase H-prime per master plan § 6.4.5; not on Wave 1 MVP critical path | Dashboard trigger: Phase H-prime entry |
| Per-persona retry-validator stress test | D-054 B5 3-attempt retry-validator existing pattern; F.5 dogfood NATURALLY exercises retry; not separate stress | Trigger: STEP 6 reveals >50% retry rate on any persona → separate F.5-V2 retry tuning |
| Outer-loop calibration database for thesis outcomes | Charter Principle 8 — post-MVP; thesis-log markdown is V0 sufficient | Calibration trigger: n≥10 dogfood theses + project-owner directive for outer-loop calibration DB |
| KOL ingestion (Vietnamese pundit Telegram/Facebook) | Phase 3.5 per Charter; not Wave 1 MVP | Phase 3.5 entry per master plan § A.3 |
| Pump detection (đội lái signals) | Phase 4 per Charter; not Wave 1 MVP | Phase 4 entry per master plan § A.3 |
| FiinPro fundamentals (paid API) | Phase 2-3 per spec § A.2 line 142 | FiinPro trigger: Phase 2-3 entry + user-authorization for paid spend |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START declared on task_class)

**Source files read** (VBW empirical, ALL via Read/Grep/Glob — architect has no Bash):

1. `agent-workspace/memory/current-execution.md` (1-230 LOC; full top context + S391 dispatch table + Phase F-prime CODE-DONE-DATA-PENDING attestation at S386 + harness sweep N+1 SHIPPED at S390)
2. `PROJECT_CHARTER.md` (1-100 LOC; Charter v1.1 Principles 1-11)
3. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` (frontmatter 1-100 + § A 100-200 + § N grep — plan-numbering reserved 040-044; sub-plan 041 file scope coordination)
4. `agent-workspace/session-plans/completed/038-S383-phase-f5-cli-dogfood-vhm-thesis.md` (1-150 LOC; F.5 PLAN structure template; DD-7 --run-mode flag rationale; STEP 0.5 STOP-AND-ASK guards)
5. `apps/cli/validate_thesis.py` (full 410 LOC; --run-mode click option at :97-103; INCOMPLETE handling at :166-187; _render_thesis_md at :201-387; HARD CAP $3.00 at :81)
6. `apps/_shared/use_case_builder.py` (1-150 LOC + 370-490 _SubagentDataGatherer; DB path consumption; bars+statements+news+claims gather pattern; gaps detection at :465-471)
7. `packages/application/analysis/use_cases/validate_thesis_phase1.py` (200-300 LOC; INCOMPLETE-corpus early-return at :213-214; Step 6 save at :280; thesis aggregate construction at :260-271)
8. `apps/cli/ingest_vhm.py` (full 143 LOC; VHM-specific bars driver; default --output=./data/vhm.sqlite — STEP 0.2 override mandate)
9. `apps/cli/ingest_news_cafef.py` (full 325 LOC; CafeF news driver; --tickers subset at :180-192; --listing CSV at :202-216; default --output=./data/vn30-news.sqlite — STEP 0.1 override mandate; --skip-llm flag at :100-104)
10. `apps/cli/ingest_fundamentals_vn30.py` (1-100 LOC; vnstock VCI driver; --tickers subset at :64-67; default --output=./data/vn30-fundamentals.sqlite — STEP 0.3 override mandate; --rate-limit-rps 0.3 default)
11. `packages/infrastructure/news/cafef_scraper.py` (60-160 LOC; discover() at :75-99; fetch_article() at :101-133; to_news_article() at :135-160 coarse VN-ticker mention scan)
12. `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` (full 238 LOC; Strategy B WRAP; I-S34 compliance; Rule 16 ZERO numeric)
13. `packages/infrastructure/market_data/ssi_adapter.py` (1-100 LOC; TradingView-style endpoint; THOUSAND VND prices; fetch_daily signature at :125)
14. `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (1-100 LOC; vendor-key→canonical LineItemKey at :54-90; QUARTERLY only Phase 2)
15. `packages/infrastructure/fundamental/sqlite_fundamental_repository.py` (100-160 LOC; INSERT OR REPLACE at :101 idempotency; get_as_of at :116-146; count at :156-159)
16. `packages/infrastructure/market_data/sqlite_bar_repository.py` (Grep verified; INSERT OR REPLACE at :101 + :134; save_many at :94 + save_many_by_ticker at :113)
17. `packages/infrastructure/news/sqlite_news_repository.py` (Grep verified; INSERT OR REPLACE at :93 + :203 idempotency; get_known_as_of at :103; get_for_ticker at :217)
18. `apps/_shared/crawl/rate_limiter.py` (1-50 LOC; per-domain RateLimiter; D-059 R1 compliant via time.monotonic())
19. `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` (full 33 LOC; S384 INCOMPLETE exemplar with gaps=['price_stale', 'fundamentals_stale', 'no_news_90d'])
20. `agent-workspace/memory/thesis-log/_template.md` (1-40 LOC; thesis-log entry schema)
21. `agent-workspace/memory/cost-ledger.tsv` (1-15 rows; cost format schema for STEP 7 cost attestation if D-080 ships)
22. `.claude/agents/sandwich-architect.md` (1-80 LOC; Phase 1b mandate)
23. `Glob agent-workspace/session-plans/pending/*.md` (verified next-free plan number = 045)
24. `Glob agent-workspace/memory/decisions/080-*.md` (verified D-080 slot available)
25. `Glob apps/cli/**/*.py` (verified existence of all 3 ingest CLIs)
26. `Glob agent-workspace/memory/thesis-log/*.md` (verified template + S384 INCOMPLETE exemplar)
27. `agent-workspace/CLAUDE.md` (full text via system-reminder; agent-workspace contract for thesis-log + observations write paths)
28. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` § N Grep for plan-numbering reservation + parallel-architect file scope coordination

**Calibration parameters extracted**:

- **task_class**: `data-corpus-operational` (NEW — no precedent in tracking logs; first operational-ingestion-only session in StockForge per Phase F-prime CODE-DONE-DATA-PENDING attestation history)
- **sample_size**: **0** (COLD-START on this task_class); closest precedents:
  - `crawler-adapter-impl` n=3 (S338/S344/S354) — ~150K Sonnet each; but those were code-port sessions, not operational
  - `cli-dogfood-impl` n=1 (S384 F.5 dogfood with INCOMPLETE-corpus path; $0 cost) — closest in shape but skipped LLM call
  - `data-ingest-cli-author` n=3 (original S43a Stage A authoring of ingest_vhm + ingest_news_cafef + ingest_fundamentals_vn30) — historical; LLM extractor not exercised in those
  - True precedent: NONE for "real-API ingestion + LLM-bounded validate_thesis re-run + thesis-log capture" combined pattern
- **avg_wall_min observed**: N/A precise cold-start; estimating per closest analog cascade:
  - STEP 0 probes ~5-10 min
  - STEP 2 CafeF bulk fetch ~10-20 min (rate_limit=2sec × ~400 articles per listing × 2 listings)
  - STEP 3 SSI bars ~10-20 min (4 tickers × ~3 min each)
  - STEP 4 vnstock fundamentals ~10-20 min (4 tickers × 3 statement types × ~1 min each at rate-limit-rps=0.3)
  - STEP 5 verification ~5 min
  - STEP 6 validate_thesis re-run ~3-5 min × 1-4 tickers
  - STEP 7 thesis-log + commit ~5 min
  - **Total wall-clock**: ~45-90 min for MANDATORY-only (VHM re-run only); ~90-180 min if all 4 ticker re-runs ship
- **avg tokens_real**: N/A cold-start; THIS architect plan-authoring ≤180K Opus PLAN target (operational-plan-author tends lighter per L-S369-1 — fewer DDs); IMPL session estimated:
  - MULTI_TASK_IMPL Opus 200-330K window if all 4 ticker re-runs ship (token-light operational + per-thesis LLM call at $3 HARD CAP each)
  - FOCUSED_IMPL Opus 100-150K window if VHM-only mandatory (DD-7 narrowest scope)
- **parallel_hit_rate**: N/A cold-start; THIS architect session is parallel with S392 G.1 architect per current-execution.md:143-150 (file scope disjoint); IMPL session sequential (single dev; existing CLIs are sync per BC-5 plan 020 DD-2)
- **parallel_savings_avg**: N/A cold-start; estimated turn-savings ~1-2 turns by running this S393 architect parallel with S392 G.1 architect
- **failure_mode frequency**: N/A cold-start; risk-table § H below enumerates 6 RMs with mitigation chains; expected failure modes:
  - RM6 vendor-schema-change canary (probability MEDIUM; mitigation = STEP 0.4 cold-probe gate; reject-and-flag if fails)
  - RM1 rate-limit hit during bulk-fetch (probability MEDIUM; mitigation = existing RateLimiter back-off; resume via re-running idempotent CLI)
  - RM4 LLM-cost-overrun (probability LOW; mitigation = HARD CAP $3.00 per validate_thesis_phase1.py:189)
- **Adjustment to default budget**: THIS plan-authoring = ~150-180K Opus PLAN (operational lighter than design plan; target ≤180K aim); IMPL = 200-330K MULTI_TASK_IMPL Opus full-scope, OR 100-150K FOCUSED_IMPL Opus VHM-only scope per DD-7
- **Cold-start?**: **YES** (explicit declaration per agent-template + plan-025 DD-11 mandate; both `.planner-stats.tsv` no rows for `data-corpus-operational` task_class AND first operational-ingestion-with-LLM-re-run shaped work)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail):

- This plan-authoring: **150-180K Opus PLAN target ceiling** (cold-start envelope per recalibrated CLAUDE.md PLAN-Opus 150-230K column; aim for lower-middle of envelope per operational-plan-author lighter pattern)
- IMPL session: 200-330K MULTI_TASK_IMPL Opus full-scope (4 ingest CLIs + 4 validate_thesis re-runs + 4 thesis-log files + 1 verification report + 1 commit + optional D-080) OR 100-150K FOCUSED_IMPL Opus VHM-only mandatory scope (DD-7 below)
- VERIFY session (if dispatched): 80-180K Opus AP-1 fresh-context per CLAUDE.md VERIFY-Opus column; OPTIONAL — operational sessions historically skip VERIFY when DoDs are deterministically observable (file existence + rowcounts + thesis-log structural conformance); main session decides at IMPL return

**PARALLEL OPPORTUNITY** (architect declaration):

- THIS architect S393 PARALLEL with S392 G.1 architect (in-flight this turn per current-execution.md:143-146)
- IMPL session S395 (or S394) PARALLEL-ELIGIBLE with Phase G-prime sub-plan 041 IMPL (S394 or S395) per disjoint file scope:
  - THIS plan-045 IMPL file scope = `data/stockforge.sqlite` (write) + `agent-workspace/memory/thesis-log/2026-05-XX-{TICKER}.md` (write) + `agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md` (write) + optional `agent-workspace/memory/decisions/080-*.md` (write)
  - Plan-041 G.1 IMPL file scope (per plan-040 § N + § F) = `packages/_shared/pdf/**` (read+write) + `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` (write) + `packages/application/fundamental/pdf_table_extractor_port.py` (write)
  - ZERO file collision; both may run truly in parallel per architect-tier S345 4-parallel precedent

---

## B. What this plan is NOT (explicit OUT-OF-SCOPE)

**This plan is explicitly NOT**:

1. **New code** (production .py changes) — operational track uses ZERO new lines of `.py` code. STEP 1-7 invoke existing CLI drivers as-is with `--output data/stockforge.sqlite` override. If a bug surfaces during STEP 2/3/4/6 invocations forcing a code-change, it's handled inline per AP-1 mandate (separate commit; not pre-planned). § F file scope BINDING below.

2. **CafeF crawler enhancements** — existing `cafef_scraper.py` + `cafef_adapter.py` Strategy B WRAP path (SHIPPED Phase D Theme L plan-020 + verified post-S358) is the ingestion substrate. No per-ticker landing-page additions; no multi-listing rotation logic; no dedicated company-page scrape. Bulk fetch via existing `--listing CSV` pattern per `ingest_news_cafef.py:202-216` quota-per-listing distribution.

3. **SSI adapter direct httpx changes** — existing `ssi_adapter.py` (S32 D-012 closure) consumed as-is via `ingest_vhm.py` orchestration. No multi-resolution support added; no intraday/weekly bars; DAILY only per Phase 1 thin slice.

4. **vnstock fundamental adapter enhancements** — existing `vnstock_fundamental_adapter.py` QUARTERLY-only path (per :15 docstring) consumed as-is via `ingest_fundamentals_vn30.py`. ANNUAL frequency deferred to Phase 3.

5. **New ADR** (operational-track ADR) — DEFAULT NO ADR; per DD-8 OPTIONAL ADR D-080 IF ≥2 ticker re-runs ship for cost-attestation rollup. Cost recorded in thesis-log frontmatter `cost_usd:` field by default per validate_thesis.py:230.

6. **Phase G-prime sub-plan touches** — sub-plans 041-044 reserved by plan-040 § N; PARALLEL ARCHITECTURE work (do NOT touch the same file scope). § F file scope BINDING below.

7. **Charter amendment** — § J below explicitly attests NONE expected; operational uses existing user-authorized adapters; no new I-S<N>-tier surface.

8. **Harness/hook changes** — harness in steady state per S390 commit `e5f17cf`; any harness gaps surfaced during STEP execution are observation-only; do NOT fix in this operational session.

9. **Calibration database scaffolding** — per S391 Q2=D continue UNCALIBRATED-V0; calibration deferred indefinitely per `current-execution.md:141`.

10. **Multi-ticker batch validate_thesis** — STEP 6 VHM mandatory + HPG/VIC/FPT optional per DD-7; not a parallel-batch invocation (single dev process invokes serially; main session may parallelize via separate dispatches if cost-tracking allows).

---

## C. STEP 0 audit + STEP 0.1..0.5 empirical-probe-first probes (DETERMINISTIC VBW)

**ALL STEP 0.x probes MUST execute BEFORE STEP 1 bulk-fetch begins.** Reject-and-flag (do NOT silently proceed) if any probe FAILS.

### STEP 0.1 — CafeF crawler adapter availability + rate-limit substrate check

**Probe (read-only)**:
- `Grep` `class CafeFAdapter|class CafeFScraper|class RateLimiter` in `packages/infrastructure/news/` + `apps/_shared/crawl/` (verify existing path)
- `Read` `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` first 30 LOC (verify Strategy B WRAP pattern at :49-83; verify I-S34 compliance attestation at :73-76)
- `Read` `apps/_shared/crawl/rate_limiter.py` first 30 LOC (verify D-059 R1 compliance via time.monotonic() at :13)
- `Read` `apps/_shared/crawl/robots_manager.py` existence (Glob)

**PASS criterion**: All 3 files exist + CafeFAdapter has fetcher Callable + RateLimiter has wait_if_needed method + robots_manager.py exists.

**FAIL = STOP-AND-ASK** main session: vendor-schema change OR file rename OR Phase D Theme L regression — investigate before STEP 2 bulk fetch.

### STEP 0.2 — SSI adapter availability + VHM/HPG/VIC/FPT ticker shape check

**Probe (read-only)**:
- `Read` `packages/infrastructure/market_data/ssi_adapter.py` first 100 LOC (verify SsiAdapter class + fetch_daily signature at :125 + endpoint URL at :63)
- `Grep` `VHM|HPG|VIC|FPT` in `packages/domain/market_data/vn30_universe.py` (verify all 4 are VN30 constituents per VN30_UNIVERSE constant) — alternate: `Read packages/domain/market_data/__init__.py` for VN30_UNIVERSE export
- `Read` `apps/cli/ingest_vhm.py` first 50 LOC (verify --ticker click option at :50; verify --output default at :55; verify VnstockAdapter + SsiAdapter + TcbsAdapter chain)

**PASS criterion**: All 3 reads succeed + VHM/HPG/VIC/FPT all named in VN30_UNIVERSE + ingest_vhm.py --ticker accepts arbitrary VN30 ticker.

**FAIL = STOP-AND-ASK** main session: SSI endpoint change OR VN30_UNIVERSE drift OR ingest_vhm.py rename — investigate.

### STEP 0.3 — vnstock fundamental adapter availability + ticker shape check

**Probe (read-only)**:
- `Read` `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` first 50 LOC (verify VnstockFundamentalAdapter class + fetch_statements signature at :143)
- `Read` `apps/cli/ingest_fundamentals_vn30.py` first 70 LOC (verify --tickers click option at :64-67 + --output default at :50-54)
- `Grep` `VHM|HPG|VIC|FPT` in `packages/domain/market_data/__init__.py` OR `packages/domain/market_data/vn30_universe.py` — confirm all 4 in vn30_tickers() output

**PASS criterion**: All 3 reads succeed + ingest_fundamentals_vn30.py accepts --tickers subset of VN30.

**FAIL = STOP-AND-ASK** main session: vnstock library version change OR VN30 universe drift — investigate.

### STEP 0.4 — Cold-probe ONE ticker × ONE source (VHM × CafeF news) — EMPIRICAL WIRE TEST

**Probe (DRY-RUN MODE; ~3-5 min wall-clock)**:
- `bash -lc "python apps/cli/ingest_news_cafef.py --tickers VHM --max-articles 5 --output /tmp/probe-vhm-cafef.sqlite --skip-llm --listing /thi-truong-chung-khoan.chn"`
- Capture exit code + stdout/stderr
- `bash -lc "sqlite3 /tmp/probe-vhm-cafef.sqlite 'SELECT COUNT(*) FROM news_articles'"`

**PASS criterion**: exit 0 + COUNT ≥1 + stdout shows `articles_scraped=N` for some N≥1.

**FAIL = REJECT-AND-FLAG**:
- exit ≠0 → vendor-schema change OR CafeF site down → STOP-AND-ASK main session
- COUNT = 0 → coarse-mention scan failure (no VHM in any of the 5 scraped articles) → tolerate ONLY IF 2nd cold-probe with --tickers VN30 yields COUNT>0 (rules out vendor) AND retry --tickers VHM --max-articles 30 yields ≥1 article (rules out small-sample-noise); ELSE STOP-AND-ASK

**Why VHM × CafeF specifically**: (a) VHM = highest-news-frequency VN30 blue chip per historical pattern (Vinhomes is real-estate flagship; constant news cycle); (b) CafeF = earliest-shipped + most-stable adapter per Phase D Theme L history; (c) cold-probe sample-size is small (~5 articles) → minimizes risk of partial-corruption if RM6 vendor-schema fires.

### STEP 0.5 — Empirical baseline `sqlite3 data/stockforge.sqlite` BEFORE state capture

**Probe (read-only)**:
- `bash -lc "ls -la data/stockforge.sqlite"` (capture file existence + size + mtime)
- `bash -lc "sqlite3 data/stockforge.sqlite '.tables'"` (capture all table names; expected: bars, news_articles, extracted_claims, financial_statements, theses, …)
- `bash -lc "sqlite3 data/stockforge.sqlite \"SELECT COUNT(*) FROM bars WHERE ticker IN ('VHM','HPG','VIC','FPT')\""` (capture per-ticker bars baseline)
- Same query for `news_articles WHERE mentioned_tickers LIKE '%VHM%' OR mentioned_tickers LIKE '%HPG%' OR mentioned_tickers LIKE '%VIC%' OR mentioned_tickers LIKE '%FPT%'` (capture per-ticker news baseline; coarse JSON-string LIKE match; not perfect but adequate for baseline)
- Same query for `financial_statements WHERE ticker IN ('VHM','HPG','VIC','FPT')` (capture per-ticker statements baseline)
- Same query for `theses WHERE ticker IN ('VHM','HPG','VIC','FPT')` (capture per-ticker theses baseline; expected 0 because PFP-DONE-7 currently PENDING)

**Capture format**: Append all baseline counts to dev observation file `agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md` under § Baseline (BEFORE STEP 1).

**PASS criterion**: All queries return integers (or 0); file exists. NO FAIL mode — this is pure baseline capture.

**Why before STEP 1**: enables AFTER-comparison at STEP 5 (delta = new rows added per cell); validates idempotency at STEP 5 re-run (if dev re-runs CLI, delta should be ZERO additional rows = INSERT OR REPLACE behaving correctly).

---

## D. Design Decisions (DDs)

### DD-1: Batch size for ingestion fetches

**Question**: One-ticker-one-source-at-a-time vs all-parallel vs serial-tickers-parallel-sources?

**Decision**: **SERIAL-CLIs-PER-SOURCE-WITH-MULTI-TICKER-FLAG** — each existing CLI accepts `--tickers VHM,HPG,VIC,FPT` subset flag (verified per STEP 0.1-0.3); invoke each CLI ONCE (not 4× per ticker) with the 4-ticker comma-separated argument. Sources serial (STEP 2 CafeF → STEP 3 SSI → STEP 4 vnstock) because:
- Rate-limit substrate is per-domain-singleton (RateLimiter); concurrent CafeF + SSI fetches don't share rate-limit state but each domain has independent limit anyway
- Single-dev-process simpler than parallel orchestration; existing CLIs are sync (BC-5 plan 020 DD-2 — async deferred to Phase 3)
- Bulk fetch sequence is more deterministic for STEP 5 verification + STEP 0.5 baseline-vs-after comparison
- Estimated wall-clock per source: ~10-20 min × 3 sources = ~30-60 min total; well within MULTI_TASK_IMPL Opus window

**Rejected alternative**: parallel orchestration across 4 tickers × 3 sources (12 invocations parallel) — would require new orchestration code (NEW production code = out-of-scope per § B item 1) + over-engineers a once-off operational session.

**Rejected alternative**: per-ticker per-source 4×3=12 separate invocations — defeats purpose of existing --tickers CSV flag; multiplies wall-clock with no benefit.

### DD-2: Date range for SSI bars

**Question**: 90d vs 1y vs 5y window?

**Decision**: **90d** (matches `_SubagentDataGatherer` 90d news-window filter at `use_case_builder.py:419-462`; minimum required to clear `price_stale` gap at `:466-467` which requires bars within 3 days of as_of). Per ingest_vhm.py:64 default `start_date = end_date - timedelta(days=365)` BUT validate_thesis only consumes 90d window per gather logic; deeper history wastes API calls + DB rows.

**Rejected alternative**: 1y (~252 trading days) — overshoots validate_thesis consumption window by 4×; wastes ~3× SSI API calls per ticker per 90d-vs-1y ratio.

**Rejected alternative**: 5y — Phase 2 percentile-service scope per current-execution.md prior context; explicitly out of Phase 1 thin slice scope.

**Implementation**: dev SHOULD pass `--start <today-90>` to ingest_vhm.py explicitly to avoid default 365d; OR accept ingest_vhm.py default 365d since SSI rate-limit + DB write overhead is small enough (the 90d ↔ 365d difference is ~5min wall-clock per ticker × 4 tickers = ~20min total overhead — TOLERABLE per Karpathy P2 simplicity). RECOMMENDED: dev passes `--start $(date -d 'today - 90 days' '+%Y-%m-%d')` for tight scoping.

### DD-3: News count cap (CafeF news per ticker baseline)

**Question**: How many CafeF news articles per ticker is the DoD-quality floor?

**Decision**: **≥30 articles per ticker** (sentiment-meaningful baseline). Rationale:
- CafeF coarse-mention scan is broad — ticker.symbol verbatim case-sensitive match in title+body_text per cafef_scraper.py:142-148
- Statistical floor for sentiment-meaningful baseline: ≥30 samples per ticker enables crude distribution observation (bull/bear/neutral split) without single-article-bias
- 4 tickers × ≥30 articles = ≥120 articles with-ticker-mention required → over-fetch ~800 total articles in STEP 2 to clear floor for ALL 4 tickers (rough estimate: VN30 mention rate ~15-30% of CafeF market-section articles → 800 × 0.20 = ~160 mentions per VN30 ticker average; well above 30 floor for blue chips like VHM/HPG/VIC/FPT)
- Lower floor (≥10) risks single-article-bias in downstream sentiment scoring; higher floor (≥100) over-engineers Phase 1 thin slice

**Rejected alternative**: ≥10 — too small; one outlier article dominates sentiment baseline.

**Rejected alternative**: ≥100 — over-engineers Phase 1 thin slice; doubles STEP 2 wall-clock without measurable downstream LLM quality improvement at V0.

**Implementation**: dev passes `--max-articles 800` to ingest_news_cafef.py + multi-listing CSV `--listing /thi-truong-chung-khoan.chn,/doanh-nghiep.chn`; STEP 5 verifies per-ticker mention count ≥30 via SQL on news_articles + JSON LIKE match; PARTIAL flag at STEP 7 IF any ticker falls below 30 (continue-others policy DD-6).

### DD-4: Fundamental statement years (depth)

**Question**: Most-recent quarter only vs 4 quarters vs 8 quarters?

**Decision**: **Most-recent quarter ONLY** (minimum to clear `fundamentals_stale` gap at `use_case_builder.py:468-469`). Rationale:
- `_SubagentDataGatherer` consumes `statements_all = fund_repo.get_as_of(_ticker, _as_of)` then `income_stmts = [s for s in statements_all if s.statement_type == StatementType.IS][-4:]` per :434 — uses last 4 IS quarters IF available; but the gate at :468-469 only requires NON-empty `statements_all`
- vnstock VCI guest tier returns ALL available quarters by default (no date-range parameter on VnstockFundamentalAdapter.fetch_statements per :143 signature); we cannot easily limit to most-recent-quarter at the adapter
- Net effect: 1 invocation of ingest_fundamentals_vn30.py per ticker fetches ALL available historical IS+BS+CF (typically last 8-12 quarters); the dev CANNOT under-fetch even if desired; AC: at LEAST 1 statement per ticker is what we ENFORCE
- For ratio computation (RatioService.compute_ttm_ratios) the last 4 IS quarters are CONSUMED but not REQUIRED for thesis to be non-INCOMPLETE; missing ratios → empty `ratios_ttm` dict per use_case_builder.py:438-449 graceful fallback

**Rejected alternative**: 4 quarters mandatory — not enforceable at adapter level; vnstock returns what it has

**Rejected alternative**: 8+ quarters — Phase 2 percentile-service scope; out of Phase 1 thin slice

**Implementation**: dev runs ingest_fundamentals_vn30.py --tickers VHM,HPG,VIC,FPT WITHOUT --start/--end args (vnstock returns all available); STEP 5 verifies per-ticker ≥1 statement of EACH type (IS+BS+CF) via SQL on financial_statements; PARTIAL flag at STEP 7 IF any ticker missing any statement type.

### DD-5: Idempotency (re-running should not duplicate)

**Question**: Existing repositories handle UPSERT correctly?

**Decision**: **YES — verified by-construction**. All 3 SQLite repositories use `INSERT OR REPLACE`:
- `sqlite_bar_repository.py:101` (save_many) + `:134` (save_many_by_ticker)
- `sqlite_news_repository.py:93` (news_articles) + `:203` (extracted_claims)
- `sqlite_fundamental_repository.py:101` (financial_statements)
- Per `sqlite_news_repository.py:15` docstring: "Both tables: `INSERT OR REPLACE` so idempotent re-runs converge"

**STEP 5 idempotency verification**: dev MAY re-run ANY of STEP 2/3/4 a second time AFTER first run; per-cell COUNT(*) should be IDENTICAL (not double); IF count doubles → RM3 idempotency-bug surfaced (separate inline-fix per AP-1; not pre-planned).

**No new code needed**; existing repositories handle this correctly.

### DD-6: Failure-policy

**Question**: One-ticker-one-source failure = abort vs continue-others-and-flag-end-of-run?

**Decision**: **CONTINUE-OTHERS-AND-FLAG-END-OF-RUN**. Rationale:
- ingest_news_cafef.py per-listing failures degrade gracefully per :211-216 (try/except per-listing)
- ingest_vhm.py per-source failures degrade gracefully per :80-96 (try/except per-adapter)
- ingest_fundamentals_vn30.py per-ticker partial-failure tolerance per docstring :10-11 "a bad ticker logs + continues"
- Karpathy P2 simplicity: don't add abort logic; existing graceful-fail is sufficient
- Net effect: STEP 2/3/4 each complete (possibly with PARTIAL coverage); STEP 5 verification report enumerates per-cell PASS/FAIL; STEP 6 VHM re-run mandatory IFF VHM CELLS ALL PASS (else flag as VHM-PARTIAL); STEP 6.2-6.4 HPG/VIC/FPT re-run optional + only on per-ticker FULL corpus

**STEP 7 attestation**: thesis-log files written ONLY for tickers with FULL corpus (all 3 sources non-zero); PARTIAL tickers flagged in dev observation file `agent-workspace/memory/observations/sandwich-dev-S<N>-data-corpus-ingestion.md`

### DD-7: validate_thesis re-run scope

**Question**: VHM only mandatory vs all-4-tickers mandatory?

**Decision**: **VHM MANDATORY + HPG/VIC/FPT OPTIONAL** (per dev/main-session decision at STEP 6). Rationale:
- Charter Principle 7 dogfood satisfaction requires ≥1 corpus-ready thesis (= VHM exemplar matching S384 INCOMPLETE that needs flipping GREEN)
- HARD CAP $3.00 × 4 tickers = up to $12 max if all 4 ship; vs $3.00 max if VHM only — wider blast radius for RM4 cost-overrun
- Wall-clock: 4× ticker re-runs × ~3-5 min each = ~12-20 min total; tolerable but Karpathy P2 = ship VHM first, decide HPG/VIC/FPT based on VHM outcome
- Verifier-independent attestation: VHM-only flip clears PFP-DONE-7+8 GREEN; HPG/VIC/FPT additional flips add data points but not gate-satisfaction value

**Implementation**:
- STEP 6.1 (MANDATORY): `python apps/cli/validate_thesis.py --ticker VHM --transport subagent --as-of <today> --run-mode dogfood --db data/stockforge.sqlite`
- STEP 6.2 (OPTIONAL; only if STEP 6.1 PASS + STEP 5 HPG-cells PASS + budget allows): same with --ticker HPG
- STEP 6.3 (OPTIONAL; only if STEP 6.1 PASS + STEP 5 VIC-cells PASS + budget allows): same with --ticker VIC
- STEP 6.4 (OPTIONAL; only if STEP 6.1 PASS + STEP 5 FPT-cells PASS + budget allows): same with --ticker FPT

**Main session orchestration**: at IMPL dispatch, main session MAY narrow this to VHM-only (FOCUSED_IMPL Opus 100-150K budget) OR full-4 (MULTI_TASK_IMPL Opus 200-330K budget); dev follows the dispatch.

### DD-8: Optional ADR D-080 cost-attestation

**Question**: New ADR warranted for this operational session?

**Decision**: **OPTIONAL — fires IF ≥2 ticker validate_thesis re-runs ship + cost-attestation rollup is non-trivial**. Rationale:
- 1-ticker (VHM only) cost = single thesis-log frontmatter row `cost_usd: X.YY` per validate_thesis.py:230; no ADR needed (data point in cost-ledger.tsv via existing Stop hook)
- ≥2 ticker cost = per-ticker rollup table useful for future calibration cycle reference (Charter Principle 8); D-080 captures: total tokens / total $ / per-persona breakdown / cost-vs-quality observation per ticker / wall-clock per re-run / retry-validator fire count per persona per ticker
- D-080 ADR schema per existing 12-field pattern at agent-workspace/memory/decisions/_template.md (Track 2)
- IMPL-tier proposal auto-accepts per severity-schema (no cool-down per L-S385-2)

**Implementation**: dev decides at STEP 7 based on STEP 6 actual execution:
- IF only VHM re-ran (STEP 6.1 only): SKIP D-080; cost lives in thesis-log/2026-05-XX-VHM.md frontmatter
- IF ≥2 tickers re-ran (STEP 6.1 + ≥1 of STEP 6.2-6.4): SHIP D-080 PROPOSED at IMPL tier ~150-200 LOC

**No mandatory ADR** — operational sessions historically don't ship ADRs unless cost-attestation rollup or schema-migration surface emerges.

---

## E. Sub-tracks (STEP 1-7 for IMPL session)

**Sequence**: STEP 1 → STEP 2 → STEP 3 → STEP 4 → STEP 5 → STEP 6.1 (+ optional 6.2-6.4) → STEP 7

**Total IMPL wall-clock**: ~45-90 min mandatory-only (VHM re-run only); ~90-180 min full-4-ticker re-run.

### STEP 1 — STEP 0 probes + cold-probe gate execution (~10-15 min)

Dev executes all STEP 0.1-0.5 probes from § C above. Captures all baseline counts + cold-probe outputs to dev observation file. Cold-probe FAIL → STOP-AND-ASK main session (do NOT proceed).

**DoD**: All 5 STEP 0.x probes PASS; cold-probe count ≥1; baseline counts captured + appended to observation file.

### STEP 2 — CafeF news bulk fetch (4 tickers, ~10-20 min)

```bash
python apps/cli/ingest_news_cafef.py \
  --tickers VHM,HPG,VIC,FPT \
  --max-articles 800 \
  --output data/stockforge.sqlite \
  --skip-llm \
  --listing /thi-truong-chung-khoan.chn,/doanh-nghiep.chn
```

**Pre-conditions**: STEP 1 PASS; data/stockforge.sqlite exists; CafeFAdapter substrate verified.

**Why `--skip-llm`**: avoids extra Anthropic spend on claim-extraction during pure-ingestion phase; LLM only fires at STEP 6 validate_thesis re-run; claim extraction can be deferred to a future operational sub-plan if needed (out-of-scope per § A.3).

**Why `--max-articles 800`**: covers ≥30 per-ticker DoD floor across all 4 tickers per DD-3 rationale (~800 × 0.20 mention rate × 1 listing = ~160 per ticker average; safe margin above 30 floor).

**DoD**: exit 0; stdout shows `articles_scraped=N` for N≥600 (some failed parses tolerated per L-S28-1 graceful-fail); `articles_written=M` close to N; per-ticker `mentioned_tickers` count via STEP 5 SQL ≥30 (or PARTIAL flag per DD-6).

### STEP 3 — R2/SSI bars bulk fetch (4 tickers, ~10-20 min)

```bash
# 4 sequential invocations (per-ticker because ingest_vhm.py is single-ticker CLI)
for t in VHM HPG VIC FPT; do
  python apps/cli/ingest_vhm.py \
    --ticker $t \
    --start $(date -d 'today - 90 days' '+%Y-%m-%d') \
    --end $(date '+%Y-%m-%d') \
    --output data/stockforge.sqlite
done
```

**Pre-conditions**: STEP 2 complete OR concurrent; SSI iBoard endpoint reachable.

**Why per-ticker loop**: ingest_vhm.py is single-ticker CLI per :49 click option (despite the misleading name suggesting VHM-only; --ticker overrides).

**Why 90d window**: matches `_SubagentDataGatherer` consumption window per DD-2 rationale.

**Expected per-ticker**: vnstock returns ~60-70 DAILY bars (90 calendar - weekends - holidays); SSI returns same range; TcbsAdapter graceful-fails per D-012; reconciliation report skipped per `--report` default name (acceptable).

**DoD**: All 4 invocations exit 0 (or 2 if vnstock fails; tolerated per ingest_vhm.py:80-83); stdout shows `vnstock returned N bars` for N≥30 + `ssi returned M bars` for M≥30 (or one source SINGLE_SOURCE mode tolerated); STEP 5 SQL verifies per-ticker bars rowcount ≥30.

### STEP 4 — BC-2 vnstock fundamentals fetch (4 tickers, ~10-20 min)

```bash
python apps/cli/ingest_fundamentals_vn30.py \
  --tickers VHM,HPG,VIC,FPT \
  --output data/stockforge.sqlite \
  --rate-limit-rps 0.3
```

**Pre-conditions**: STEP 2 + 3 complete OR concurrent; vnstock VCI guest tier reachable.

**Why `--rate-limit-rps 0.3`**: matches VCI guest tier hard cap per ingest_fundamentals_vn30.py:62 default; respects vendor rate-limit per Charter ToS compliance.

**Expected per-ticker**: 1 invocation × 3 statement types (IS+BS+CF) × ~8-12 quarters of historical = ~24-36 rows per ticker × 4 tickers = ~96-144 rows total in financial_statements.

**DoD**: exit 0; stdout shows per-ticker IS+BS+CF counts; STEP 5 SQL verifies per-ticker COUNT(DISTINCT statement_type) = 3 + per-ticker row count ≥1 of each type.

### STEP 5 — Post-fetch DB verification queries (~5 min)

Dev executes verification SQL battery + appends results to `agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md` under § After (POST STEP 1-4):

```sql
-- Per-ticker bars count + latest period_end
SELECT ticker, COUNT(*) AS bars_count, MAX(period_end) AS latest_bar_date
FROM bars WHERE ticker IN ('VHM','HPG','VIC','FPT') GROUP BY ticker;

-- Per-ticker news with mentions (coarse JSON LIKE match)
SELECT
  'VHM' AS ticker,
  COUNT(*) AS news_count
FROM news_articles
WHERE mentioned_tickers LIKE '%"VHM"%'
UNION ALL
SELECT 'HPG', COUNT(*) FROM news_articles WHERE mentioned_tickers LIKE '%"HPG"%'
UNION ALL
SELECT 'VIC', COUNT(*) FROM news_articles WHERE mentioned_tickers LIKE '%"VIC"%'
UNION ALL
SELECT 'FPT', COUNT(*) FROM news_articles WHERE mentioned_tickers LIKE '%"FPT"%';

-- Per-ticker statements count by type
SELECT ticker, statement_type, COUNT(*) AS stmt_count, MAX(period_end) AS latest_period
FROM financial_statements
WHERE ticker IN ('VHM','HPG','VIC','FPT')
GROUP BY ticker, statement_type;

-- Theses baseline (expected 0 BEFORE STEP 6)
SELECT ticker, COUNT(*) AS thesis_count
FROM theses WHERE ticker IN ('VHM','HPG','VIC','FPT')
GROUP BY ticker;
```

**Per-cell DoD-quality check matrix** (12 cells; populated in verification report):

| Cell | Source | Min count | DD ref |
|---|---|---|---|
| VHM × bars | SSI/VCI | ≥30 | DD-2 |
| HPG × bars | SSI/VCI | ≥30 | DD-2 |
| VIC × bars | SSI/VCI | ≥30 | DD-2 |
| FPT × bars | SSI/VCI | ≥30 | DD-2 |
| VHM × news | CafeF | ≥30 | DD-3 |
| HPG × news | CafeF | ≥30 | DD-3 |
| VIC × news | CafeF | ≥30 | DD-3 |
| FPT × news | CafeF | ≥30 | DD-3 |
| VHM × statements | vnstock | ≥1 IS + ≥1 BS + ≥1 CF | DD-4 |
| HPG × statements | vnstock | ≥1 IS + ≥1 BS + ≥1 CF | DD-4 |
| VIC × statements | vnstock | ≥1 IS + ≥1 BS + ≥1 CF | DD-4 |
| FPT × statements | vnstock | ≥1 IS + ≥1 BS + ≥1 CF | DD-4 |

**DoD**: All 12 cells PASS; if any PARTIAL → flag in observation + STEP 6 narrowing per DD-6 continue-others policy + DD-7 VHM-only fallback.

### STEP 6 — validate_thesis CLI re-run for VHM (mandatory) + optional HPG/VIC/FPT (~3-5 min per ticker)

**STEP 6.1 — VHM (MANDATORY)**:

```bash
python apps/cli/validate_thesis.py \
  --ticker VHM \
  --transport subagent \
  --as-of $(date '+%Y-%m-%d') \
  --run-mode dogfood \
  --db data/stockforge.sqlite
```

**Pre-conditions**: STEP 5 VHM cells ALL PASS (bars ≥30 + news ≥30 + 3 statement types ≥1 each); claude CLI alive (`bash -lc "claude --version"`).

**Expected**: exit 0 (thesis SUBMITTED) OR exit 2 (BearCaseInvariantError = legitimate INCOMPLETE for I-S10 reason NOT corpus reason); new file `agent-workspace/memory/thesis-log/YYYY-MM-DD-VHM.md` written per validate_thesis.py:158-162 with `status: submitted` (or `status: incomplete` IF I-S10-failed) + `gaps:` field MUST NOT contain 'price_stale' / 'fundamentals_stale' / 'no_news_90d' (the 3 corpus gaps fixed by STEP 2-4); `cost_usd` recorded; thesis_id non-empty; Thesis aggregate persisted to SqliteThesisRepository (verified via SELECT COUNT(*) FROM theses WHERE ticker='VHM' should be 1).

**DoD-PFP-7-flip-evidence**: SQL `SELECT thesis_id, status, cost_usd FROM theses WHERE ticker='VHM' ORDER BY created_at DESC LIMIT 1` returns 1 row with non-empty thesis_id + status IN ('submitted', 'incomplete') + cost_usd ≤ 3.00.

**DoD-PFP-8-flip-evidence**: thesis-log file exists at expected path + frontmatter has `gaps:` NOT containing the 3 corpus gaps + LIVE LLM personas emitted PerspectiveAnalysis output (verified via thesis aggregate `perspectives` field non-empty + each perspective has `key_points` non-empty).

**STEP 6.2-6.4 — HPG/VIC/FPT (OPTIONAL per DD-7)**:

Same command shape per ticker. Decided by dev/main-session based on:
- STEP 5 PASS status for the ticker's cells (no-go if PARTIAL)
- Remaining wall-clock budget within IMPL session window
- Remaining $ budget (per-ticker $3.00 HARD CAP × tickers re-running ≤ $12 total)

**Per-ticker DoD** (when run): same as STEP 6.1 DoD-PFP-7+8 evidence applied per ticker.

### STEP 7 — Thesis-log observation files + commit (~5-10 min)

Dev:
1. Verify thesis-log/YYYY-MM-DD-{TICKER}.md files exist for each ticker re-run (created by STEP 6)
2. Sanity-check each file's frontmatter has `status` field + `cost_usd` field + `gaps:` NOT containing the 3 corpus gaps
3. Append per-ticker cost rollup + per-ticker thesis_id to dev observation file `agent-workspace/memory/observations/sandwich-dev-S<N>-data-corpus-ingestion.md`
4. DECIDE per DD-8 whether ADR D-080 is warranted (≥2 tickers re-ran AND cost-attestation rollup non-trivial)
5. IF D-080 ships: author `agent-workspace/memory/decisions/080-data-corpus-ingestion-cost-attestation.md` ~150-200 LOC per 12-field schema
6. Commit (per D-060):
   ```bash
   git add agent-workspace/memory/thesis-log/2026-05-XX-*.md \
           agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md \
           agent-workspace/memory/observations/sandwich-dev-S<N>-data-corpus-ingestion.md
   # IF D-080:
   git add agent-workspace/memory/decisions/080-*.md
   git commit -m "S<N>: Phase F-prime Wave 1 MVP DATA-CORPUS ingestion + VHM(+optional HPG/VIC/FPT) dogfood re-run — PFP-DONE-7+8 GREEN"
   ```
7. Update `current-execution.md` PFP-DONE grid: PFP-DONE-7 PENDING → GREEN + PFP-DONE-8 PARTIAL → GREEN (or PARTIAL-VHM-only if STEP 6.2-6.4 skipped)

**DoD**: ≥1 thesis-log file persisted (VHM mandatory); 1 verification report persisted; 1 dev observation file persisted; optional 1 ADR D-080; 1 commit; current-execution.md PFP-DONE grid updated.

---

## F. File scope (BINDING for IMPL session)

**Files dev MAY write to** (operational; ALL exist or are new artifact paths):

| Path | Op | Why |
|---|---|---|
| `data/stockforge.sqlite` | WRITE (via existing repositories' INSERT OR REPLACE) | Canonical DB consumed by validate_thesis |
| `agent-workspace/memory/thesis-log/2026-05-XX-VHM.md` | NEW WRITE (created by validate_thesis.py:158-162) | STEP 6.1 mandatory output |
| `agent-workspace/memory/thesis-log/2026-05-XX-HPG.md` | NEW WRITE optional | STEP 6.2 optional output |
| `agent-workspace/memory/thesis-log/2026-05-XX-VIC.md` | NEW WRITE optional | STEP 6.3 optional output |
| `agent-workspace/memory/thesis-log/2026-05-XX-FPT.md` | NEW WRITE optional | STEP 6.4 optional output |
| `agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md` | NEW WRITE | STEP 5 verification report |
| `agent-workspace/memory/observations/sandwich-dev-S<N>-data-corpus-ingestion.md` | NEW WRITE | dev return observation per AP-1 |
| `agent-workspace/memory/decisions/080-data-corpus-ingestion-cost-attestation.md` | NEW WRITE OPTIONAL per DD-8 | IF ≥2 tickers re-ran |
| `agent-workspace/memory/current-execution.md` | EDIT (close-bookkeeping) | PFP-DONE grid update at STEP 7 close |
| `/tmp/probe-vhm-cafef.sqlite` | NEW WRITE temporary | STEP 0.4 cold-probe DB |
| `agent-workspace/memory/sessions/2026-05-XX-session-<N>.md` | NEW WRITE | dev session-end log per AOM |
| `agent-workspace/memory/checkpoints/latest.md` | EDIT | close-bookkeeping |

**Files dev MUST NOT touch** (BINDING):

| Path | Why |
|---|---|
| `packages/**` | Zero new production code; operational track |
| `apps/cli/validate_thesis.py` | ONLY if RM-bug surfaces during STEP 6 per AP-1 inline-fix (separate commit) |
| `apps/cli/ingest_*.py` | ONLY if RM-bug surfaces during STEP 2/3/4 per AP-1 inline-fix (separate commit) |
| `apps/_shared/**` | Zero new code |
| `scripts/hooks/**` | Harness in steady state; no harness changes this session |
| `PROJECT_CHARTER.md` | Immutable |
| `agent-workspace/constitution/**` | Immutable absent explicit user approval |
| `agent-workspace/session-plans/pending/040-S391-*.md` | Read-only reference |
| `agent-workspace/session-plans/pending/041-*` through `044-*` | Reserved Phase G-prime; PARALLEL architect file scope |
| `agent-workspace/session-plans/pending/045-*.md` (THIS plan after authoring) | Sandwich-dev MAY append `executing_agent:` + status update lines via Edit; but NO substantive plan revision (a re-plan is a separate sandwich-architect dispatch per AP-1) |
| `agent-workspace/session-plans/completed/**` | Read-only reference |
| `data/*-news.sqlite`, `data/vhm.sqlite`, `data/vn30-fundamentals.sqlite` | Legacy default-DB paths from older CLI invocations; do NOT use; canonical = `data/stockforge.sqlite` per § A.2 |
| `obsidian-vault/raw/**` | Immutable per CLAUDE.md hard rule |

**Commit-eligible scope** (per D-060):
- thesis-log/ files (per ticker)
- observations/ files (verification report + dev return)
- Optional ADR D-080
- current-execution.md close-bookkeeping update
- sessions/ + checkpoints/ close-bookkeeping
- **NOT** data/stockforge.sqlite (gitignored; DB content not committed)

---

## G. Sub-track DoDs (≥10 items for verifier-independent attestation)

**G.1**: `data/stockforge.sqlite` post-state per (ticker × source) cell ≥ 1 row across 12 cells (4 tickers × 3 sources); minimum 12 non-zero counts verified via STEP 5 SQL battery + captured in verification report

**G.2**: ≥30 CafeF news articles per ticker (4 tickers × ≥30 = ≥120 with-ticker-mention articles); sentiment-meaningful baseline per DD-3

**G.3**: ≥30 trading days SSI bars per ticker for 90d window (4 tickers × ≥30 = ≥120 bars rows); TWAP-meaningful per DD-2

**G.4**: ≥1 fundamental statement per ticker per statement_type (IS+BS+CF); 4 tickers × 3 types = ≥12 statement rows minimum; most-recent quarter per DD-4

**G.5**: `python apps/cli/validate_thesis.py --ticker VHM --run-mode=dogfood --db data/stockforge.sqlite` completes WITHOUT INCOMPLETE-corpus early-return (verified by NEW thesis-log/2026-05-XX-VHM.md frontmatter `gaps:` field NOT containing 'price_stale' / 'fundamentals_stale' / 'no_news_90d'); Step 6 save at use_case:280 FIRES (verified by SELECT COUNT(*) FROM theses WHERE ticker='VHM' >0)

**G.6**: Persisted thesis-log markdown file at `agent-workspace/memory/thesis-log/YYYY-MM-DD-VHM.md` with non-empty `thesis_id` + status IN ('submitted', 'incomplete') + `cost_usd` ≤ Decimal('3.00') + `dogfood: true` + `dogfood_session: S<N>` frontmatter fields

**G.7**: PFP-DONE-7 (thesis persistence) flipped from PENDING to GREEN in `current-execution.md` (STEP 7 close-bookkeeping edit per § E STEP 7)

**G.8**: PFP-DONE-8 (live LLM empirical validation) flipped from PARTIAL to GREEN (or PARTIAL-VHM-only if STEP 6.2-6.4 skipped) in `current-execution.md`

**G.9**: cost-ledger.tsv entry recorded for the VHM re-run Anthropic spend (auto-populated by Stop hook + SubagentStop hook per existing pattern; verified by tail -5 cost-ledger.tsv)

**G.10**: STEP 0 probe results captured in verification report (`agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md`) under § Baseline; STEP 5 post-fetch counts under § After; delta computed = new rows added per cell

**G.11**: Dev observation file at `agent-workspace/memory/observations/sandwich-dev-S<N>-data-corpus-ingestion.md` summarizing: (a) STEP 1-7 execution log + per-step wall-clock + per-step PASS/FAIL; (b) per-cell row count delta; (c) per-ticker thesis_id + cost; (d) any RM that fired + mitigation outcome; (e) PFP-DONE-7+8 flip confirmation

**G.12**: Commit lands per D-060 with message format `S<N>: Phase F-prime Wave 1 MVP DATA-CORPUS ingestion + VHM(+optional HPG/VIC/FPT) dogfood re-run — PFP-DONE-7+8 GREEN`; 0 git push (D-060 hard rule)

**G.13** (OPTIONAL per DD-8): ADR D-080 PROPOSED at IMPL tier ~150-200 LOC IF ≥2 ticker re-runs ship with cost-attestation rollup

---

## H. Risk Mitigations (RMs)

| ID | Risk | Probability | Mitigation chain |
|---|---|---|---|
| **RM1** | Vendor API rate-limit hit during bulk-fetch (CafeF 429/503 + SSI rate-cap + vnstock VCI rate-cap) | MEDIUM | (1) Existing RateLimiter substrate at apps/_shared/crawl/rate_limiter.py handles back-off + exponential jitter (per BC-5 reliability skill); (2) ingest_news_cafef.py uses CafeFScraper internal rate_limit_seconds=2.0 default; (3) ingest_fundamentals_vn30.py --rate-limit-rps 0.3 matches VCI guest tier hard cap; (4) ingest_vhm.py SsiAdapter rate_limit_seconds=1.0 default; (5) IF rate-limit STILL hit despite back-off: re-run idempotent CLI per DD-5 (UPSERT semantics); resume marker via INSERT OR REPLACE convergence |
| **RM2** | Wall-clock overrun in IMPL session (4 tickers × 3 sources × cold-probe per-cell + 1-4 validate_thesis re-runs) | MEDIUM | (1) Estimated ~45-90 min mandatory-only (within MULTI_TASK_IMPL Opus 200-330K wall-clock budget); (2) Main session orchestrates IMPL dispatch with MULTI_TASK_IMPL Opus budget cite per L-S365-1 (M-S365-1 prevention rule); (3) IF wall-clock overrun: split into 2 FOCUSED_IMPL sessions (1=STEP 1-5 ingest+verify / 2=STEP 6.1 VHM re-run + STEP 7 commit) per DD-7 narrowest-scope fallback; (4) STEP 6.2-6.4 optional per DD-7 — dev can skip without DoD impact |
| **RM3** | Idempotency-bug surfacing (existing repository may double-insert despite INSERT OR REPLACE) | LOW | (1) Verified per DD-5: all 3 repositories use INSERT OR REPLACE explicitly (file:line cited); (2) STEP 5 verification matrix includes idempotency-spot-check: re-run STEP 2/3/4 with same args → expect ZERO additional rows (delta = 0); (3) IF doubling observed → AP-1 inline-fix path (separate commit; not pre-planned) + bug ticket logged in dev observation; (4) Worst case: dev wipes affected table + re-runs (`sqlite3 data/stockforge.sqlite "DELETE FROM <table> WHERE ticker IN (...)"` + STEP 2/3/4 re-run) |
| **RM4** | LLM-cost-overrun during validate_thesis re-run | LOW | (1) HARD CAP per validate_thesis_phase1.py:189 `scoped_budget(limit_usd=Decimal('3.00'))` — use case catches CostBudgetExceeded internally + returns Thesis.incomplete(gaps=['cost_budget_exceeded']) per validate_thesis_phase1.py:201-205 + validate_thesis.py:147-153 CLI exit 1; (2) Per-ticker bounded; DD-7 VHM-only mandatory scope = $3.00 max; full-4 = $12.00 max; (3) Cost-ledger.tsv auto-populates via Stop hook + SubagentStop hook for verifier traceability (4) IF actual cost > Decimal('2.50') triggers F.5-V2 budget-tightening study per plan-038 § A.3 |
| **RM5** | Thesis-output-quality flag (LLM may produce non-actionable output if data is thin or contradictory) | LOW-MEDIUM | (1) STEP 0 DD-3 ≥30 news threshold mitigates sentiment-thin-baseline risk; (2) DD-2 90d bars window mitigates TA-thin-baseline risk; (3) DD-4 most-recent quarter mitigates fundamentals-stale risk; (4) IF thesis output emits 'buy/sell' prose (I-S35 violation) → STEP 6 grep-detect + AP-1 inline-fix path (likely persona prompt drift; surface to verifier); (5) IF thesis status='incomplete' for I-S10 BearCaseInvariantError → legitimate output (S384 INCOMPLETE-corpus path showed dev observation must capture this distinctly from corpus-INCOMPLETE) |
| **RM6** | Vendor schema-change since S384 dogfood (CafeF HTML selector drift OR SSI endpoint shift OR vnstock library version bump) | MEDIUM | (1) STEP 0.4 cold-probe VHM × CafeF is the canary (smallest sample; fastest probe); (2) STEP 0.1-0.3 read-only adapter source verification confirms file paths + signatures unchanged; (3) IF cold-probe FAILS → STOP-AND-ASK main session (do NOT silently proceed); (4) IF bulk-fetch fails per-cell mid-STEP-2/3/4 → graceful-fail per existing per-listing/per-ticker error handling (continue-others per DD-6); (5) Verifier S396 (if dispatched) spot-checks ≥3 cells for source-attribution sanity |

---

## J. Charter-tier-surface (NONE expected — operational uses existing user-authorized adapters)

**Attestation**: This operational sub-plan does NOT surface any new I-S<N>-tier invariant, charter Principle amendment, financial-data-protocol Rule addition, or VBW-protocol checkpoint.

**Why**:
- All 3 ingest CLIs (ingest_vhm + ingest_news_cafef + ingest_fundamentals_vn30) SHIPPED previously through their own charter-coherent design + verifier cycles (Phase D Theme L for news, S32 Track A R2 for bars, S33 for fundamentals)
- All 3 data sources (CafeF + SSI + vnstock VCI) are PUBLIC + FREE-TIER per Charter Principle "No insider information"
- validate_thesis re-run consumes existing V0=6 personas (BUFFETT/GRAHAM/TALEB SHIPPED Phase F-prime F.2 with ADR D-075; BEAR/BULL/QUANT pre-existing) + existing Phase1Synthesizer (deterministic; I-S1 by-construction) + existing SqliteThesisRepository
- INCOMPLETE-corpus early-return at use_case:213-214 is existing logic; STEP 6 corpus-ready re-run does NOT modify it (data path simply doesn't trigger it)
- No new ADR auto-fires; OPTIONAL D-080 cost-attestation (DD-8) is IMPL-tier (auto-ratifies per severity-schema; no charter gate)

**No AskUserQuestion expected at IMPL time** unless RM6 vendor-schema-change forces re-plan (then STOP-AND-ASK main session per STEP 0 reject-and-flag policy).

**No new Rule 16 mode**: validate_thesis already enforces Rule 16 by-construction per existing Phase F-prime F.3 ship (numeric values come from RatioService deterministic compute; LLM only interprets categorical + GroundedPoint outputs).

---

## N. Sub-plan dispatch sequencing + parallel-eligibility

### N.1 — File scope disjoint from plan-041 (CONFIRMED)

| Aspect | This plan-045 | Plan-041 (G.1) |
|---|---|---|
| Architect dispatch | S393 (this) | S392 (parallel, in-flight) |
| IMPL session | S395 (or S394) | S394 (or S395) |
| File scope write | `data/stockforge.sqlite` + `thesis-log/` + `observations/` + optional `decisions/080-*.md` | `packages/_shared/pdf/**` + `packages/application/fundamental/pdf_table_extractor_port.py` + `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` |
| File scope read | apps/cli/, packages/infrastructure/{news,market_data,fundamental}/, packages/application/analysis/use_cases/, apps/_shared/ | packages/domain/fundamental/, packages/infrastructure/fundamental/vnstock_*, research/ |
| Overlap | NONE | NONE |
| Parallel-eligibility | YES per architect-tier precedent S345 4-parallel | YES same |

### N.2 — IMPL dispatch sequencing (RECOMMENDED)

**Recommended sequencing**: Both plan-041 (G.1 IMPL) and plan-045 (DATA-CORPUS IMPL) **parallel-eligible** per disjoint file scope above + plan-025 DD-5 3-parallel ceiling (this is 2-parallel = within ceiling).

**Main session orchestrator decides**:
- (a) Sequential ORDER A: S394 plan-041 G.1 IMPL → S395 plan-045 IMPL — pros: G.1 author S392 returns first (PDF probe is more architect-design-load than data-corpus operational); main session reviews + dispatches G.1 IMPL ahead; THIS plan IMPL waits
- (b) Sequential ORDER B: S394 plan-045 IMPL → S395 plan-041 G.1 IMPL — pros: operational ingestion ships Wave 1 MVP READY faster; G.1 IMPL is more design-load + benefits from later dispatch
- (c) PARALLEL: S394 + S395 dispatched in same turn — pros: highest turn-velocity per architect-tier S345 4-parallel precedent (2-parallel here = within plan-025 DD-5 3-parallel ceiling); cons: 2 dev sessions = more total token spend per turn

**Recommendation**: PARALLEL (option c) IF main session has budget room for 2 MULTI_TASK_IMPL Opus dev sessions in same turn (~400-500K combined); OTHERWISE Order B (plan-045 IMPL first to unlock Wave 1 MVP READY which is higher-MVP-impact than G.1 PDF substrate which is Phase G-prime intermediate).

**Decision is main-session's**, not architect's — this plan declares parallel-eligibility + main session orchestrates.

### N.3 — VERIFY session (optional)

**Recommendation**: SKIP standalone S396 sandwich-verifier dispatch for this operational plan. Rationale:
- DoDs § G are deterministically observable (file existence + SQL rowcounts + thesis-log structural conformance + cost-ledger entries)
- No new production code → no AP-1 self-review concern; dev observation file + verification report self-attestation is sufficient
- Cost-bounded (~80-180K VERIFY Opus saved)
- Precedent: S386 close-bookkeeping for plan-037 NO-OP skipped VERIFY (operational artifact)

**Reverse**: dispatch S396 verifier IF main session detects RM-fire from dev observation; verifier focuses on:
- (a) Per-cell DoD rowcount spot-check (re-run STEP 5 SQL battery independently)
- (b) thesis-log frontmatter `gaps:` field NOT containing 3 corpus gaps
- (c) Cost-ledger entry sanity (cost_usd ≤ 3.00)
- (d) PFP-DONE-7+8 flip evidence in current-execution.md

---

## P. Compliance attestation grid

Pre-filled per template; main session may amend at commit time.

| Item | Status | Evidence |
|---|---|---|
| AP-1 fresh-context dispatch | ✓ | Architect S393 dispatched fresh-context per current-execution.md:144-145; parallel with S392 G.1 architect per architect-tier precedent S345 4-parallel; IMPL S395 (or S394) MUST be fresh-context per AP-1 mandate |
| D-060 no-commits-in-plan-session | ✓ | Architect tools: [Read, Glob, Grep, Write]; no Bash; no commit by architect this session; main session commits plan + dev commits IMPL output per D-060 |
| harness_priority_one | ✓ | Operational not harness; harness in steady-state per S390 commit `e5f17cf`; queue drained 9→0; 2 new candidates L-S389-1+L-S389-2 are 1st-instance per AP-7 deferred until 2nd instance |
| Charter Principle 7 dogfood gate | ✓ | User Q1=A authorization captured at current-execution.md:140 (S391); real-API budget commitment authorized for VHM+HPG+VIC+FPT × 3 sources; satisfies dogfood mandatory requirement |
| Charter Principle 8 calibration | ✓ | Q2=D continue UNCALIBRATED-V0 per current-execution.md:141; cost+quality observation files capture per-persona evidence for future calibration cycle |
| 0 charter writes | ✓ | No PROJECT_CHARTER.md edits this plan |
| 0 constitution writes | ✓ | No agent-workspace/constitution/** edits this plan |
| 0 human-workspace writes | ✓ | No human-workspace/ writes outside auto-mv hook scope (N/A here) |
| VBW protocol applied | ✓ | Every claim cites file:line; this session read 28 source files empirically (calibration summary § A.4 lists all) |
| I-S34 public-sources-only | ✓ | CafeF + SSI iBoard + vnstock VCI all PUBLIC + FREE-TIER; ZERO paid/insider/scraping-bypass channels per § A.1 + § A.4 |
| Cold-start declared | ✓ | task_class="data-corpus-operational"; sample_size=0; budget envelope 150-180K Opus PLAN per § A.4 |
| Phase 1b CONSUMED | ✓ | This plan has ≥3 sub-tracks (7 STEPs); Phase 1b mandate satisfied per sandwich-architect.md:42-65 |
| L-S345-1 architect-LOC-drift discipline | ✓ best-effort | Plan author estimates STEP-by-STEP wall-clock + budget envelopes; operational plan touches mostly data/markdown not code so LOC-discipline less load-bearing |
| L-S385-2 attestation-vocabulary | ✓ | Plan uses CODE-READY-DATA-PENDING / READY / BLOCKED-BY-X vocabulary per plan-039 D7.B promote |
| stop_offering_routing_branches | ✓ | Plan does not enumerate (a)/(b)/(c) "what next" options; main session orchestrates dispatch per autonomous-full |
| dont_self_pause_at_session_boundary | ✓ | Architect output = this plan + companion observation; main session dispatches IMPL after review without self-pause |

---

## Q. Companion observation

Return-summary observation written by THIS architect at:

`agent-workspace/memory/observations/sandwich-architect-S393-data-corpus-ingestion-operational-plan.md`

Summarizing: (a) sub-plan LOC + STEP count (b) STEP 0 probe count (c) DD count + top 3 design decisions (d) DoD-criteria count (e) RM count + top 3 risks (f) parallel-dispatch compatibility with S392 plan-041 (g) expected IMPL-session budget envelope.

---

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches plan-045 IMPL (sandwich-dev) per § N sequencing; parallel-eligible with plan-041 G.1 IMPL per § N.1 file scope disjoint.
