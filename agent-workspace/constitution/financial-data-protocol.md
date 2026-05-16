# Financial Data Protocol — StockForge

> Stock-specific data integrity rules. Real money depends on these.
> Companion to `invariants.md`. Read both before working with any data layer.

## Why This Exists

Stock data has unique failure modes that don't exist in idea-validation or general SaaS:
- **Look-ahead bias** — using data agent didn't have at decision time → fake "winning" backtest
- **Survivorship bias** — only training on companies still trading → models that fail on real future
- **Adjustment confusion** — comparing pre-split price to post-split → 10x errors
- **Stale fundamentals** — using FY2023 filed in March 2024 for January 2024 decision → impossible-in-reality
- **Currency drift** — FX changes between price update and conversion → silent value distortion
- **Source disagreement** — vnstock vs FiinPro vs TCBS disagree → which to trust?

This protocol is the answer to each.

---

## Rule 1: Point-in-Time Integrity

### The Problem

You query "what was company X's P/E on 2023-06-15?" The naive answer uses Q1 2023 EPS. But Q1 2023 was filed on 2023-04-30 — was it really known on April 30, or April 28? When did ratios get computed? Different sources have different filing dates for the same period.

### The Rule

Every fundamental data record has THREE date fields:
- `period_end` — what period this represents (e.g., 2023-03-31 for Q1 2023)
- `filing_date` — when this was officially published
- `ingested_at` — when our system learned about it

For backtest: filter `WHERE filing_date <= as_of_date AND ingested_at <= as_of_date`.
For live: filter `WHERE filing_date IS NOT NULL` (no in-progress estimates).
For estimates/forecasts: separate table `forecasts` with `forecast_date`, `for_period_end`, `source`.

### The Enforcement

`FundamentalRepository` has only two methods:
- `get_as_of(ticker, as_of_date)` — uses point-in-time filter
- `get_latest(ticker)` — uses today's date

There is no `get_all()` or `get_by_period()` that could be misused for backtest.

---

## Rule 2: Survivorship-Aware Universe Construction

### The Problem

If you backtest "buy stocks with P/E < 10 in 2018, hold 3 years", and your dataset only includes companies still listed in 2024, you've cherry-picked survivors. Real 2018 universe included companies that later went bankrupt or got delisted.

### The Rule

- Universe table includes ALL stocks ever traded, with `first_traded_at`, `delisted_at`, `suspended_periods`
- Backtest universe construction: `WHERE first_traded_at <= as_of_date AND (delisted_at IS NULL OR delisted_at > as_of_date) AND NOT in_suspension(ticker, as_of_date)`
- Delisted stocks keep their full price history
- "Why delisted" tagged: `BANKRUPTCY | MERGER | PRIVATIZATION | EXCHANGE_MIGRATION | OTHER`

### The Enforcement

Backtest framework `Universe.construct(as_of_date)` returns the survivor-aware universe. There is no `Universe.current_listed_only()` method available in backtest paths.

CI gate checks: backtest dataset must include at least 5% delisted stocks. Less = warning that dataset is suspect.

---

## Rule 3: Adjustment Type Tagging

### The Problem

Stock at 100,000 splits 1:2 → next day at 50,000. If you look at raw historical data, looks like 50% loss. Adjusted data smooths this out, but mixing adjusted (for chart) with unadjusted (for transaction calculation) gives 10x errors.

### The Rule

Every price record has `adjustment_type`:
- `NONE` — raw historical (what you actually paid)
- `DIVIDEND` — adjusted for dividends only
- `SPLIT` — adjusted for splits only
- `BOTH` — fully adjusted (typical for charts/return calc)

`Quote` value object has `adjustment_type` field. Repository methods are explicit:
- `get_quotes_adjusted(ticker, range)` → returns BOTH
- `get_quotes_raw(ticker, range)` → returns NONE
- No mixed query allowed.

### The Enforcement

Quote dataclass enforces `adjustment_type` not None. Mixing in same calculation raises `MixedAdjustmentError`.

---

## Rule 4: Source Attribution & Reconciliation

### The Problem

vnstock says HPG Q3 2024 revenue = 35,000 tỷ. FiinPro says 35,200 tỷ. TCBS says 34,800 tỷ. Which is "true"?

