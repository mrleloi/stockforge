"""VnstockFundamentalAdapter — fetch FinancialStatements via vnstock Finance API.

vnstock 4.0.2 exposes `vnstock.api.financial.Finance(symbol).balance_sheet() /
income_statement() / cash_flow()`, returning DataFrames keyed by period. Each
row maps to one FinancialStatement record with normalized canonical
LineItemKey keys per packages/domain/fundamental/value_objects/line_item.py.

Vendor vocabulary mapping (vnstock raw column → canonical LineItemKey) lives
in `_VNSTOCK_LINE_ITEM_MAP`. When vnstock changes column names (vendor drift
hazard L-S28-1) the test suite catches the breakage on the recorded fixture
and the map updates here without touching domain code.

Phase 2 thin slice covers QUARTERLY frequency only; ANNUAL deferred (vnstock
exposes via the same API with `period="year"`, addable in Phase 3 when the
historical-percentile service wants 5+ years of data).
"""

from __future__ import annotations

import re
import time
from collections.abc import Iterator
from dataclasses import dataclass
from datetime import UTC, date, datetime
from decimal import Decimal
from typing import Protocol, cast

from packages.contracts import Currency, Money, SourceProvider, Ticker
from packages.domain.fundamental.models import FinancialStatement
from packages.domain.fundamental.value_objects import LineItemKey, StatementType

__all__ = ["VnstockFundamentalAdapter", "VnstockFundamentalAdapterError"]


_VND_THOUSANDS_MULTIPLIER = Decimal("1000")


class VnstockFundamentalAdapterError(RuntimeError):
    """Raised when vnstock returns an unexpected payload or transport fails."""


class FinanceFetchFn(Protocol):
    """Injectable Finance fetcher. Production = vnstock Finance methods."""

    def __call__(self, *, symbol: str, statement: str, period: str) -> object: ...


class _DataFrameLike(Protocol):
    columns: list[str]

    def iterrows(self) -> Iterator[tuple[int, dict[str, object]]]: ...


# vnstock Finance API column → canonical LineItemKey. Mapping is intentionally
# narrow — only the Phase 2 ratios' inputs are normalized; uncovered columns
# pass through as raw-string keys in `line_items` so adapters that need them
# (Phase 3 EBITDA path) extend the map without breaking the entity contract.
_VNSTOCK_LINE_ITEM_MAP: dict[str, LineItemKey] = {
    # Income Statement
    "Revenue": LineItemKey.REVENUE,
    "Net sales": LineItemKey.REVENUE,
    "Doanh thu thuần": LineItemKey.REVENUE,
    "Net Profit For the Year": LineItemKey.NET_INCOME,
    "Net profit": LineItemKey.NET_INCOME,
    "Net profit/(loss) after tax": LineItemKey.NET_INCOME,
    "Lợi nhuận sau thuế": LineItemKey.NET_INCOME,
    "Gross Profit": LineItemKey.GROSS_PROFIT,
    "EPS": LineItemKey.EPS,
    "EPS (VND)": LineItemKey.EPS,
    "EPS basic (VND)": LineItemKey.EPS,
    "Shares outstanding": LineItemKey.SHARES_OUTSTANDING,
    # Balance Sheet
    "TOTAL ASSETS (Bn. VND)": LineItemKey.TOTAL_ASSETS,
    "Total Assets": LineItemKey.TOTAL_ASSETS,
    "Tổng tài sản": LineItemKey.TOTAL_ASSETS,
    "OWNER'S EQUITY (Bn.VND)": LineItemKey.TOTAL_EQUITY,
    "Owner's Equity": LineItemKey.TOTAL_EQUITY,
    "Total equity": LineItemKey.TOTAL_EQUITY,
    "Vốn chủ sở hữu": LineItemKey.TOTAL_EQUITY,
    "LIABILITIES (Bn. VND)": LineItemKey.TOTAL_LIABILITIES,
    "Liabilities": LineItemKey.TOTAL_LIABILITIES,
    "Total liabilities": LineItemKey.TOTAL_LIABILITIES,
    "Nợ phải trả": LineItemKey.TOTAL_LIABILITIES,
    "BVPS (VND)": LineItemKey.BOOK_VALUE_PER_SHARE,
    "Book value per share": LineItemKey.BOOK_VALUE_PER_SHARE,
    # Cash Flow
    "Net cash inflows from operating activities": LineItemKey.OPERATING_CASH_FLOW,
    "Net cash inflows/(outflows) from operating activities": LineItemKey.OPERATING_CASH_FLOW,
    "Lưu chuyển tiền thuần từ hoạt động kinh doanh": LineItemKey.OPERATING_CASH_FLOW,
}


_PERIOD_COL_RE = re.compile(r"^(\d{4})-Q([1-4])$")
_QUARTER_END_MONTH_DAY: dict[int, tuple[int, int]] = {
    1: (3, 31),
    2: (6, 30),
    3: (9, 30),
    4: (12, 31),
}


def _quarter_label_to_period_end(label: str) -> date | None:
    m = _PERIOD_COL_RE.match(label)
    if m is None:
        return None
    year = int(m.group(1))
    quarter = int(m.group(2))
    month, day = _QUARTER_END_MONTH_DAY[quarter]
    return date(year, month, day)


_STATEMENT_API_TOKEN: dict[StatementType, str] = {
    StatementType.IS: "income_statement",
    StatementType.BS: "balance_sheet",
    StatementType.CF: "cash_flow",
}


