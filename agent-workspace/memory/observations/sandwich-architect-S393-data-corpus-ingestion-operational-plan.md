---
observation_type: sandwich-architect-return
session_id: S393
agent_id: sandwich-architect (background dispatch from main session orchestrating Phase F-prime DATA-PENDING + Phase G-prime parallel architect)
dispatched_by: main session per current-execution.md:144-146 S391 dispatch table
parent_plan: 045-S393-data-corpus-ingestion-operational-plan
authored: 2026-05-17
model: Claude Opus 4.7
budget_actual: ≤180K Opus PLAN target (within 150-230K Opus PLAN envelope per CLAUDE.md § Session Types)
authoring_context: PARALLEL with S392 G.1 architect (current-execution.md:144) per architect-tier precedent S345 4-parallel; disjoint file scope verified
---

# S393 sandwich-architect return — Data-Corpus Operational Plan-045 Authored

## (a) Sub-plan LOC + STEP count

- **Plan-045 LOC**: ~614 LOC (markdown)
- **Total STEPs**: 7 (STEP 0 audit + STEP 1-7 execution sub-tracks per § E)
- **STEP 0 sub-probes**: 5 (STEP 0.1-0.5 per § C)
- **Top-level sections**: A (Goal/Scope) + B (NOT-scope) + C (STEP 0 probes) + D (DDs) + E (Sub-tracks) + F (File scope) + G (DoDs) + H (RMs) + J (Charter-tier-surface) + N (Sequencing) + P (Compliance) + Q (Companion observation reference)

## (b) STEP 0 probe count

**5 deterministic VBW probes** BEFORE STEP 1 bulk-fetch:

1. STEP 0.1 — CafeF crawler adapter availability + RateLimiter substrate check (read-only Grep + Read on 3 paths)
2. STEP 0.2 — SSI adapter availability + VHM/HPG/VIC/FPT VN30 universe shape check
3. STEP 0.3 — vnstock fundamental adapter availability + ticker shape check
4. STEP 0.4 — **Cold-probe ONE ticker × ONE source** (VHM × CafeF) — empirical wire test ~3-5 min wall-clock; reject-and-flag if FAILS per RM6 vendor-schema-change canary
5. STEP 0.5 — Empirical baseline `sqlite3 data/stockforge.sqlite` BEFORE state capture (file existence + per-ticker COUNT(*) baselines for bars/news/statements/theses)

## (c) DD count + top 3 design decisions

**Total DDs**: 8 (DD-1 batch size / DD-2 date range / DD-3 news cap / DD-4 fundamental depth / DD-5 idempotency / DD-6 failure policy / DD-7 re-run scope / DD-8 optional ADR)

**Top 3 design decisions** (highest decision-load):

1. **DD-7 validate_thesis re-run scope = VHM MANDATORY + HPG/VIC/FPT OPTIONAL** — single-ticker mandatory clears PFP-DONE-7+8 GREEN; optional extras bounded by HARD CAP $3.00/ticker × 4 = up to $12 vs $3 single-ticker; Karpathy P2 narrowest-scope-first; main session orchestrates IMPL dispatch budget envelope per Opus FOCUSED_IMPL (VHM-only 100-150K) vs MULTI_TASK_IMPL (full-4 200-330K)

2. **DD-1 batch size = SERIAL-CLIs-PER-SOURCE-WITH-MULTI-TICKER-FLAG** — each existing CLI accepts `--tickers VHM,HPG,VIC,FPT` subset; invoke each CLI ONCE not 4× per ticker; sources serial (STEP 2 CafeF → STEP 3 SSI → STEP 4 vnstock) because (a) BC-5 plan 020 DD-2 sync-only-no-async carry-forward, (b) deterministic for STEP 5 verification, (c) ~30-60 min total well within MULTI_TASK_IMPL window

3. **DD-3 CafeF news count cap = ≥30 articles per ticker** (sentiment-meaningful baseline) — achieved via `--max-articles 800 --listing /thi-truong-chung-khoan.chn,/doanh-nghiep.chn` multi-listing CSV per ingest_news_cafef.py:202-216 quota distribution; rationale: 800 × ~0.20 VN30 mention rate × 1 listing = ~160 per ticker average; safe margin above 30 floor for blue chips VHM/HPG/VIC/FPT

## (d) DoD-criteria count

**13 DoD items** (§ G items G.1-G.13):