### The Rule

- Every data point stores `source_provider` (enum: VNSTOCK | FIINPRO | TCBS | SSI | MANUAL | SCRAPED_<source>)
- "Truth" view materialized via reconciliation rules:
  - If only one source: that's the truth
  - If sources agree (within 1% tolerance): truth = average, confidence = HIGH
  - If sources disagree (>1%): truth = manual override OR flag for review, confidence = LOW
  - Manual override always wins, with `override_reason` documented
- UI shows truth value + "X of Y sources confirm" badge

### The Enforcement

`ReconciledFundamental` view in DB. Application layer queries reconciled view by default. Raw single-source queries explicitly via `RawFundamentalRepository` for debugging only.

---

## Rule 5: Currency Discipline

### The Problem

VND fundamentals + USD foreign comparable + EUR debt instrument = silent type confusion if not strict.

### The Rule

- `Money` value object always has `currency` field (default VND for domestic data)
- Cross-currency math requires explicit `convert(target_currency, as_of_rate)` call
- FX rates stored with `as_of_date` (point-in-time integrity applies)
- No implicit conversion — `Money(100, USD) + Money(2_000_000, VND)` raises `CurrencyMismatchError`

### The Enforcement

`Money` dataclass `__add__`, `__sub__`, `__mul__` validate currency. CI test verifies no implicit conversion possible.

---

## Rule 6: LLM Output Provenance

### The Problem

LLM extracts "HPG announced 30% dividend increase" from a news article. Two months later, you wonder: was that real or hallucinated?

### The Rule

Every LLM-extracted claim record has:
- `source_url` — where extracted from (URL or file path)
- `source_text_excerpt` — exact text quoted (≤500 chars)
- `extractor_model` — model name + version (e.g., "claude-sonnet-4-6")
- `extractor_prompt_hash` — hash of system prompt used (for reproducibility)
- `extractor_version` — code version (commit hash)
- `extracted_at` — timestamp
- `confidence_extracted` — LLM's stated confidence in the extraction (0-1)
- `verified_by_human` — bool (default false)

Without all these fields, claim cannot be inserted to DB.

### The Enforcement

Repository constructor validates all fields. Schema NOT NULL constraints. Verifier agent randomly samples 5% of new claims for human review queue.

---

## Rule 7: Sentiment Score Calibration

### The Problem

LLM says "this article is 80% bullish". What does 80% mean? Is it calibrated to anything?

### The Rule

Sentiment scores are categorical, not numeric:
- `STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH`

Plus extracted features:
- `mentioned_tickers: list[Ticker]`
- `key_phrases: list[str]`
- `tone_indicators: list[str]` (e.g., "uses superlatives", "compares to leader", "raises concern")

Aggregation to "sentiment score" happens in code, not LLM:
- e.g., `sentiment_score = (bullish_count - bearish_count) / total_count` over a time window

### The Enforcement

Sentiment LLM tasks return enum, not number. Application layer converts to score with explicit formula. Backtest can validate which scoring formula correlates with subsequent price moves.

---

## Rule 8: Anti-Look-Ahead in News & Sentiment

### The Problem

You backtest "buy stocks with positive news momentum". But the news article from Jan 15 might have been published 8pm — too late to act. Or the sentiment was scored 3 days later when more context was available.

### The Rule

Every news/sentiment record has:
- `published_at` — when source published it (best estimate)
- `ingested_at` — when our system saw it
- `scored_at` — when sentiment was computed

Backtest filters: `WHERE published_at <= as_of_date AND scored_at <= as_of_date AND published_at + acting_lag <= action_date`

Where `acting_lag` = realistic time between news and possible trade (e.g., next day open if published after market close).

### The Enforcement

News/sentiment repository has only `get_known_as_of(ticker, as_of_date)` method for backtest. The lag is enforced in the query.

---

## Rule 9: KOL Recommendation Provenance

### The Problem

KOL says "buy HPG" in a 30-minute video. When exactly? Was it part of a long disclaimer? Was it conditional ("if breaks 30k then buy")?

### The Rule

