# Invariants — StockForge

> Things that must never break. Violations are bugs, not features.
> Stock-specific invariants are marked with ⭐ — they exist because finance + LLM = real money risk.

## Data Integrity

### I-1: Every claim has source_url
No claim may be stored, returned, or referenced without `source_url` metadata.
Enforcement: Schema constraint + DR2 drift signal + verifier agent.

### I-2: Every extraction has timestamp
`extracted_at` timestamp required on all extracted data (claims, recommendations, sentiment scores).
Enforcement: Schema NOT NULL constraint.

### I-3: Hallucination is a bug
If LLM generates a claim not grounded in provided evidence, that's a defect.
Enforcement: VBW Protocol + verifier agent + eval set regression.

### I-4: Public output has verified data only
Anything surfaced via dashboard or alerts shows `verified=true` data only. Pending verification = "unverified" badge in UI.
Enforcement: View-level filter + application-level check.

### I-5: Data freshness visible
All surfaced data shows "as of [date]" with staleness color coding (green: <24h, yellow: <7d, red: >7d).
Enforcement: UI requirement + mandatory timestamp propagation.

---

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

## Code Integrity

### I-10: Domain layer has ZERO framework dependency
`packages/domain/**` may not import FastAPI, Pydantic, ORM libraries, or any framework.
Only pure Python: stdlib, dataclasses, enum, typing. Internal domain types only.
Enforcement: DR6 drift signal + import-linter rule.

### I-11: Cross-BC communication via contracts only
Bounded contexts never directly import from each other's domain/application packages.
All cross-BC communication goes through `packages/contracts/`.
Enforcement: DR8 drift signal + import-linter rule.

### I-12: No `Any` type in domain package
`packages/domain/**` cannot contain `: Any` or `cast(Any, ...)`.
Enforcement: mypy --strict + DR6 drift signal.

### I-13: No `print()` in production code
Use structured logger (`structlog`). `print()` allowed only in tests, dev tooling, CLI.
Enforcement: ruff rule + DR-minor drift signal.

---

## Process Integrity

### I-20: Spec before code
No production code written without corresponding spec in `specs/tier2-feature/` or `specs/tier3-task/`.
Enforcement: Code review checklist + PR template.

### I-21: VBW Protocol mandatory before spec/test/code
Agent must verify source before writing. Reading from memory/convention is forbidden.
Enforcement: VBW checkpoints in `vbw-protocol.md` + pre-commit hook (planned).

### I-22: Session handoff always written
Every session ends with written handoff to next session.
Enforcement: Session-end protocol + /session-end command.

### I-23: Constitution never modified by agent
Files in `agent-workspace/constitution/` require explicit human edit.
Enforcement: CLAUDE.md hard rule + human review gate.

### I-24: Eval set regression blocks merge
If eval set performance drops, PR cannot merge without human override.
Enforcement: CI gate + Tier 3 human approval.

### I-25: Deterministic gates must pass
mypy --strict, pytest, ruff must pass before commit.
Enforcement: Pre-commit hook + CI pipeline.

### I-S26: Thesis Post-Mortem Required at 6 Months
Every thesis older than 6 months must have a post-mortem entry. Cron alerts when overdue.
Enforcement: BC-8 monitoring + alert.

---

## Privacy & Safety

### I-30: User portfolio is private
Portfolio data never leaves local instance unless user explicitly enables sharing (Phase 4+ feature, off by default).
Enforcement: Schema default + application-level ACL.

### I-31: Raw source material immutable
`obsidian-vault/raw/` never modified by agent. All agent writes go to `wiki/`.
Enforcement: CLAUDE.md hard rule + file system permissions.

### I-32: No PII in logs
Personal information not logged outside designated privacy-controlled paths.
Enforcement: Logger filter + code review.

### I-33: Destructive operations require explicit approval
DELETE FROM, DROP TABLE, `rm -rf`, force push, branch deletion require user confirmation in same session.
Enforcement: CLAUDE.md hard rule + subagent design.

### I-S34: Scraping Respects Source ToS
News scrapers respect robots.txt + reasonable rate limits + identify user agent. Facebook/Zalo private content NEVER scraped (only public pages/groups).
Enforcement: Scraper base class enforces + manual review of new scraper additions.

### I-S35: No Output Without Disclaimer
Any thesis/alert/recommendation output to user includes "research aid, not financial advice" framing.
Enforcement: Output template includes disclaimer footer + UI mandatory banner.

---

## Cost Integrity

### I-40: Budget cap per thesis validation
No single thesis validation may exceed $5 in LLM costs without escalation.
Enforcement: Budget-aware harness + budget-check command.

### I-41: Budget cap per session
No session may exceed $25 in LLM costs without human approval.
Enforcement: Session-level budget check + escalation.

### I-42: Daily LLM budget cap
Total LLM spend per day capped at configurable amount (default: $10/day for personal use).
Enforcement: External rate limiter + alert.

### I-S43: Data Provider Budget Tracked
Paid data API calls (FiinPro, etc.) tracked per call + per month. Alert at 80% of monthly budget.
Enforcement: API gateway middleware logs + tracks.

---

## Quality Integrity

### I-50: Citation before synthesis
Synthesis agents cannot produce output until claim verifier has confirmed citations.
Enforcement: Pipeline ordering + schema validation.

### I-51: Adversarial review before alerts
No alert fires to user without adversarial critic review (in spec, even if simple rules-based).
Enforcement: Status state machine + Tier 2 probabilistic gate.

### I-52: Multi-criteria not scalar
System never produces single "stock score". Always multi-dimensional with trade-off surface.
Enforcement: Output schema + spec template + UI design.

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

## Violations Handling

### Severity Levels

**CRITICAL** (I-10, I-11, I-23, I-30, I-33, I-S1, I-S2) — agent must stop immediately, escalate to human.

**HIGH** (most invariants, all stock-specific I-S except S20-S22) — blocks commit/merge/deploy, fix before continuing.

**MEDIUM** (I-S20-S22, I-S43, I-S54) — warning, fix in current session or flag for next.

**LOW** — log, address at phase boundary.

### When Found

1. Stop current work
2. Log violation in `agent-workspace/memory/drift-logs/`
3. Assess: can fix now, or escalate?
4. If escalate → output escalation message to user
5. If fix → address and re-verify
6. Consider: does this need new drift signal or constitutional amendment?

### Post-Incident

After HIGH or CRITICAL violation:
1. Root cause analysis
2. New rule added to `agent-notes.md`
3. Drift signal added if detectable
4. Related skill or command updated

---

## Amendments

Invariants can be added, but rarely removed. To modify:
1. Document rationale (link to specific incidents)
2. Explicit human approval
3. Version bump on this file
4. Migration plan if removal affects existing enforcement

Stock-specific invariants (I-S*) have especially high bar to remove — they exist because real money depends on them.

Last modified: 2026-04-23 (v1.0 initial — adapted from IdeaForge for stock domain)
