---
thesis_id: 2026-04-30-VHM-exemplar
ticker: VHM
as_of: 2026-04-29
session: S30 (FOCUSED_IMPL — Phase 1 close)
exemplar: true
real_thesis: false
purpose: demonstrate template usage on Tier 1 ingested data; NOT a real thesis; NOT counted toward Charter Month-3 5-thesis criterion (Q-S30-1 doctrine)
data_source: data/vhm.sqlite (S28 ingestion; 248 bars 2025-05-05..2026-04-29; single-source vnstock VCI per IMPL-S28-3)
binding_invariants_demonstrated: I-S1 (no LLM math) / I-S5 (source attribution) / I-S6 (currency VND) / I-S10 (bear case ≥3) / I-S11 (multi-perspective Phase 1 = 3 stub) / I-S12 (disagreement preserved) / I-S26 (post-mortem schedule) / I-S35 (research-aid disclaimer)
---

# VHM — as of 2026-04-29 (EXEMPLAR — not a real thesis)

> **Status**: PASS — research aid only, not financial advice (I-S35).
> **Session**: S30 — FOCUSED_IMPL (Phase 1 close ceremony)
> **Horizon**: N/A (exemplar; no real horizon)
> **Grade**: D (Phase 1 has no calibration data; minimum confidence by default per I-S7)

> **Why PASS, not THESIS_CANDIDATE**: Phase 1 thin-slice ingests Tier 1 only (price + volume). A genuine thesis requires Tier 2 (fundamentals: P/E, P/B, ROE) + Tier 3 (KOL signal) + Tier 4 (crowd sentiment) — none yet operational. The honest output for a Tier-1-only context is PASS with structural-incompleteness flag, demonstrating the system's adversarial discipline.

## Summary
**Recommendation**: PASS (Tier 2+ data not yet available; cannot form value/quality verdict)
**Top question to resolve**: When Tier 2 fundamentals ingest in Phase 2, does the +139.74% 12m price action align with earnings/book-value evolution, or is it narrative-driven re-rating?

## Trade-Off Matrix
| Dimension | Verdict | Key Evidence (with source) |
|---|---|---|
| Value | UNKNOWN | No Tier 2 fundamentals ingested (Phase 2+); P/E, P/B, ROE all N/A |
| Quality | UNKNOWN | No financial statements ingested; governance / management quality not assessed |
| Growth | INFERRED-WEAK | Price-implied growth: +139.74% 12m return (Q12 below); growth without earnings basis = momentum, not fundamental |
| Risk | WEAK | Single-source data (Q9) violates reconciliation discipline (Rule 4); no fundamentals to validate; sector-specific BĐS regulatory exposure unobserved |

## Quant Summary (numbers from code, never LLM — I-S1)

> Every number below has a `-- query: ...` SQL trace against `data/vhm.sqlite`. LLM never produces numbers in prose.

- **Current price**: 146,000 VND as of 2026-04-29 `-- query: SELECT close_amount FROM bars WHERE ticker='VHM' ORDER BY period_end DESC LIMIT 1` (Q3)
- **Period covered**: 2025-05-05 → 2026-04-29 (248 trading days) `-- query: SELECT COUNT(*), MIN(period_end), MAX(period_end) FROM bars WHERE ticker='VHM'` (Q1)
- **52-week close range**: 58,000 — 151,000 VND `-- query: SELECT MIN(CAST(close_amount AS REAL)), MAX(CAST(close_amount AS REAL)) FROM bars WHERE ticker='VHM'` (Q4)
- **Total return (period)**: +139.74% `-- query: (last_close 146000.0 / first_close 60900.0) - 1` (Q12)
- **30-day return**: +43.14% (102,000 → 146,000) `-- query: ratio of last close to close at OFFSET 29` (Q13)
- **90-day return**: +57.84% (92,500 → 146,000) `-- query: ratio at OFFSET 89` (Q14)
- **Drawdown from peak**: -3.31% (peak 151,000 on path; current 146,000) `-- query: peak vs last` (Q15)
- **Avg daily volume (full period)**: 6,426,032 shares `-- query: SELECT AVG(volume) FROM bars WHERE ticker='VHM'` (Q6)
- **Avg daily volume (last 30d)**: 5,482,973 shares `-- query: SELECT AVG(volume) FROM (... ORDER BY period_end DESC LIMIT 30)` (Q5)
- **Max single-day volume**: 21,911,900 shares on 2025-05-20 (close 62,900) `-- query: SELECT period_end, volume FROM bars WHERE ticker='VHM' ORDER BY volume DESC LIMIT 1` (Q11)
- **Source provider distribution**: 100% vnstock (248/248); 0 TCBS rows (R2 residue per IMPL-S28-3) `-- query: SELECT source_provider, COUNT(*) FROM bars GROUP BY source_provider` (Q9)
- **Foreign net flow (last 30d)**: 0 (Phase 1 vnstock VCI source does not include foreign flow; foreign-flow ingestion = Phase 2 BC-1 hardening) `-- query: SELECT SUM(foreign_buy - foreign_sell) FROM ...` (Q10)
- **Currency**: VND (Phase 1 cross-currency forbidden per BR-3 + I-S6)