Extracted KOL recommendations include:
- `source_url` — full video/post URL
- `timestamp_in_source` — for video: timestamp range (e.g., "12:34-13:02")
- `transcript_excerpt` — exact text quoted
- `extracted_intent` — categorical: STRONG_BUY | BUY | WATCH | NEUTRAL | AVOID | STRONG_AVOID
- `extracted_conditions` — list of conditions if any (e.g., "if VN-Index above 1300")
- `extracted_timeframe` — INTRADAY | DAYS | WEEKS | MONTHS | LONG_TERM
- `extraction_confidence` — how confident extractor is (separate from intent strength)
- `kol_id` — links to BC-6 KOL profile
- `published_at` — when video/post went live

If extraction confidence < 0.7, flag for human review before counting in calibration.

### The Enforcement

Recommendation aggregate validates fields. Calibration database only includes `extraction_confidence >= 0.7` records.

---

## Rule 10: Backtest Reproducibility

### The Problem

You ran a backtest 6 months ago, got 23% return. Today you run "the same backtest" and get 18%. Why? Different code? Different data? You can't tell.

### The Rule

Every backtest run records:
- `code_commit_hash` — full git hash of stockforge at run time
- `data_snapshot_id` — reference to DB snapshot or "live as of date"
- `config_file_hash` — hash of strategy config used
- `random_seed` — fixed seed
- `started_at`, `finished_at`, `duration_ms`
- `result_summary` — dataclass with all key metrics
- `result_full_path` — R2 link to detailed trade log

Backtest framework auto-records all of this. Re-running same `(commit, snapshot, config, seed)` must produce identical result.

### The Enforcement

Backtest engine validates inputs present before running. Output stored immutable. CI test: run same backtest twice, assert identical output.

---

## Quick Reference Table

| Concern | Rule | Enforcement |
|---|---|---|
| Look-ahead in fundamentals | I-S2, Rule 1 | `get_as_of()` only |
| Survivor bias | I-S3, Rule 2 | Universe includes delisted |
| Price adjustment confusion | I-S4, Rule 3 | `adjustment_type` mandatory |
| Source disagreement | I-S5, Rule 4 | Reconciled view |
| Currency confusion | I-S6, Rule 5 | `Money` enforces currency |
| LLM hallucination | I-S1, Rule 6 | Provenance fields mandatory |
| Sentiment vagueness | Rule 7 | Categorical, not numeric |
| News lag | Rule 8 | `acting_lag` in queries |
| KOL recommendation context | Rule 9 | Conditions + timeframe required |
| Backtest reproducibility | I-S53, Rule 10 | Auto-record metadata |
| LLM emitting numeric field | I-S1-1, Rule 16 | EchoValidator + schema-discriminator hook |

---

## When This Protocol Conflicts With Convenience

It will. You'll want to query "latest" data for a backtest because it's faster. You'll want to skip currency tag for prototype. You'll want to dump LLM output without provenance for first version.

**Don't.**

The protocol exists because every shortcut compounds. A backtest with look-ahead bias won't fail loudly — it'll just give you false confidence and you'll lose money in production.

If the protocol genuinely blocks legitimate work, that's a constitutional amendment discussion, not a workaround.

---

## Rule 11 — Hook Portability Per Phase (D-019, ratified 2026-05-04)

The data-integrity hooks in `scripts/hooks/` (telemetry, drift signals, learning-data sweepers, citation grep) enforce Rules 1-10. They must remain portable across phase boundaries so a fresh project clone reproduces the same enforcement without external toolchain installation.

### Phase 0 (Harness Bootstrap) — bash + POSIX only

During Phase 0, hooks MUST use bash + POSIX utilities only. Forbidden: `python`/`python3`, `jq`/`yq`, `pip`/`npm`/`pnpm`. Reason: a fresh user cloning the repo at Phase 0 has not yet provisioned a Python venv or jq install; hook failures at SessionStart create a worse first impression than no hook.

**Enforcement**: `scripts/hooks/bash-hook-lint.sh § Check 1 L-S11-1` scans `scripts/hooks/*.sh` and (post D-019 ratification) HARD-fails on any non-Phase-0-portable invocation when `STOCKFORGE_HOOK_PROFILE=strict`.

### Phase 1+ (Data Pipeline Active) — Python + jq accepted

