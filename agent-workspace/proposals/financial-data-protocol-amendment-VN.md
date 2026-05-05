---
status: ACCEPTED (ratified S43c via D-021; frontmatter sync S43f)
proposed_at: 2026-04-30
proposed_by: Claude Opus 4.7 (S26 IMPL — Phase 1 Track B; master-plan 004 § S26 deliverable #1)
source_evidence:
  - PROJECT_CHARTER.md § First Sub-Scope (HOSE/HNX/UPCoM, vốn hóa 2,000-50,000 tỷ VND, position sizing 5-15%, holding 1m-24m)
  - agent-workspace/ubiquitous-language/glossary.md v1.0 (S25 deliverable; 42 VN terms incl. T+2.5, Room ngoại, Sàn HOSE/HNX/UPCoM, Trần, Sàn, Phiên ATO/ATC, Tỷ giá USD/VND)
  - specs/tier2-feature/000-phase-1-thin-slice-VHM.md § A.3 BR-3 + BR-5 (T+2.5 informational; VND only Phase 1)
  - agent-workspace/constitution/financial-data-protocol.md Rules 1-10 (existing baseline; this amendment APPENDS Rules 12-15 — Rule 11 reserved for S16 amendment Hook Portability)
  - docs/DAY_1_CHECKLIST.md § A.4 + § B.1 (financial-data-protocol customization step)
target_constitution_path: agent-workspace/constitution/financial-data-protocol.md
target_section: NEW § "Vietnam-Domain Rules 12-15"
move_when: user explicit approve; insertion point = after "## Rule 10: Backtest Reproducibility" and before "## Quick Reference Table"
relates_to:
  - financial-data-protocol-amendment.md (S16 — Rule 11 Hook Portability; ORTHOGONAL to this amendment, NOT a fold)
  - invariants-amendment-VN.md (S26 sibling — I-S55-I-S65 invariants enforce these Rules)
---

# Financial Data Protocol Amendment — Vietnam-Domain Rules 12-15

> **Status**: PROPOSAL pending user approve. Codifies VN-specific data integrity rules that emerged from glossary v1.0 (S25) and Phase 1 thin-slice spec (S25). Each Rule names existing glossary terms by exact spelling and references invariants-amendment-VN.md for enforcement.
>
> **Why these Rules and not others**: glossary v1.0 surfaced 8 critical VN-domain terms (T+2.5, Room ngoại, Đội lái, Mua chủ động, Bán chủ động, Sàn HOSE/HNX/UPCoM, Phiên ATO/ATC, Tỷ giá USD/VND). Rules 12-15 cover the 4 that are data-integrity-binding for Phase 1+ (settlement timing, foreign-cap detection, sàn-tier data quality, FX point-in-time). Đội lái + Mua/Bán chủ động + ATO/ATC are Phase 2+ (intraday + Tier 4 work) — deferred.

## Append to `financial-data-protocol.md` (NEW section, after Rule 10)

---

## Rule 12 — T+2.5 Settlement Timing Awareness

### The Problem

VN equities settle T+2.5 (trade date + 2.5 trading days). A buy on Monday clears Wednesday afternoon; cash from a Monday sell is re-investable Wednesday afternoon. Backtests that ignore T+2.5 over-count compoundable cash by 2-3 trading days, producing false-positive performance especially for high-turnover strategies.

### The Rule

- Every `Position` entity tracks `opened_at` = trade-match date (NOT cleared-cash date).
- Every cash-flow record carries `cleared_at = opened_at + T+2.5 trading days` (computed via VN trading calendar, not naive +3 calendar days).
- Backtest re-investment available cash queries: `WHERE cleared_at <= action_date`.
- Live cash queries may use `cleared_at <= today` for pre-trade checks; cash gating in `apps/cli/order_*.py` (Phase 2+) MUST consult cleared cash, not trade-match cash.
- Phase 1 thin-slice exception: `Position.opened_at` is required, but T+2.5 cash gating is NOT enforced (deferred to Phase 2 when intraday/order-management lands per spec 000 § BR-5).

### The Enforcement

`PositionRepository.compute_cleared_cash(as_of_date)` is the only path for re-investable cash. No `available_cash()` method bypasses T+2.5. CI gate (Phase 2+) adds property test: random portfolio + random sell timing, assert `cleared_at - opened_at` always ≥2.5 trading days per VN calendar.

---

## Rule 13 — Room Ngoại (Foreign-Ownership Cap) Detection

### The Problem

Foreign investors face a hard ceiling on per-stock ownership in VN equities. The cap is sector-dependent: banking ≤30%, real estate ≤49%, most industrial ≤49% with stock-specific overrides. When a stock saturates Room ngoại, foreign buy-pressure cannot accumulate further — the stock is effectively closed to foreign-flow signal until domestic holders sell to foreigners. Strategies that key on "foreign accumulation" silently fail on saturated stocks. Strategies that pump on "Room ngoại near full" (early signal of further foreign demand) miss the regime.

### The Rule

- Every `Bar` (BC-1) carries `foreign_buy_volume` + `foreign_sell_volume` (existing schema per architecture.md BC-1).
- NEW per-Ticker daily snapshot record `ForeignOwnershipState`: `(ticker, date, foreign_owned_shares, foreign_cap_shares, saturation_pct, source_provider, ingested_at, as_of)`.
- `saturation_pct = foreign_owned_shares / foreign_cap_shares`. When `saturation_pct >= 0.95`, the stock is in saturation regime — foreign-flow analysis must explicitly mark this.
- Source provenance: HOSE listed-stocks portal + vnstock `room_ngoai()` endpoint + TCBS reconciliation per Rule 4. Rule 4 reconciliation tolerance = 1% of cap (NOT 1% of saturation_pct — different denominators).
- Backtest queries on foreign accumulation MUST filter `WHERE saturation_pct < 0.95 OR explicit_saturation_strategy = TRUE`.

### The Enforcement

`ForeignOwnershipRepository` Protocol: `get_state_as_of(ticker, as_of_date)` + `get_saturated_universe(as_of_date, threshold=0.95)`. Bar+ForeignOwnership join in `MarketDataReadModel` denormalized view. Phase 1 thin-slice on VHM does NOT seed ForeignOwnership data (Phase 2 deliverable when full VN30 ingestion lands); Bar.foreign_buy / foreign_sell fields are seeded but Saturation analysis deferred.

---

## Rule 14 — Sàn HOSE / HNX / UPCoM Data-Quality Tiering

### The Problem

VN listed equities split across 3 exchanges (Sàn): HOSE (HCMC; tier-1 large caps; strictest disclosure), HNX (Hanoi; tier-2; mid-caps), UPCoM (over-the-counter board; tier-3; micro-caps + pre-listing transitional). Data quality, filing cadence, and cross-source reconciliation tolerance differ by Sàn. Treating UPCoM Bars with the same trust as HOSE Bars produces false-positive backtest signals on noisy UPCoM data.

### The Rule

- Every `Ticker` value object infers Sàn at construction (regex on listing-status feed: 3-letter alpha → HOSE; 3-letter alpha + HNX flag → HNX; UPCoM has explicit ticker namespace).
- Every `Bar` carries `sàn` field (NEW; values: HOSE | HNX | UPCoM). Field is denormalized from Ticker for query performance (Rule 4 reconciliation runs per-Sàn).
- Reconciliation tolerance per Rule 4 is Sàn-tiered:
  - HOSE: ±1% (existing tolerance preserved)
  - HNX: ±2% (mid-cap, slightly noisier filings)
  - UPCoM: ±5% (micro-cap, frequent stale data; Sàn-tier downgrade flag mandatory)
- Phase 1 thin-slice scope locks to HOSE only (VHM is HOSE; spec 000 § A.5 Out-of-Scope item 4).
- Charter "First Sub-Scope" mid-cap band (vốn hóa 2,000-50,000 tỷ VND) implicitly excludes most UPCoM stocks; this Rule codifies the data-quality reason.

### The Enforcement

`Bar.__post_init__` validates `sàn ∈ {HOSE, HNX, UPCoM}`. `ReconciliationService.tolerance_for(bar)` returns Sàn-tier tolerance. Backtest universe construction (per Rule 2) MUST tag `Sàn` per row; CI gate (Phase 2+) warns if backtest dataset mixes Sàn without explicit tier-aware logic.

---

## Rule 15 — FX VND-USD Point-in-Time Discipline

### The Problem

VN equities are priced VND. Some thesis comparisons reference USD-denominated peers (e.g., regional comparable PE). FX rates VND/USD drift 1-3% per quarter and 5-8% per year. A naive "as_of FX rate" lookup using today's rate to convert a 2024-Q1 metric distorts comparable analysis silently. Rule 5 already mandates explicit `Money.convert(target_currency, as_of_rate)`; Rule 15 codifies VN specifics and the FX rate source-attribution discipline.

### The Rule

- FX rates VND/USD (and any other pair) stored as `FxRate(currency_pair, as_of_date, rate, source_provider, ingested_at)` records per Rule 1 point-in-time integrity.
- `source_provider` for FX MUST be one of: `SBV` (Tỷ giá trung tâm State Bank of Vietnam — official reference rate) | `VCB` (Vietcombank cash quote) | `VNSTOCK` (vnstock historical FX endpoint, derived from interbank). NEVER LLM-extracted (I-S1).
- `Money.convert(target_currency, as_of_date)` resolves FX via `FxRateRepository.get_as_of(currency_pair, as_of_date)` — NOT current-day rate. If as_of_date pre-dates earliest stored FX rate, raise `FxRateNotAvailableError` (do NOT fallback to nearest); this preserves Rule 1 integrity at the FX layer.
- Backtest cross-currency: every conversion call records `(amount_native, amount_target, fx_rate_used, fx_as_of_date, fx_source)` for audit reproducibility per Rule 10.
- Phase 1 thin-slice: VND only (spec 000 § BR-3); FX subsystem stubbed but unused.

### The Enforcement

`Money.convert()` raises if FX rate unavailable for as_of_date. `FxRateRepository.get_as_of()` enforces point-in-time. CI test (Phase 2+): backtest with deliberate cross-currency comparison runs twice with same `(commit, snapshot, config, seed)` and produces identical converted values per Rule 10 reproducibility.

---

## Why Rules 12-15 Are Phase-1-Compatible Even Though Phase 1 Doesn't Enforce Them

Rules 12-15 are codified now to anchor S27-S28 entity design (Bar.sàn field, Position.opened_at semantics, FX placeholder structure) so Phase 2 enforcement layers slot into existing types without retrofitting. This matches Charter "When in doubt, simplify" + "Ship thin slices" — types are designed once, enforcement layers ship phase-by-phase.

## End of amendment