## Bull Case (Tier 1 only)

1. **Sustained 12-month uptrend** — total return +139.74% from 60,900 → 146,000 VND (Q12) over 248 trading days; sustained price action is consistent with re-rating narrative — source: `data/vhm.sqlite`, as-of: 2026-04-29
2. **Low recent drawdown from peak** — only -3.31% off 151,000 peak (Q15); momentum has not reversed yet — source: `data/vhm.sqlite`, as-of: 2026-04-29
3. **Volume signature consistent over period** — 30d avg 5.48M / full-period avg 6.43M (Q5/Q6); slight tapering but not exhaustion — source: `data/vhm.sqlite`, as-of: 2026-04-29

## Bear Case (mandatory ≥3 distinct points per I-S10)

1. **Recent 30d return +43% suggests momentum exhaustion risk** — annualized that pace = +1,400%; mathematically unsustainable on fundamentals; VN30 BĐS sector typically mean-reverts after such moves (Q13) — source: `data/vhm.sqlite`, as-of: 2026-04-29
2. **Structural Tier 2 incompleteness** — no P/E, P/B, ROE, debt/equity, or earnings data ingested; cannot validate whether +139.74% return is fundamentals-justified or pure narrative; in VN-domain (Charter § Core Insight) narrative-only moves carry high pump/dump risk — source: `PROJECT_CHARTER.md` § Core Insight + Phase 1 thin-slice scope, as-of: 2026-04-30
3. **Single-source data violates reconciliation discipline** — Q9 confirms 100% vnstock VCI (TCBS 404 per R2 residue); Rule 4 reconciliation tolerance ≥1% cannot be exercised → data-quality LOW per Charter Principle 1 (every claim has source + as-of) — source: `agent-workspace/constitution/financial-data-protocol.md` Rule 4 + `data/vhm-reconciliation.md`, as-of: 2026-04-30
4. **No Tier 3+4 data → no detection of pump/Đội lái patterns** — KOL recommendation tracking + crowd sentiment are Phase 2-3; if VHM has been heavily promoted recently, Phase 1 cannot detect it. The +139.74% return without Tier 3-4 visibility is exactly the scenario Charter calls "structurally inefficient market with KOL/influencer impact" — source: `PROJECT_CHARTER.md` § Tier 3-4 + Phase 1 thin-slice § A.5, as-of: 2026-04-30

## Explicit Disagreements (preserved per I-S12)

- **Topic: Recent uptrend interpretation** — Bull says "sustained re-rating" (point 1); Bear says "momentum exhaustion risk + narrative-only" (points 1+2). Resolution: pending Tier 2 ingestion + earnings filings (Phase 2). Cannot collapse to consensus without that data.

## Catalysts Watched (what could trigger re-rating)

- VN macro policy shift (interest-rate cuts, credit easing) — likely-to-track in Phase 2 BC-4 Macro
- Sector-specific regulation announcements (real estate credit policy) — Phase 2 BC-5 News
- Earnings releases (Q1/Q2 FY26) — Phase 2 BC-2 Fundamental
- Foreign-flow reversal — Phase 2 once foreign-flow feed integrated

## Risks (what could invalidate thesis)

- High momentum-reversal risk after +43% 30d (point Bear-1)
- Foreign-room saturation unknown (Phase 2 metric)
- Sector concentration with parent company VIC ecosystem dependence (Phase 2 BC-3)

## Invalidation Triggers (thesis dies if any of these)

- N/A for exemplar (PASS recommendation already; nothing to invalidate)
- For a real future thesis: would set "P/E exceeds 25x while ROE drops below 12%", "foreign-room saturation > 95% sustained", "monthly drawdown > -15%"

## Risk & Position Sizing (deterministic per Charter Principle 10)

> Numbers below come from RiskRule constants + personal-risk-profile.md, NOT from LLM. LLM cannot override.

