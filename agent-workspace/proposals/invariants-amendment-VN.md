---
status: ACCEPTED (ratified S43c via D-022; frontmatter sync S43f)
proposed_at: 2026-04-30
proposed_by: Claude Opus 4.7 (S26 IMPL — Phase 1 Track B; master-plan 004 § S26 deliverable #2)
source_evidence:
  - PROJECT_CHARTER.md § First Sub-Scope (HOSE/HNX/UPCoM, position 5-15%, hold 1m+)
  - agent-workspace/ubiquitous-language/glossary.md v1.0 (S25; 42 VN terms)
  - agent-workspace/proposals/financial-data-protocol-amendment-VN.md (S26 sibling — Rules 12-15; these I-S* enforce those Rules)
  - agent-workspace/constitution/invariants.md (existing I-S* baseline; last used I-S54; this amendment ships I-S55-I-S65)
  - specs/tier2-feature/000-phase-1-thin-slice-VHM.md § A.3 BR-1..5 (informs which I-S* are Phase 1 binding)
target_constitution_path: agent-workspace/constitution/invariants.md
target_section: Append to ⭐ Stock-Specific Data Integrity (after I-S54 Calibration Drift Detection)
move_when: user explicit approve; insertion point = before "## Code Integrity"
relates_to:
  - financial-data-protocol-amendment-VN.md (S26 sibling — Rules 12-15 enforced via these I-S55-I-S65)
phase_binding_legend: "Phase 1 = enforced now in code via dataclass __post_init__ or Protocol; Phase 2+ = scaffold + binding deferred until intraday/full-VN30/cash-mgmt land"
---

# Invariants Amendment — Vietnam-Domain I-S55 through I-S65

> **Status**: PROPOSAL pending user approve. 11 NEW stock-specific invariants enforcing financial-data-protocol-amendment-VN.md Rules 12-15. Each entry: ID + name + binding statement + enforcement + binding_phase.
>
> **Why 11 not 10**: master-plan 004 § S26 enumerated 11 distinct concerns (T+2.5 / foreign-room / ATO-ATC / dividend ex-date / listing-status / lot-size / ceiling-floor / suspension / ex-rights / reconciliation-tolerance / fallback-chain) — codified faithfully even though master-plan abstract count said "10". Better to ship 11 honestly than cherry-pick.

## Append to `invariants.md` § ⭐ Stock-Specific Data Integrity (after I-S54)

---

### I-S55: T+2.5 Cleared Cash Re-Investability

Cash from a sell trade is re-investable only after T+2.5 trading days clear (VN settlement convention). Backtest re-investment logic must consult `Position.cleared_at`, not `opened_at`.

**Enforcement**: `PositionRepository.compute_cleared_cash(as_of_date)` is the only path. `available_cash()` shortcut method forbidden. **Binding phase**: Phase 2 (when intraday + cash management land); Phase 1 thin-slice tracks `opened_at` only without cash gating per spec 000 § BR-5.

### I-S56: Foreign-Room Saturation Alert

When `ForeignOwnershipState.saturation_pct >= 0.95` for a Ticker, foreign-flow signal interpretation MUST explicitly mark saturation regime. Strategies keying on "foreign accumulation" silently fail on saturated stocks.

**Enforcement**: `ForeignOwnershipRepository.get_saturated_universe(as_of_date)` returns Tickers with saturation ≥0.95. Alert pipeline (Phase 2+) emits `SaturationRegimeWarning` event before any foreign-flow-keyed signal is rendered. **Binding phase**: Phase 2 (full VN30 ingestion seeds ForeignOwnership data).

### I-S57: Phiên ATO / ATC Phase Identification

Intraday Bars from VN exchanges include Phiên ATO (At-The-Open auction; opening price discovery) + Phiên ATC (At-The-Close auction; closing price discovery). These auction-phase trades have non-continuous price formation; technical indicators that assume continuous trading misfire on ATO/ATC bars.

**Enforcement**: Intraday Bar entity (Phase 2+) carries `phase ∈ {PRE_OPEN, ATO, CONTINUOUS, ATC, POST_CLOSE}`. Indicator calculations in BC-8 must filter or weight ATO/ATC bars per indicator semantics. **Binding phase**: Phase 2+ (Phase 1 thin-slice = EOD only; no intraday).

### I-S58: Dividend Ex-Date Adjustment (VN Convention)

VN dividends declare ex-date as last day stockholder is entitled to dividend (NOT first day price drops). Some sources report ex-date as next trading day. Mismatched ex-date → adjusted-price errors of 5-15% on dividend day.

**Enforcement**: `DividendEvent` records `ex_date` (last-entitled day) + `pay_date` (cash distribution day) + `ex_date_source_convention ∈ {VN_LAST_ENTITLED, ALT_FIRST_DROP}`. Adjustment logic per Rule 3 always uses VN_LAST_ENTITLED + 1 trading day as the adjustment-effective date. Reconciliation between sources MUST normalize convention before comparison. **Binding phase**: Phase 1 (dataclass scaffold) + Phase 2 enforcement (when full corporate-actions feed lands).

### I-S59: Listing-Status Sàn Tagging

Every Ticker carries `sàn ∈ {HOSE, HNX, UPCoM}` resolved at construction. Mixing Sàn in backtest universe without tier-aware logic is bug.

**Enforcement**: `Ticker.__post_init__` validates `sàn` non-null. `Bar.sàn` denormalized from Ticker for query speed. Universe construction (per Rule 2) tags every row with `sàn`. CI warning (Phase 2+) when backtest dataset mixes Sàn without explicit tier handling. **Binding phase**: Phase 1 (scaffold + Bar field); Phase 2 enforcement.

### I-S60: Lot-Size 100-Share Rule

VN equities trade in lots of 100 shares (HOSE/HNX standard); odd-lot trades route to Sở giao dịch lô lẻ (separate market with different price discovery). Backtests that allow fractional or 1-share orders silently model unrealistic execution.

**Enforcement**: `Order.quantity` validation: `quantity % 100 == 0` for round-lot path; `OddLotOrder` separate type for the lô lẻ path. Position-sizing (per Rule 11 risk-rule) rounds DOWN to nearest 100 shares. **Binding phase**: Phase 2 (when order management lands); Phase 1 Position quantity is informational only.

### I-S61: Ceiling / Floor (Trần / Sàn) Per-Sàn Limits

Daily price ceiling/floor (Trần/Sàn glossary terms) differ per Sàn: HOSE ±7%, HNX ±10%, UPCoM ±15% from prior reference price. Trades at ceiling/floor have non-continuous pricing (queue-based fills); backtest assumptions of continuous fillability fail.

**Enforcement**: `Bar.is_at_ceiling()` + `is_at_floor()` methods (computed: `close == reference_price * (1 + sàn_limit_pct)` within rounding tolerance). Backtest fillability check (Phase 2+): if order price = ceiling/floor, model partial fill probability per Sàn. **Binding phase**: Phase 1 (Bar method scaffold) + Phase 2 fillability modeling.

### I-S62: Trading-Suspension Event Handling

VN exchanges suspend trading on individual Tickers (regulatory + compliance reasons; minutes to days to permanent). Backtests on suspended Tickers must skip or mark-to-last-trade (NOT extrapolate). Live thesis output on suspended stock must surface suspension status.

**Enforcement**: `SuspensionEvent(ticker, started_at, ended_at_or_null, reason)` records. Bar query layer skips suspension windows for return calc; thesis output includes `suspension_status` field. **Binding phase**: Phase 2+ (suspension feed not in Phase 1 thin-slice).

### I-S63: Corporate-Action Ex-Rights Tagging

Beyond dividends + splits, VN corporate actions include rights issues (quyền mua), bonus shares (cổ phiếu thưởng), and capital adjustments. Ex-rights date carries adjustment math distinct from ex-dividend.

**Enforcement**: `CorporateAction` aggregate covers `{DIVIDEND, SPLIT, RIGHTS_ISSUE, BONUS_SHARES, CAPITAL_ADJUSTMENT}`. Adjustment-type tagging per Rule 3 extended: `adjustment_type ∈ {NONE, DIVIDEND, SPLIT, BOTH, RIGHTS, BONUS, CAPITAL}`. **Binding phase**: Phase 1 enum scaffold + Phase 2 corporate-actions feed integration.

### I-S64: vnstock vs TCBS Reconciliation Tolerance Sàn-Tiered

Per Rule 14, reconciliation tolerance is Sàn-tiered: HOSE ±1%, HNX ±2%, UPCoM ±5%. Single tolerance across Sàn produces false-flag noise on UPCoM and missed-divergence on HOSE.

**Enforcement**: `ReconciliationService.tolerance_for(bar)` returns Sàn-tier tolerance; existing `RECONCILIATION_TOLERANCE_PCT` constant DEPRECATED (kept for backward compat, raises DeprecationWarning). **Binding phase**: Phase 1 (S28 ReconciliationService implementation must consume `tolerance_for(bar)` from inception).

### I-S65: Source-Fallback Chain Order

When primary data source is unavailable, fallback chain is deterministic: vnstock → TCBS → Vietstock public → Manual. Manual override must document `override_reason` (per Rule 4). KOL-extracted numbers NEVER appear in this chain (I-S1 — no LLM math).

**Enforcement**: `BarProvider.fetch_with_fallback(ticker, date_range)` consults chain in order; emits `SourceFallbackEvent` when non-primary source returned. Audit log records every fallback for Rule 10 reproducibility. **Binding phase**: Phase 1 (S28 vnstock primary + TCBS backup; Vietstock + Manual deferred Phase 2).

---

## Coverage Map: Rules 12-15 ↔ Invariants I-S55-I-S65

| Rule | Enforced by |
|---|---|
| Rule 12 (T+2.5 settlement) | I-S55 cleared-cash re-investability |
| Rule 13 (Room ngoại) | I-S56 foreign-room saturation alert |
| Rule 14 (Sàn HOSE/HNX/UPCoM tiering) | I-S59 sàn tagging + I-S64 sàn-tier reconciliation |
| Rule 15 (FX VND-USD point-in-time) | (covered by existing Rule 5 + I-S6; no new I-S* needed) |

I-S57 (ATO/ATC), I-S58 (dividend ex-date), I-S60 (lot-size), I-S61 (ceiling/floor), I-S62 (suspension), I-S63 (ex-rights) anchor Phase 2 work on Bar/Order/CorporateAction types — codified now so Phase 2 enforcement slots into existing scaffolds.

## End of amendment
