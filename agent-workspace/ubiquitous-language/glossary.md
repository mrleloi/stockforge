# Ubiquitous Language — StockForge

> Single source of truth for domain terms. Vietnamese stock market research domain.
> Code names + spec names MUST match this file exactly. Synonyms appear only for recognition, never for use.
> Drift → log in `drift-log.md` and fix via codemod.

**Version**: v1.0 — S25 PLAN seed (2026-04-30; sandwich-architect subagent dispatch)
**Source corpus**: PROJECT_CHARTER.md, four-tier-signal-architecture.md, 9 BCs (architecture.md), VN financial public sources.

---

## Generic Finance Terms (BC-agnostic)

### Ticker
**Definition**: Listing symbol on HOSE/HNX/UPCoM (e.g., `VHM`, `HPG`); always uppercase, no exchange suffix.
**Source**: HOSE listed-stocks portal (https://www.hsx.vn/) + glossary v0 carry-over | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Thesis
**Definition**: Time-bounded investment hypothesis on a Ticker; structured bull case + mandatory bear case + catalysts + confidence (calibrated). Framed as "exploration", never "buy/sell".
**Source**: PROJECT_CHARTER.md § Honest Boundaries + I-S10 | **As-of**: 2026-04-30 | **BC**: BC-8 | **Phase**: 1

### Bear Case
**Definition**: Mandatory adversarial counterpart of every thesis; ≥3 distinct risk factors with specific evidence + source URL + as-of (I-S10). System refuses to render thesis without substantive bear case.
**Source**: PROJECT_CHARTER.md Principle 3 + invariants.md I-S10 | **As-of**: 2026-04-30 | **BC**: BC-8 | **Phase**: 1

### Bull Case
**Definition**: Positive-thesis side of a Thesis; structured catalysts + opportunity framing; equal rigor with Bear Case.
**Source**: spec 001-validate-investment-thesis.md § A.4 | **As-of**: 2026-04-30 | **BC**: BC-8 | **Phase**: 1

### As-Of Date
**Definition**: Business date a piece of data represents (NOT the ingestion date). Backtest queries MUST filter `WHERE filing_date <= as_of_date` (point-in-time integrity, I-S2).
**Source**: financial-data-protocol.md Rule 1 + I-S2 | **As-of**: 2026-04-30 | **BC**: BC-1, BC-2 | **Phase**: 1

### Calibration
**Definition**: Empirical hit rate of a signal source (KOL, pattern, agent perspective) over a rolling window. Confidence claims MUST trace to a calibration number — not LLM "feeling certain" (I-S7).
**Source**: PROJECT_CHARTER.md Principle 8 + I-S7 | **As-of**: 2026-04-30 | **BC**: BC-6, BC-8 | **Phase**: 2+

### Confidence Score
**Definition**: Categorical confidence label {HIGH | MEDIUM | LOW} attached to thesis output; derived from calibration hit rate, NOT LLM self-assessment.
**Source**: spec 001-validate-investment-thesis.md § A.4 + I-S7 | **As-of**: 2026-04-30 | **BC**: BC-8 | **Phase**: 2+

### Fair Value Range
**Definition**: Code-computed valuation band (low/mid/high VND) replacing forbidden "price target". Always 3 numbers + as-of + source. Charter Boundaries: "we don't predict price".
**Source**: PROJECT_CHARTER.md § Honest Boundaries + glossary forbidden-terms | **As-of**: 2026-04-30 | **BC**: BC-2, BC-8 | **Phase**: 2+

### Drawdown
**Definition**: Peak-to-trough percentage decline of a Position over a window; computed by code, never narrated.
**Source**: PROJECT_CHARTER.md § Personal-risk-profile context | **As-of**: 2026-04-30 | **BC**: BC-9 | **Phase**: 1

### Position Sizing
**Definition**: Percentage of portfolio allocated to one Position; deterministic via RiskRule (Charter Principle 10); 5-15% per stock per Charter § First Sub-Scope.
**Source**: PROJECT_CHARTER.md § First Sub-Scope + Principle 10 | **As-of**: 2026-04-30 | **BC**: BC-9 | **Phase**: 1

### Stop-Loss
**Definition**: Pre-committed exit price at fixed percentage below cost basis; code-enforced; LLM cannot override.
**Source**: PROJECT_CHARTER.md Principle 10 | **As-of**: 2026-04-30 | **BC**: BC-9 | **Phase**: 1

### P/E (Price-to-Earnings)
**Definition**: Current Price ÷ trailing-12M EPS; computed deterministically in `packages/domain/fundamental/services/`. If EPS ≤ 0 → store None with reason (I-S3).
**Source**: spec four-tier-signal-architecture.md § B.1 | **As-of**: 2026-04-30 | **BC**: BC-2 | **Phase**: 2+

### P/B (Price-to-Book)
**Definition**: Current Price ÷ Book Value Per Share; deterministic computation; VND only.
**Source**: spec four-tier-signal-architecture.md § B.1 | **As-of**: 2026-04-30 | **BC**: BC-2 | **Phase**: 2+

### ROE (Return on Equity)
**Definition**: Net Income ÷ Average Shareholders' Equity (trailing 12M); deterministic.
**Source**: vnstock fundamentals docs (https://github.com/thinh-vu/vnstock) | **As-of**: 2026-04-30 | **BC**: BC-2 | **Phase**: 2+

### EPS (Earnings Per Share)
**Definition**: Net Income attributable to common shareholders ÷ weighted-avg shares outstanding.
**Source**: Vietstock financial reports template | **As-of**: 2026-04-30 | **BC**: BC-2 | **Phase**: 2+

---

## Vietnam-Specific Trading Mechanics

### T+2.5 (Settlement Timing)
**Definition**: VN equity settlement convention: trade matched day T → cash/shares cleared at ~14:30 day T+2 (effectively "2.5 trading days"). Affects available-cash for re-entry trades.
**Source**: VSD circulars + HOSE settlement guide | **As-of**: 2026-04-30 | **BC**: BC-9 | **Phase**: 1

### Room ngoại (Foreign-Ownership Cap)
**Definition**: Per-ticker cap on aggregate foreign ownership (typically 49% non-banking, 30% banking). Saturation event → forced sell pressure from foreign side; signal.
**Source**: SBV Circular 51/2021 + HOSE foreign-room dashboard | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Đội lái (Pump-Operator Crew)
**Definition**: Coordinated price-manipulation collective; orchestrates pump-distribution-dump cycles via Tier 3 (KOL push) + Tier 4 (forum coordination). Detection via cross-tier divergence (T3+T4 hot, T1+T2 silent).
**Source**: PROJECT_CHARTER.md § The Core Insight + spec 003-crowd-sentiment-pump-detection.md | **As-of**: 2026-04-30 | **BC**: BC-7 | **Phase**: 2+

### Mua chủ động (Active Buy)
**Definition**: Tape-reading classifier — order matched at ASK price (buyer crossed spread). Active-buy vs active-sell volume = net order-flow signal (Tier 1).
**Source**: TCBS Open API tape data + HOSE microstructure docs | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 2+

### Bán chủ động (Active Sell)
**Definition**: Order matched at BID (seller crossed spread). Companion to "Mua chủ động"; net (buy − sell) = order-flow imbalance.
**Source**: TCBS Open API + tape conventions | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 2+

### Sàn HOSE
**Definition**: Ho Chi Minh Stock Exchange — top tier; large-caps; ceiling/floor ±7%; lot size 100; ATO/ATC phases active.
**Source**: HOSE official rulebook (https://www.hsx.vn/) | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Sàn HNX
**Definition**: Hanoi Stock Exchange — secondary tier; mid-caps; ceiling/floor ±10%; lot size 100.
**Source**: HNX official rulebook (https://hnx.vn/) | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Sàn UPCoM
**Definition**: Unlisted Public Company Market — third tier; smaller caps + transitional listings; ceiling/floor ±15%; lower data quality.
**Source**: HNX UPCoM portal | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Phiên ATO (At-The-Open Auction)
**Definition**: HOSE opening-auction phase 09:00-09:15; single-price match; orders cannot be canceled within phase.
**Source**: HOSE trading-session schedule | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 2+

### Phiên ATC (At-The-Close Auction)
**Definition**: HOSE closing-auction phase 14:30-14:45; single-price match; sets official EOD close.
**Source**: HOSE trading-session schedule | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 2+

### Tỷ giá USD/VND (FX Rate)
**Definition**: USD-VND reference rate; SBV publishes daily central rate ±5% trading band. Cross-currency invariant: VND positions never converted to USD without explicit FX point-in-time tag (I-S6).
**Source**: SBV daily central-rate (https://www.sbv.gov.vn/) | **As-of**: 2026-04-30 | **BC**: BC-4 | **Phase**: 1

### Lô lẻ (Odd Lot)
**Definition**: Order size below standard lot (100 shares); routed to separate odd-lot session; lower liquidity; not part of main matching.
**Source**: HOSE trading rules § Order Types | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 2+

### Trần (Ceiling Price)
**Definition**: Daily upper-bound price = previous-close × (1 + ceiling-pct); ceiling-pct = 7% HOSE / 10% HNX / 15% UPCoM. Order at ceiling = hit-trần signal.
**Source**: HOSE/HNX rulebooks | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Sàn (Floor Price)
**Definition**: Daily lower-bound price = previous-close × (1 − floor-pct); same percentage tiers as Trần. Order at sàn = hit-sàn signal (panic).
**Source**: HOSE/HNX rulebooks | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Giá tham chiếu (Reference Price)
**Definition**: Previous trading day's close (HOSE/HNX) or last 15-day avg (UPCoM); basis for ceiling/floor calculation.
**Source**: HOSE/HNX rulebooks | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Cổ tức (Dividend)
**Definition**: Cash or stock distribution; ex-dividend date causes price adjustment. Bar OHLCV must tag adjustment_type per filing (I-S4).
**Source**: VSD corporate-action calendar | **As-of**: 2026-04-30 | **BC**: BC-1, BC-3 | **Phase**: 1

### Cổ phiếu thưởng (Bonus Shares)
**Definition**: Free-share distribution to existing holders (split-equivalent); causes downward adjustment of historical OHLCV.
**Source**: VSD corporate-action portal | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 2+

### Margin (Tỷ lệ vay margin)
**Definition**: Broker-financed leverage on equity positions; max 50% per VN regulation; margin call (CAP) when collateral ratio breaches threshold.
**Source**: SSC margin circulars | **As-of**: 2026-04-30 | **BC**: BC-9 | **Phase**: 2+

---

## VN30 + Sector Universe

### VN30
**Definition**: Top-30 index of HOSE largest + most-liquid stocks; quarterly rebalance; Phase 1 thin-slice anchored on VN30 universe (Charter § First Sub-Scope).
**Source**: HOSE VN30 methodology document | **As-of**: 2026-04-30 | **BC**: BC-1 | **Phase**: 1

### Vốn hóa (Market Cap)
**Definition**: Listed shares × current price; thresholds: large-cap >50,000 tỷ VND, mid-cap 2,000-50,000 tỷ VND (Charter), small-cap <2,000 tỷ VND.
**Source**: PROJECT_CHARTER.md § First Sub-Scope | **As-of**: 2026-04-30 | **BC**: BC-3 | **Phase**: 1

---

## Tier 3-4 Vocabulary (Phase 2+ — anchored here)

### KOL (Key Opinion Leader)
**Definition**: Vietnamese-language finance influencer on YouTube/Facebook/Telegram/Podcast; has rolling-window calibration score; recommendations measurably move VN prices (Charter § Core Insight).
**Source**: PROJECT_CHARTER.md § Core Insight + spec 002-influence-network-tracking.md | **As-of**: 2026-04-30 | **BC**: BC-6 | **Phase**: 2+

### Recommendation (KOL)
**Definition**: Specific call by a KOL on a Ticker {BUY | HOLD | SELL | WATCH} + timeframe + as-of; tracked to outcome for calibration.
**Source**: spec 002-influence-network-tracking.md | **As-of**: 2026-04-30 | **BC**: BC-6 | **Phase**: 2+

### Narrative Phase
**Definition**: Lifecycle stage of a market narrative: {INCUBATION | EMERGING | DISTRIBUTION | DUMP | POST_DUMP}; Tier 4 classifier output.
**Source**: spec 003-crowd-sentiment-pump-detection.md | **As-of**: 2026-04-30 | **BC**: BC-7 | **Phase**: 2+

### Pump Pattern
**Definition**: Cross-tier divergence signature (T3+T4 hot, T1+T2 silent) characteristic of coordinated price manipulation by Đội lái.
**Source**: spec 003-crowd-sentiment-pump-detection.md § A.3 Pattern 3 | **As-of**: 2026-04-30 | **BC**: BC-7 | **Phase**: 2+

### Crowd Sentiment
**Definition**: Aggregated forum/group/comment sentiment classifier output; profiled (not single-score per I-S11); lags price.
**Source**: spec 003-crowd-sentiment-pump-detection.md | **As-of**: 2026-04-30 | **BC**: BC-7 | **Phase**: 2+

### F319 / VFP (Forums)
**Definition**: Major VN retail-investor forums (f319.com, vietfinance.vn); Tier 4 sentiment + coordination-signature source.
**Source**: spec 003-crowd-sentiment-pump-detection.md § B (sources) | **As-of**: 2026-04-30 | **BC**: BC-7 | **Phase**: 2+

### Signal Tier
**Definition**: One of {T1 Hard Data | T2 Official Narrative | T3 Influence Network | T4 Crowd Sentiment}; every datum carries its tier; combinatorial confluence/divergence = analytical edge.
**Source**: spec four-tier-signal-architecture.md § A.2 | **As-of**: 2026-04-30 | **BC**: cross-cutting | **Phase**: 1 (T1 enforced); 2+ (T2-T4)

---

## Forbidden Terms (carry-over from v0)

| Forbidden | Canonical | Why |
|---|---|---|
| "buy signal" / "sell signal" | `Thesis` with grade | Charter § Boundaries — no price prediction |
| "recommendation" (system output) | `thesis exploration` | Legal framing (I-S35) |
| "price target" | `Fair Value Range` | False precision |
| "sentiment score" (single number) | `sentiment profile` (structured) | I-S11 no-single-score rule |
| "hot stock" / "hot pick" | `narrative-active ticker` | No hype language |

---

## Change Protocol

- Add term → append entry in correct section + log to `drift-log.md`
- Rename term → drift-log + codemod + update every reference
- Phase 2 entry: review `Phase: 2+` terms for activation; promote to enforcement.
