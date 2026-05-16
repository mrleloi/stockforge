# Invariants — StockForge (Stock-Domain Specific)

> Things that must never break. Violations are bugs, not features.
> Stock-specific invariants exist because finance + LLM = real money risk.
>
> **General invariants** (I-1..I-5, I-10..I-13, I-20..I-25, I-30..I-33, I-40..I-42, I-50..I-52)
> live in `invariants.md`. This file holds I-S* invariants — VN stock domain only.
>
> **Established**: 2026-05-05 (S48l HH-G.2 — split out of monolithic invariants.md per portability validation).

## ⭐ Stock-Specific Data Integrity

### I-S1: No LLM Math
LLM never returns a number as natural-language output. All numeric outputs come from deterministic Python functions called via tool use.
Enforcement: Output validator + grep check for "approximately X%" patterns + system prompt constraint.

**Anti-pattern**:
```
LLM output: "Based on my analysis, the company's ROE is approximately 18%."
```

**Correct**:
```
LLM tool call: compute_roe(net_income, equity)
Tool result: 17.83%
LLM output: "ROE is 17.83% (computed from FY2024 financials)."
```

### I-S1-1: Numeric-Field Discipline (sub-rule of I-S1; D-065-RATIFIED)
Numeric-typed schema fields (`int`, `float`, `Decimal`, `numpy.number`, or numeric-parameterized
containers) consumed by LLM call sites must satisfy one of: (1) categorical surrogate via
`Enum`/`Literal`, (2) deterministic-pipeline echo with `EchoValidator`, (3) calibration-database
lookup keyed on (`extractor_version`, `signal_type`), or (4) `Optional[T] = None` surrogate.
LLM-emitted numeric values without satisfaction mode are CRITICAL violations.
Enforcement: `financial-data-protocol.md` Rule 16 (full text) + mypy/ruff/hook (planned).

### I-S2: Point-in-Time Integrity for Fundamentals
Every fundamental query for backtest must filter `WHERE filing_date <= as_of_date`. Live queries can use latest. Look-ahead bias is bug-class.
Enforcement: Repository pattern enforces filter in `get_as_of()` method + linter rule banning `latest_filing` in backtest paths.

### I-S3: Survivorship Bias Awareness
Backtest universe must include de-listed and suspended stocks. Schema includes `delisted_at`, `suspended_at`. Backtests filter by `WHERE first_traded_at <= as_of_date AND (delisted_at IS NULL OR delisted_at > as_of_date)`.
Enforcement: Backtest engine validates universe construction; warns if dataset has no delisted stocks.

### I-S4: Adjusted vs Unadjusted Prices Always Tagged
Every price record has `adjustment_type` field: NONE | DIVIDEND | SPLIT | BOTH. Mixing adjusted and unadjusted is bug.
Enforcement: Schema enum + repository methods enforce consistent type per query.

### I-S5: Source Provider Attribution
Every data point has `source_provider` field (vnstock | fiinpro | tcbs | manual | scraped_<source>). When sources disagree, system shows divergence.
Enforcement: Schema + reconciliation agent flags discrepancies > 1% on key fields.

### I-S6: Currency Always Specified
Every Money value object includes currency (default VND). Cross-currency math requires explicit conversion with as_of_rate.
Enforcement: `Money` value object enforces in constructor.

### I-S7: Confidence ≠ Hit Rate
LLM "confidence" is qualitative. System "confidence" used in alerts must trace to historical hit rate from calibration database.
Enforcement: Confidence claims in alerts must include `n_samples`, `hit_rate`, `lookback_period` metadata.

---

## ⭐ Adversarial Output Invariants

### I-S10: Thesis Must Include Bear Case
Any thesis output (BC-8) must contain a substantive bear case (≥3 distinct points, not boilerplate).
Enforcement: Thesis aggregate validates in `submit()` method + critic agent reviews.

### I-S11: Multi-Perspective Synthesis Required
Synthesis output (multi-perspective adversarial) must include at least: bear, bull, quant, behavior perspectives. Two minimum to count as "synthesis"; four minimum for high-confidence output.
Enforcement: Synthesis aggregate validates in constructor.

### I-S12: Disagreement Surfaced, Not Resolved
When perspectives disagree (bear says SELL, bull says BUY), output shows the disagreement explicitly. Synthesis does NOT vote-average to "HOLD".
Enforcement: Output template + validator rejects collapsed output.

### I-S13: Counter-Narrative for Hot Stocks
When community sentiment > 80% bullish on a ticker, system MUST generate counter-narrative analysis before issuing any positive signal.
Enforcement: Pipeline enforces ordering + critic agent validates.