- G.1-G.4: per-cell rowcount thresholds across 12 cells (4 tickers × 3 sources)
- G.5-G.6: validate_thesis VHM re-run completes WITHOUT INCOMPLETE-corpus + persisted thesis-log markdown
- G.7-G.8: PFP-DONE-7 + PFP-DONE-8 flip from PENDING to GREEN in current-execution.md
- G.9: cost-ledger.tsv entry recorded per auto Stop hook
- G.10-G.11: STEP 0 baseline + STEP 5 delta in verification report + dev observation
- G.12: Commit per D-060 with prescribed message format; 0 git push
- G.13 (OPTIONAL per DD-8): ADR D-080 IF ≥2 ticker re-runs

## (e) RM count + top 3 risks

**Total RMs**: 6 (RM1-RM6 per § H)

**Top 3 risks**:

1. **RM6 vendor schema-change canary** (MEDIUM probability) — CafeF HTML selector drift / SSI endpoint shift / vnstock library version bump since S384 dogfood (Feb 2026 timestamp); mitigation = STEP 0.4 cold-probe VHM × CafeF is the canary (smallest sample; fastest probe); reject-and-flag if FAILS (STOP-AND-ASK main session); per-cell graceful-fail per existing ingest CLI error handling (continue-others per DD-6)

2. **RM2 wall-clock overrun** (MEDIUM probability) — 4 tickers × 3 sources × cold-probe per-cell + 1-4 validate_thesis re-runs estimated ~45-90 min mandatory / ~90-180 min full-4-ticker; mitigation = MULTI_TASK_IMPL Opus 200-330K budget cite per L-S365-1 prevention rule; OR split into 2 FOCUSED_IMPL sessions if overrun (STEP 1-5 ingest+verify / STEP 6.1 + STEP 7 re-run+commit); DD-7 narrowest-scope VHM-only fallback always available

3. **RM1 rate-limit hit** (MEDIUM probability) — CafeF 429/503 + SSI rate-cap + vnstock VCI guest tier hard cap; mitigation = existing RateLimiter substrate exponential back-off per BC-5 reliability skill + each CLI has built-in rate-limit-aware delays; IF STILL hit: re-run idempotent CLI per DD-5 (UPSERT semantics convergence)

## (f) Parallel-dispatch compatibility with S392 plan-041

**FILE SCOPE DISJOINT — VERIFIED**:

| Aspect | This plan-045 | Plan-041 (G.1) |
|---|---|---|
| Architect dispatch | S393 (this; background) | S392 (parallel; in-flight) |
| IMPL session | S395 (or S394) | S394 (or S395) |
| File scope WRITE | `data/stockforge.sqlite` + `thesis-log/` + `observations/` + optional `decisions/080-*` + `current-execution.md` close-bookkeeping | `packages/_shared/pdf/**` + `packages/application/fundamental/pdf_table_extractor_port.py` + `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` |
| Overlap | NONE | NONE |
| Parallel-eligibility | YES per architect-tier precedent S345 4-parallel | YES same |

**Net**: Both architects (S392 + THIS S393) safely running in PARALLEL this turn per architect-tier S345 precedent. Both IMPL sessions PARALLEL-ELIGIBLE per disjoint file scope + plan-025 DD-5 3-parallel ceiling (this is 2-parallel = within ceiling).

**Recommendation to main session**: PARALLEL IMPL dispatch (option c per § N.2 of plan-045) IF budget room for 2 MULTI_TASK_IMPL Opus dev sessions in same turn (~400-500K combined); OTHERWISE plan-045 IMPL FIRST (Order B per § N.2) to unlock Wave 1 MVP READY which is higher-MVP-impact than G.1 PDF substrate.

## (g) Expected IMPL-session budget envelope

**Default**: MULTI_TASK_IMPL Opus 200-330K window for full-scope IMPL (VHM mandatory + optional HPG/VIC/FPT re-runs + commits + optional ADR D-080)

**Fallback**: FOCUSED_IMPL Opus 100-150K window for VHM-only narrowest-scope per DD-7 (clears PFP-DONE-7+8 GREEN with minimum scope)

**Cost-ledger envelope** (Anthropic spend for validate_thesis re-run portion):
- VHM-only: ≤ $3.00 HARD CAP per validate_thesis_phase1.py:189
- Full-4: ≤ $12.00 HARD CAP (4 × $3.00)
- Operational ingestion portion (CafeF + SSI + vnstock): $0 vendor-API cost (all free-tier per Charter Principle "public sources only")

**Wall-clock envelope**: ~45-90 min mandatory-only; ~90-180 min full-4-ticker