@dataclass
class VnstockFundamentalAdapter:
    """Fetch FinancialStatements via vnstock Finance API. Stateless."""

    finance_fetch_fn: FinanceFetchFn | None = None
    rate_limit_seconds: float = 1.0
    _last_call_at: float = 0.0

    def __post_init__(self) -> None:
        if self.finance_fetch_fn is None:
            try:
                from vnstock.api.financial import Finance  # type: ignore[import-untyped]
            except ImportError as exc:  # pragma: no cover - import guarded
                raise VnstockFundamentalAdapterError(
                    "vnstock library not installed; pip install vnstock>=4.0.0"
                ) from exc

            def _fetch(*, symbol: str, statement: str, period: str) -> object:
                fin = Finance(symbol=symbol, source="VCI")
                method = getattr(fin, statement)
                return cast(object, method(period=period))

            object.__setattr__(self, "finance_fetch_fn", _fetch)

    def fetch_statements(
        self,
        ticker: Ticker,
        statement_type: StatementType,
        period: str = "quarter",
    ) -> list[FinancialStatement]:
        self._respect_rate_limit()
        assert self.finance_fetch_fn is not None
        df = self.finance_fetch_fn(
            symbol=ticker.symbol,
            statement=_STATEMENT_API_TOKEN[statement_type],
            period=period,
        )
        ingested_at = datetime.now(UTC)
        out: list[FinancialStatement] = []
        for row in self._iter_rows(df):
            period_end = self._coerce_period_end(row)
            if period_end is None or period_end > date.today():
                continue
            line_items = self._normalize_line_items(row)
            if not line_items:
                continue
            filing_date = self._coerce_filing_date(row, period_end)
            out.append(
                FinancialStatement(
                    ticker=ticker,
                    statement_type=statement_type,
                    period_end=period_end,
                    filing_date=filing_date,
                    ingested_at=ingested_at,
                    line_items=line_items,
                    source_provider=SourceProvider.VNSTOCK,
                    fiscal_period_label=str(row.get("yearReport", "") or row.get("period", "")),
                )
            )
        out.sort(key=lambda s: s.period_end)
        return out

    def _respect_rate_limit(self) -> None:
        elapsed = time.monotonic() - self._last_call_at
        if 0 < elapsed < self.rate_limit_seconds:
            time.sleep(self.rate_limit_seconds - elapsed)
        object.__setattr__(self, "_last_call_at", time.monotonic())

    @staticmethod
    def _iter_rows(df: object) -> Iterator[dict[str, object]]:
        if hasattr(df, "iterrows"):
            df_typed = cast(_DataFrameLike, df)
            cols = list(df_typed.columns)
            # vnstock 4.0.x WIDE format: columns include 'item'+'item_en' plus
            # period columns like '2026-Q1','2025-Q4'. Pivot wide→long: yield
            # one synthetic row per period with item_en→value mapping.
            period_cols = [c for c in cols if _PERIOD_COL_RE.match(str(c))]
            if "item_en" in cols and period_cols:
                rows_buf: list[dict[str, object]] = list(
                    {col: r[col] for col in cols} for _idx, r in df_typed.iterrows()
                )
                for period_col in period_cols:
                    period_end = _quarter_label_to_period_end(str(period_col))
                    if period_end is None:
                        continue
                    synthetic: dict[str, object] = {"period_end": period_end}
                    for item_row in rows_buf:
                        item_en = item_row.get("item_en")
                        item_vi = item_row.get("item")
                        value = item_row.get(period_col)
                        if value is None:
                            continue
                        if isinstance(item_en, str):
                            synthetic[item_en] = value
                        if isinstance(item_vi, str):
                            synthetic.setdefault(item_vi, value)
                    yield synthetic
                return
            # Long format (legacy / test fixtures): one row per period.
            for _idx, row in df_typed.iterrows():
                yield {col: row[col] for col in cols}
            return
        if isinstance(df, list):
            for row in df:
                yield cast(dict[str, object], row)
            return
        raise VnstockFundamentalAdapterError(
            f"unexpected vnstock Finance payload type {type(df).__name__}"
        )

    @staticmethod
    def _coerce_period_end(row: dict[str, object]) -> date | None:
        for key in ("period_end", "endDate", "yearReport", "period"):
            v = row.get(key)
            if v is None:
                continue
            if isinstance(v, date) and not isinstance(v, datetime):
                return v
            if isinstance(v, datetime):
                return v.date()
            if isinstance(v, str) and len(v) >= 10:
                try:
                    return datetime.strptime(v[:10], "%Y-%m-%d").date()
                except ValueError:
                    continue
        return None

    @staticmethod
    def _coerce_filing_date(row: dict[str, object], period_end: date) -> date:
        v = row.get("filing_date") or row.get("publicDate")
        if isinstance(v, date) and not isinstance(v, datetime):
            return max(v, period_end)
        if isinstance(v, datetime):
            return max(v.date(), period_end)
        if isinstance(v, str) and len(v) >= 10:
            try:
                parsed = datetime.strptime(v[:10], "%Y-%m-%d").date()
                return max(parsed, period_end)
            except ValueError:
                pass
        return period_end

    @staticmethod
    def _normalize_line_items(row: dict[str, object]) -> dict[str, Money]:
        out: dict[str, Money] = {}
        for raw_key, raw_value in row.items():
            if raw_value is None:
                continue
            canonical = _VNSTOCK_LINE_ITEM_MAP.get(raw_key)
            if canonical is None:
                continue
            try:
                numeric = Decimal(str(raw_value))
            except (ValueError, ArithmeticError):
                continue
            if "Bn" in raw_key:
                amount = numeric * _VND_THOUSANDS_MULTIPLIER * _VND_THOUSANDS_MULTIPLIER * _VND_THOUSANDS_MULTIPLIER
            else:
                amount = numeric
            out[canonical.value] = Money(amount, Currency.VND)
        return out