---

## ⭐ Calibration Invariants

### I-S20: KOL Recommendations Must Be Tracked to Outcome
Every extracted KOL recommendation gets scheduled outcome reviews at 1m, 3m, 6m, 12m. Cron job auto-creates review tasks.
Enforcement: BC-6 service guarantees review tasks created on extraction.

### I-S21: Pump Detection Must Be Backtest-Validated
Pump pattern detection rules must be validated against historical labeled pumps before being used for live alerts. Minimum: precision > 0.5, recall > 0.3 on hold-out set.
Enforcement: CI gate before deploying pump detection rule changes.

### I-S22: Personal Bias Tracking Active
Every user decision (buy/sell/hold) must be logged to BC-9 with reason + market context at time. Used for personal bias detection over time.
Enforcement: All write paths to portfolio require Decision log entry.

---

## ⭐ Stock-Domain Process Integrity

### I-S26: Thesis Post-Mortem Required at 6 Months
Every thesis older than 6 months must have a post-mortem entry. Cron alerts when overdue.
Enforcement: BC-8 monitoring + alert.

---

## ⭐ Stock-Domain Privacy & Safety

### I-S34: Scraping Respects Source ToS
News scrapers respect robots.txt + reasonable rate limits + identify user agent. Facebook/Zalo private content NEVER scraped (only public pages/groups).
Enforcement: Scraper base class enforces + manual review of new scraper additions.

### I-S35: No Output Without Disclaimer
Any thesis/alert/recommendation output to user includes "research aid, not financial advice" framing.
Enforcement: Output template includes disclaimer footer + UI mandatory banner.

---

## ⭐ Stock-Domain Cost Integrity

### I-S43: Data Provider Budget Tracked
Paid data API calls (FiinPro, etc.) tracked per call + per month. Alert at 80% of monthly budget.
Enforcement: API gateway middleware logs + tracks.

---

## ⭐ Stock-Domain Quality Integrity

### I-S53: Backtest Reproducibility
Every backtest result must be reproducible from: code commit hash + data snapshot date + config file. Random seeds fixed.
Enforcement: Backtest framework requires snapshot reference + run metadata.

### I-S54: Calibration Drift Detection
Monthly: compare recent prediction accuracy vs historical baseline. If drop > 20%, flag for review.
Enforcement: Monthly cron + alert + human review trigger.

### I-S55: T+2.5 Cleared Cash Re-Investability (D-022, ratified 2026-05-04)
Cash from a sell trade is re-investable only after T+2.5 trading days clear (VN settlement convention). Backtest re-investment logic must consult `Position.cleared_at`, not `opened_at`.
Enforcement: `PositionRepository.compute_cleared_cash(as_of_date)` is the only path; `available_cash()` shortcut forbidden. **Binding phase**: Phase 2 (intraday + cash management); Phase 1 thin-slice tracks `opened_at` only without cash gating.

### I-S56: Foreign-Room Saturation Alert (D-022)
When `ForeignOwnershipState.saturation_pct >= 0.95` for a Ticker, foreign-flow signal interpretation MUST explicitly mark saturation regime.
Enforcement: `ForeignOwnershipRepository.get_saturated_universe(as_of_date)` returns saturated Tickers; alert pipeline (Phase 2+) emits `SaturationRegimeWarning`. **Binding phase**: Phase 2.

### I-S57: Phiên ATO / ATC Phase Identification (D-022)
Intraday Bars from VN exchanges include Phiên ATO + Phiên ATC auctions; non-continuous price formation. Indicators assuming continuous trading misfire on ATO/ATC bars.
Enforcement: Intraday Bar (Phase 2+) carries `phase ∈ {PRE_OPEN, ATO, CONTINUOUS, ATC, POST_CLOSE}`; BC-8 indicators filter or weight per semantics. **Binding phase**: Phase 2+.

### I-S58: Dividend Ex-Date Adjustment (VN Convention) (D-022)
VN dividends: ex-date = last day stockholder is entitled. Some sources report as next trading day. Mismatched ex-date → 5-15% adjusted-price errors.
Enforcement: `DividendEvent` records `ex_date` + `pay_date` + `ex_date_source_convention ∈ {VN_LAST_ENTITLED, ALT_FIRST_DROP}`; adjustment per Rule 3 always uses VN_LAST_ENTITLED + 1 trading day. **Binding phase**: Phase 1 dataclass scaffold + Phase 2 enforcement.