Once Phase 1 ships the Python venv + data dependencies (`pyproject.toml` provisioned), hooks may invoke Python and jq. The bash-hook-lint check downgrades L-S11-1 to informational severity at phase boundary (config flag: `STOCKFORGE_HOOK_PORTABILITY_TIER=1`).

### Why This Matters for Financial Data Integrity

A Phase 0 hook that depends on jq for JSON parsing fails silently when jq is missing. Silent hook failure = drift signal not firing = data-integrity violation goes undetected. The portability rule is upstream of every Rule 1-10 enforcement.

---

## Rule 12 — T+2.5 Settlement Timing Awareness (D-021, ratified 2026-05-04)

VN equities settle T+2.5 (trade date + 2.5 trading days). Backtests that ignore T+2.5 over-count compoundable cash by 2-3 trading days, producing false-positive performance especially for high-turnover strategies.

- Every `Position` tracks `opened_at` = trade-match date (NOT cleared-cash date).
- Every cash-flow record carries `cleared_at = opened_at + T+2.5 trading days` via VN trading calendar (not naive +3 calendar days).
- Backtest re-investment cash queries: `WHERE cleared_at <= action_date`.
- `PositionRepository.compute_cleared_cash(as_of_date)` is the only path; `available_cash()` shortcut forbidden.
- Phase 1 thin-slice exception: `Position.opened_at` required; T+2.5 cash gating deferred to Phase 2 (intraday + cash management). See I-S55.

## Rule 13 — Room Ngoại (Foreign-Ownership Cap) Detection (D-021)

Foreign investors face per-stock ownership ceilings (banking ≤30%, real estate ≤49%, others variable). When saturated, foreign buy-pressure cannot accumulate further — strategies keying on "foreign accumulation" silently fail. Strategies pumping on "Room ngoại near full" need explicit saturation regime tagging.

- Every `Bar` (BC-1) carries `foreign_buy_volume` + `foreign_sell_volume`.
- NEW per-Ticker daily snapshot `ForeignOwnershipState(ticker, date, foreign_owned_shares, foreign_cap_shares, saturation_pct, source_provider, ingested_at, as_of)`.
- `saturation_pct = foreign_owned_shares / foreign_cap_shares`. When `>= 0.95`, mark saturation regime explicitly.
- Source provenance: HOSE listed-stocks portal + vnstock `room_ngoai()` endpoint + TCBS reconciliation per Rule 4. Tolerance = 1% of cap (not of saturation_pct).
- Backtest queries on foreign accumulation MUST filter `WHERE saturation_pct < 0.95 OR explicit_saturation_strategy = TRUE`. See I-S56.

## Rule 14 — Sàn HOSE / HNX / UPCoM Data-Quality Tiering (D-021)

VN listed equities split across 3 exchanges with different data quality, filing cadence, and reconciliation tolerance. Treating UPCoM Bars with HOSE-trust produces false-positive backtest signals on noisy UPCoM data.

- Every `Ticker` infers Sàn at construction (HOSE | HNX | UPCoM).
- Every `Bar` carries `sàn` field (denormalized from Ticker for query performance; per-Sàn reconciliation runs in Rule 4).
- Reconciliation tolerance per Rule 4 is Sàn-tiered:
  - HOSE: ±1% (existing tolerance preserved)
  - HNX: ±2% (mid-cap, slightly noisier filings)
  - UPCoM: ±5% (micro-cap, frequent stale data; Sàn-tier downgrade flag mandatory)
- Phase 1 thin-slice: HOSE only.
- `Bar.__post_init__` validates `sàn ∈ {HOSE, HNX, UPCoM}`; `ReconciliationService.tolerance_for(bar)` returns Sàn-tier tolerance. See I-S59 + I-S64.

## Rule 15 — FX VND-USD Point-in-Time Discipline (D-021)

VN equities priced VND. Cross-currency comparisons (e.g., regional comparable PE) require explicit FX with as_of_date integrity. Rule 5 mandates `Money.convert(target_currency, as_of_rate)`; Rule 15 codifies VN specifics.

