"""LineItemKey — canonical line-item names for Vietnamese financial statements.

Per spec-T1-001 § B.1 FinancialStatement.line_items is a `dict[str, Money]`.
Free-form keys would let adapters drift (vnstock returns "doanhthu" while
Vietstock returns "Net revenue") and break ratio_service formulas downstream.
This module enumerates the **canonical English keys** that
VnstockFundamentalAdapter must normalize to. Adapter-side translation is
encoded in the adapter, not the entity, so the domain stays free of vendor
vocabulary.

The mapping table at the bottom (`line_item_required_for_ratio`) makes the
contract with `services/ratio_service.py` explicit: each Ratio names the
LineItemKey set it depends on, so a missing key surfaces as a deterministic
RatioInputMissingError rather than a silent KeyError.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["LineItemKey", "line_item_required_for_ratio"]


class LineItemKey(StrEnum):
    """Canonical line-item identifiers across the three statement types.

    Phase 2 scope covers the items needed by the 6 ratios in master-plan
    005 § S34 (P/E, P/B, ROE, ROA, Debt/Equity, Net Margin). Phase 3 expands
    with EBITDA, Operating CF, working-capital line items as Tier 2 thesis
    spec demands.
    """

    # Income Statement
    REVENUE = "revenue"
    GROSS_PROFIT = "gross_profit"
    NET_INCOME = "net_income"
    EPS = "eps"
    SHARES_OUTSTANDING = "shares_outstanding"
    # Balance Sheet
    TOTAL_ASSETS = "total_assets"
    TOTAL_EQUITY = "total_equity"
    TOTAL_LIABILITIES = "total_liabilities"
    BOOK_VALUE_PER_SHARE = "book_value_per_share"
    # Cash Flow
    OPERATING_CASH_FLOW = "operating_cash_flow"


def line_item_required_for_ratio(ratio_name: str) -> tuple[LineItemKey, ...]:
    """Return the LineItemKeys the named ratio formula reads.

    Used by ratio_service.compute_*() pre-flight check; missing keys raise
    RatioInputMissingError before the formula divides anything. Keeping the
    mapping in the VO module (not the service) lets tests audit the contract
    without importing the service.
    """
    table: dict[str, tuple[LineItemKey, ...]] = {
        "PE": (LineItemKey.EPS,),
        "PB": (LineItemKey.BOOK_VALUE_PER_SHARE,),
        "ROE": (LineItemKey.NET_INCOME, LineItemKey.TOTAL_EQUITY),
        "ROA": (LineItemKey.NET_INCOME, LineItemKey.TOTAL_ASSETS),
        "DEBT_EQUITY": (LineItemKey.TOTAL_LIABILITIES, LineItemKey.TOTAL_EQUITY),
        "NET_MARGIN": (LineItemKey.NET_INCOME, LineItemKey.REVENUE),
    }
    return table.get(ratio_name, ())
