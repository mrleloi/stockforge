# BC-2: Fundamental

> Tier 1 (Hard Data) — financial reports, ratios, valuation inputs. Point-in-time integrity mandatory (I-S2).

**Responsibility**: Financial reports, ratios, valuation inputs.

**Aggregates**: FinancialStatement, Ratio, ValuationInput, EarningsRevision

**Storage**: Postgres with point-in-time integrity (each report has filing_date + period_end). 10-year retention for fundamentals.

**Sources** (Phase 1):
- Vietstock public — financial reports (PDF + structured)
- vnstock — basic fundamentals
- FiinPro — comprehensive normalized fundamentals (Phase 2-3 if budget)

**Backtest discipline** (financial-data-protocol.md):
- Every query MUST filter `WHERE filing_date <= as_of_date`
- Restated financials tracked via `restated_at` field
- Adjustment-type confusion is biggest risk

**LLM role**: NONE. Calculations like P/E, ROE, DCF use deterministic formulas in `services/`.