- FX rates stored as `FxRate(currency_pair, as_of_date, rate, source_provider, ingested_at)`.
- `source_provider` for FX MUST be one of: `SBV` (State Bank of Vietnam Tỷ giá trung tâm) | `VCB` (Vietcombank cash quote) | `VNSTOCK` (vnstock historical FX). NEVER LLM-extracted (I-S1).
- `Money.convert(target_currency, as_of_date)` resolves via `FxRateRepository.get_as_of()` — NOT current-day rate. If as_of pre-dates earliest stored rate, raise `FxRateNotAvailableError`.
- Backtest cross-currency: every conversion records `(amount_native, amount_target, fx_rate_used, fx_as_of_date, fx_source)` for Rule 10 reproducibility.
- Phase 1 thin-slice: VND only; FX subsystem stubbed.

### Why Rules 12-15 Are Phase-1-Compatible Even Though Phase 1 Doesn't Enforce Them

Codified now to anchor S27-S28 entity design (Bar.sàn field, Position.opened_at semantics, FX placeholder structure) so Phase 2 enforcement layers slot into existing types without retrofitting. Matches Charter "When in doubt, simplify" + "Ship thin slices".


## Rule 16 — Numeric-Field Discipline (I-S1-1) (ACCEPTED 2026-05-16 via Q-INT-2026-05-6 ratification + S336 user pick; ratified D-065)

### The Problem