### I-S59: Listing-Status Sàn Tagging (D-022)
Every Ticker carries `sàn ∈ {HOSE, HNX, UPCoM}` resolved at construction. Mixing Sàn in backtest universe without tier-aware logic is bug.
Enforcement: `Ticker.__post_init__` validates `sàn` non-null; `Bar.sàn` denormalized for query speed. **Binding phase**: Phase 1 scaffold + Phase 2 enforcement.

### I-S60: Lot-Size 100-Share Rule (D-022)
VN equities trade in lots of 100 shares (HOSE/HNX standard); odd-lot routes to Sở giao dịch lô lẻ. Backtests allowing fractional or 1-share orders model unrealistic execution.
Enforcement: `Order.quantity` validation `% 100 == 0` for round-lot; `OddLotOrder` separate type for lô lẻ. Position-sizing rounds DOWN to nearest 100 shares. **Binding phase**: Phase 2.

### I-S61: Ceiling / Floor (Trần / Sàn) Per-Sàn Limits (D-022)
Daily price ceiling/floor differ per Sàn: HOSE ±7%, HNX ±10%, UPCoM ±15%. Trades at ceiling/floor have queue-based fills; continuous-fillability assumptions fail.
Enforcement: `Bar.is_at_ceiling()` + `is_at_floor()` methods; backtest fillability check models partial fill probability per Sàn. **Binding phase**: Phase 1 method scaffold + Phase 2 fillability modeling.

### I-S62: Trading-Suspension Event Handling (D-022)
VN exchanges suspend Tickers (regulatory/compliance; minutes to permanent). Backtests must skip or mark-to-last-trade; live thesis output surfaces suspension status.
Enforcement: `SuspensionEvent(ticker, started_at, ended_at_or_null, reason)`; Bar query layer skips suspension windows for return calc. **Binding phase**: Phase 2+.

### I-S63: Corporate-Action Ex-Rights Tagging (D-022)
Beyond dividends + splits, VN corporate actions include rights issues (quyền mua), bonus shares (cổ phiếu thưởng), capital adjustments. Ex-rights date carries adjustment math distinct from ex-dividend.
Enforcement: `CorporateAction` aggregate covers `{DIVIDEND, SPLIT, RIGHTS_ISSUE, BONUS_SHARES, CAPITAL_ADJUSTMENT}`; adjustment-type extended `{NONE, DIVIDEND, SPLIT, BOTH, RIGHTS, BONUS, CAPITAL}`. **Binding phase**: Phase 1 enum scaffold + Phase 2 feed integration.

### I-S64: vnstock vs TCBS Reconciliation Tolerance Sàn-Tiered (D-022)
Per Rule 14, tolerance is Sàn-tiered: HOSE ±1%, HNX ±2%, UPCoM ±5%. Single tolerance produces false-flag noise on UPCoM and missed-divergence on HOSE.
Enforcement: `ReconciliationService.tolerance_for(bar)` returns Sàn-tier tolerance; `RECONCILIATION_TOLERANCE_PCT` constant DEPRECATED. **Binding phase**: Phase 1 (S28 ReconciliationService consumes from inception).

### I-S65: Source-Fallback Chain Order (D-022)
Fallback chain deterministic: vnstock → TCBS → Vietstock public → Manual. Manual override documents `override_reason`. KOL-extracted numbers NEVER appear in this chain (I-S1).
Enforcement: `BarProvider.fetch_with_fallback(ticker, date_range)` consults chain in order; emits `SourceFallbackEvent` when non-primary source returned. **Binding phase**: Phase 1 (S28 vnstock primary + TCBS backup).

---

## Severity Levels (Stock-Specific)

**CRITICAL** (I-S1, I-S2) — agent must stop immediately, escalate to human.

**HIGH** (most I-S* invariants except S20-S22) — blocks commit/merge/deploy, fix before continuing.

**MEDIUM** (I-S20-S22, I-S43, I-S54) — warning, fix in current session or flag for next.

(General severity bands for I-1..I-52 live in `invariants.md`.)

---

## Cross-Reference

For general invariants (Data/Code/Process/Privacy/Cost/Quality applicable to any project), see `invariants.md` in this directory.

For violation handling protocol (when found / post-incident steps), see `invariants.md` § Violations Handling.

For amendment protocol (rationale + approval + version bump), see `invariants.md` § Amendments — same procedure applies to I-S* invariants.

---

Last modified: 2026-05-05 (S48l HH-G.2 — split out of monolithic invariants.md per portability validation; content unchanged from invariants.md v1.0 2026-04-23 + D-022 ratification 2026-05-04).