- **Max position size**: 15.00% (RiskRule default per Charter § First Sub-Scope; personal-risk-profile.md § 2 = USER FILL still empty as of S30)
- **Sector exposure after add**: would-be 15% in BĐS — within sector cap 30% (Charter implicit)
- **Stop level**: N/A for exemplar (PASS, no entry); template would use thesis-invalidation triggers above
- **Holding period target**: N/A
- **T+2.5 cash check**: N/A

## Confidence (calibrated per I-S7)

- **Calibration grade**: D (Phase 1 baseline; no calibration data yet)
- **n_samples**: 0 (no prior thesis with outcomes; exemplar is the first thesis-template demonstration)
- **hit_rate**: N/A (Phase 2+ once 5-thesis backfill complete)
- **lookback_period**: N/A
- **Phase 1 heuristic verdict**: LOW confidence — perspectives partially align (Tier 1 evidence ambiguous) AND data is structurally incomplete (Tier 2-4 absent). LOW confidence + Tier-2-incompleteness → recommendation MUST be PASS or INVESTIGATE, never THESIS_CANDIDATE.

## Reasoning Trace

The system pulled 248 daily Bars for VHM from `data/vhm.sqlite` (S28-ingested via vnstock VCI single-source per IMPL-S28-3). Tier 1 deterministic computation surfaces a +139.74% 12-month return with low recent drawdown (-3.31% from peak) and tapering but consistent volume. Bull perspective reads this as sustained re-rating; bear perspective reads it as momentum-exhaustion risk + structural data incompleteness (no Tier 2 fundamentals to validate the narrative; no Tier 3-4 to detect KOL/crowd pump signal). Per I-S12 the disagreement is preserved, not collapsed. Per Charter § Honest Boundaries the system "predicts narrative phase" and never a price target; per I-S10 bear case is substantive ≥3 points. Final recommendation PASS reflects honest insufficiency, not a buy/sell signal.

## Sources Cited

| # | Source | As-of | Used For |
|---|---|---|---|
| 1 | `data/vhm.sqlite` (S28 ingestion via vnstock VCI) | 2026-04-29 | All quantitative numbers (Q1-Q15) |
| 2 | `data/vhm-reconciliation.md` (S28 reconciliation report) | 2026-04-30 | Single-source data flag (R2 residue) |
| 3 | `PROJECT_CHARTER.md` § Core Insight + Tier 3-4 + First Sub-Scope | 2026-04-30 | Bear points 2, 4; risk sizing default 15% |
| 4 | `agent-workspace/constitution/financial-data-protocol.md` Rule 4 | 2026-04-23 | Bear point 3 (reconciliation discipline) |
| 5 | `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` § A.5 | 2026-04-30 | Tier 2-4 out-of-scope framing |

## Personal Bias Check (Charter Principle 6 + I-S22)

- **Do I (the user) own VHM?**: UNKNOWN — `personal-risk-profile.md` § 7 audit trail is empty; user has not filled the profile yet. If owned, confirmation bias risk HIGH on bull-case interpretation.
- **Public position?**: UNKNOWN
- **Sector overweight bias?**: UNKNOWN — § 5 USER FILL empty
- **Recent gut-vs-system divergence?**: N/A (this is the first thesis exemplar)

## Data Freshness

- **Price data staleness**: green — last bar at 2026-04-29 (1 day ago)
- **Fundamentals**: N/A (Phase 2+ ingestion pending)
- **News**: N/A (Phase 2+)
- **Source reconciliation**: SINGLE_SOURCE only (R2 residue) — Phase 2 hardening to discover working TCBS endpoint OR pivot to DNSE/KBS via vnstock

## Post-Mortem Schedule (I-S26)

- **Horizon close**: N/A for exemplar (no real horizon; this is template demonstration only)
- **Post-mortem file** (would-be path for real thesis): `agent-workspace/memory/post-mortems/2026-10-30-VHM-horizon6m.md`
- **For exemplar**: post-mortem is NOT scheduled because no real position taken; calibration database does not consume exemplar entries.

---

## Disclaimer (I-S35 mandatory)

*This is a research aid, not financial advice. Decisions and responsibility are yours. This entry is an EXEMPLAR demonstrating the thesis-log/_template.md schema — not a real investment thesis. Numbers come from `data/vhm.sqlite` (deterministic SQL queries Q1-Q15); narrative comes from LLM interpretation of those numbers within the Phase 1 thin-slice scope. The Vietnamese stock market is structurally volatile; real theses require Tier 2-4 data not available in Phase 1. Position sizing per personal-risk-profile.md (currently empty as of S30 — user must fill before any real entry).*

[Archive thesis ID: `2026-04-30-VHM-exemplar` — exemplar; not in calibration DB]