Charter Principle 9 ("No LLM math") + I-S1 ("No LLM Math") + I-S7 ("Confidence ≠ Hit
Rate") together forbid the LLM from generating numbers, but operate at the prose / output
layer. They do not constrain the **schema** layer: a Pydantic / dataclass field declared
`confidence: float` or `price_target: float | None` is itself an invitation for the LLM
to emit a numeric value, and downstream code that consumes that field will treat the
LLM-emitted number as data.

Phase A's 15 deep-dive observations (Wave-1 research integration, S323-S324) found this
pattern in 3 candidate repos: ai-hedge-fund (`src/agents/warren_buffett.py:13-16` —
`confidence: int 0-100`), TradingAgents (`tradingagents/agents/schemas.py:127, :199` —
`entry_price` + `price_target` Optional[float]), and TradingAgents-CN
(`tradingagents/agents/trader/trader.py:68-80` — explicit "🚨 强制要求提供具体数値"
mandating LLM-emitted confidence + risk score). Each is a violation of the rule this
Rule 16 codifies. Two counter-examples (FinceptTerminal `NotifLevel` bounded enum at
`services/notifications/NotificationService.h:15` + Vibe-Trading deterministic
`confidence=low` enforcement at `SKILL.md:138-139`) show the correct shape.

### The Rule

**An LLM never emits a numeric value as the source-of-truth for an output field.** This
applies to **every** dataclass / Pydantic / TypedDict / event schema field whose type is
`int`, `float`, `Decimal`, `complex`, `numpy.number`, or any container parameterized on a
numeric scalar (e.g. `list[float]`, `dict[str, int]`, `tuple[float, ...]`) — and to any
free-text output that, when parsed, would yield a numeric scalar of these types.

A field whose type is numeric, and whose value originates in or transits through an LLM
call, MUST satisfy at least one of:

1. **Categorical surrogate**: The field is replaced with an `Enum` or `Literal[...]`
   bounded categorical (per the FinceptTerminal `NotifLevel` and Vibe-Trading
   `confidence=low` patterns above; per existing `financial-data-protocol.md` Rule 7
   `STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH`). The LLM picks a
   category; deterministic code converts to a number downstream if/when needed.

2. **Deterministic-pipeline echo**: The field's value is computed by deterministic code
   (a non-LLM Python function operating on verified inputs per Rule 6 LLM Output
   Provenance, Rule 4 Source Attribution, and the source_evidence chain of the calling
   use case). The LLM is permitted only to **echo** that computed value back inside its
   structured output. Echo validation is mandatory: the post-LLM step asserts the
   LLM-echoed value equals (or matches within tolerance) the upstream computed value.
   Mismatch is a HARD ERROR (raise + abort; never silently coerce).

3. **Calibration-database lookup**: For confidence-like fields specifically, the value
   is sourced from `agent-workspace/calibration/` keyed on (`extractor_version`,
   `signal_type`) tuple. The lookup is a deterministic dictionary access on calibration
   data captured per Charter Principle 8 ("Calibration over confidence"). The LLM never
   computes nor estimates this value.

4. **NULL / unknown surrogate**: For fields where neither a categorical nor a
   deterministic pipeline value exists, the field MUST be `Optional[T]` AND the LLM-
   produced output sets it to `None`. Downstream consumers treat `None` as
   "uncomputed", never as "zero" or "unknown-but-implied-low".

### The Enforcement

**At schema definition time** (mypy --strict + ruff custom rule, planned IMPL hook):
- Any new dataclass / TypedDict / Pydantic field with a numeric type, declared in a path
  that participates in an LLM call site (initial scope: `packages/contracts/events/**`,
  `packages/domain/**`, BC-6 + BC-8 schema modules), MUST have one of: (a) a sibling
  `*_source: Literal["categorical", "deterministic", "calibration", "null"]` discriminator
  field; (b) a module-level docstring asserting "no LLM call paths populate this field";
  (c) an explicit `# I-S1-1: deterministic echo of <fn>(...)` inline comment naming the
  upstream computation.
- A dedicated hook at `scripts/hooks/numeric-field-discipline-check.sh` (planned; not
  authored by this proposal) lints these constraints.

**At runtime** (validator + verifier agent):
- Application-layer use cases that invoke an LLM and consume a numeric output field
  validate the LLM-echoed value against the upstream deterministic-pipeline computation.
  The validator is `EchoValidator.validate(llm_value, deterministic_value,
  tolerance=...)`.
- The verifier agent randomly samples 5% of new event records where a numeric field
  participates in an LLM call site, for human review queue (parallels Rule 6's existing
  5%-sampling enforcement).

**At amendment time**:
- Adding a new numeric field to any schema in scope (above) requires the change-author
  to specify which of the 4 satisfaction modes (categorical, deterministic-echo,
  calibration, null) applies, recorded in the field docstring. A constitution
  amendment for this Rule 16 is required to introduce a new satisfaction mode.

### Fields explicitly subject to this rule (initial inventory, non-exhaustive)

- `packages/contracts/events/kol_recommendation_extracted.py`
  `KolRecommendationExtracted.confidence_extracted: float` (existing per
  `agent-workspace/constitution/architecture.md:300`) — satisfies via mode 3 (calibration
  lookup) once BC-6 KOL extractor wires to `agent-workspace/calibration/` per Rule 9 +
  I-S20.
- Future BC-8 output schemas to be created by Phase F-prime (Theme H IMPL per Wave-1
  master plan § 6.4.3): the equivalent of `ResearchPlan` / `TraderProposal` /
  `PortfolioDecision` (TradingAgents source schemas at `tradingagents/agents/schemas.py`)
  — schemas MUST ban `entry_price` + `price_target` LLM-emit per
  `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § H.3` mitigation #4, or substitute mode
  2 (deterministic-pipeline echo) via BC-2 DCF / multiple-derivation pipeline once that
  pipeline lands.

### Cross-references

- Charter Principle 9 ("No LLM math") — parent principle this rule operationalizes.
- Charter Principle 8 ("Calibration over confidence") — provides the calibration-database
  satisfaction mode (#3 above).
- I-S1 ("No LLM Math") — sibling general-form invariant in
  `invariants-stockforge.md`.
- I-S7 ("Confidence ≠ Hit Rate") — sibling semantic invariant; Rule 16 enforces I-S7 at
  the schema layer.
- Rule 6 ("LLM Output Provenance") — sibling rule in this same file; Rule 16 extends
  Rule 6 to numeric-field semantics specifically.
- Rule 7 ("Sentiment Score Calibration") — precedent for categorical surrogate
  pattern (mode #1).
- Rule 9 ("KOL Recommendation Provenance") — already requires
  `extraction_confidence` field semantically; Rule 16 enforces the deterministic
  source for that confidence.

Last modified: 2026-04-23 (v1.0 initial — stock-specific data integrity)
Amended 2026-05-04: Rule 11 (D-019 hook portability), Rules 12-15 (D-021 Vietnam-domain)
Amended 2026-05-16: Rule 16 (D-065 I-S1-1 numeric-field discipline; Phase C of Wave-1 research integration; source D-061 § Decision item 6).