**VERIFY session**: SKIP STANDALONE per § N.3 recommendation (DoDs deterministically observable; no new production code → no AP-1 self-review concern); reverse only if RM-fire detected from dev observation.

---

## Additional architect notes

### Critical empirical finding — DB path mismatch

The 3 existing ingest CLIs default to DIFFERENT SQLite files:
- `ingest_vhm.py` → `./data/vhm.sqlite`
- `ingest_news_cafef.py` → `./data/vn30-news.sqlite`
- `ingest_fundamentals_vn30.py` → `./data/vn30-fundamentals.sqlite`

But `validate_thesis.py` consumes `data/stockforge.sqlite` per validate_thesis.py:65 default. Plan-045 STEP 1-4 ALL ENFORCE `--output data/stockforge.sqlite` override to consolidate corpus into the canonical DB. This is the SINGLE MOST IMPORTANT operational discipline in the plan; if dev forgets the override on ANY of the 3 ingest CLIs, the corresponding cell will remain ZERO in stockforge.sqlite and validate_thesis re-run will still hit INCOMPLETE-corpus early-return.

### S384 INCOMPLETE-corpus exemplar gap-list = EXACT 3 gaps to close

`agent-workspace/memory/thesis-log/2026-05-17-VHM.md:13` shows `gaps: ['price_stale', 'fundamentals_stale', 'no_news_90d']` — these are EXACTLY the 3 gaps detected at `use_case_builder.py:466-471`. STEP 6 corpus-ready re-run DoD: thesis-log frontmatter `gaps:` field MUST NOT contain any of these 3 strings (it may contain other gaps like 'cost_budget_exceeded' or 'bear_case_invariant_failed' — those are NON-corpus-related and legitimate).

### Idempotency by-construction verified across all 3 repositories

All 3 SQLite repositories use INSERT OR REPLACE explicitly:
- `sqlite_bar_repository.py:101` (save_many) + `:134` (save_many_by_ticker)
- `sqlite_news_repository.py:93` (news_articles) + `:203` (extracted_claims) + `:15` docstring "Both tables: INSERT OR REPLACE so idempotent re-runs converge"
- `sqlite_fundamental_repository.py:101` (financial_statements)

Net effect: dev may re-run any STEP 2/3/4 invocation a second time without corpus duplication. STEP 5 verification includes optional idempotency-spot-check (re-run yields ZERO delta rows).

### Phase G-prime sub-plan 041 parallel architecture

Plan-040 reserves plan numbers 040-044 for Phase G-prime master plan + sub-plans G.1-G.4. This operational plan uses 045 (next free) per plan-040 § N explicit constraint. File scope verified disjoint per § N.1 of plan-045. Architect-tier S345 4-parallel precedent supports parallel dispatch of S392 (G.1 architect) + THIS S393 (data-corpus architect) — both running in background this turn.

### Compliance with CLAUDE.md hard rules

- ✓ No production code authored
- ✓ No commits by architect (architect tools: [Read, Glob, Grep, Write]; no Bash)
- ✓ No charter / no constitution / no human-workspace writes
- ✓ No plan 040-044 touches (read-only references)
- ✓ Plan number 045 verified next-free via Glob agent-workspace/session-plans/pending/*.md
- ✓ ADR D-080 slot verified available via Glob agent-workspace/memory/decisions/080-*.md
- ✓ VBW protocol applied — 28 source files read empirically (full list in plan § A.4 Calibration summary)
- ✓ Phase 1b CONSUMED variant (≥3 sub-tracks = 7 STEPs); cold-start declared for task_class="data-corpus-operational"
- ✓ L-S385-2 attestation vocabulary used (CODE-READY-DATA-PENDING / READY / BLOCKED-BY-X)
- ✓ Cost-budget rationale documented per DD-7 + RM4 + Charter Principle 7+8

### What main session does next (after this architect returns)

1. Review plan-045 + this observation
2. Decide IMPL dispatch sequencing per § N.2 of plan-045 (PARALLEL with G.1 IMPL OR sequential with plan-045 first OR G.1 first)
3. Commit plan-045 + this observation per D-060 (architect output)
4. Dispatch IMPL session (S394 or S395) per chosen sequencing
5. POST IMPL return: review dev observation; SKIP VERIFY per § N.3 unless RM-fire detected; close-bookkeeping mv plan-045 pending → completed + update current-execution.md PFP-DONE-7+8 GREEN

---

> Observation file ends. Architect S393 return complete.
