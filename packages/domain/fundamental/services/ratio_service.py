"""RatioService — deterministic Phase-2 ratio formula library (S34 Track C).

Six ratios per master-plan 005 § S34: P/E, P/B, ROE, ROA, Debt/Equity, Net
Margin. Each formula carries a textbook citation in `formula_audit` so a
downstream thesis output cites the exact derivation with no LLM paraphrase
(binds I-S1 + Rule 6).

TTM (trailing twelve months) aggregation rule: flow items (NetIncome, Revenue)
sum across the last 4 quarterly Income Statements; stock items (TotalAssets,
TotalEquity, TotalLiabilities, BookValuePerShare) read from the **most recent
filed** Balance Sheet — averaging two-period book value is a Phase 3 refinement
per Damodaran "Investment Valuation" 3rd ed §10.3 Note 2.

Division-by-zero raises RatioComputationError; missing line items raise
RatioInputMissingError. Never silently substitutes — financial-data-protocol
Rule 1 forbids "fill-with-NaN" patterns that would let look-ahead-bias hide.
"""

from __future__ import annotations

import contextlib
from collections.abc import Mapping
from dataclasses import dataclass
from datetime import date
from decimal import Decimal

from packages.contracts import Money, Ticker
from packages.domain.fundamental.models import FinancialStatement
from packages.domain.fundamental.value_objects import (
    LineItemKey,
    Ratio,
    RatioName,
    StatementType,
    line_item_required_for_ratio,
)

__all__ = ["RatioService", "RatioComputationError", "RatioInputMissingError"]


class RatioInputMissingError(KeyError):
    """Raised when a required LineItemKey is absent from the inputs."""


class RatioComputationError(ZeroDivisionError):
    """Raised when a formula's denominator is zero or invalid."""


_FORMULA_AUDIT: dict[RatioName, str] = {
    # P/E: market price per share / earnings per share (TTM).
    # Damodaran "Investment Valuation" 3rd ed §17.1; Vietstock convention follows.
    RatioName.PE: "price_per_share / eps_ttm — Damodaran Investment Valuation 3e §17.1",
    # P/B: market price per share / book value per share (latest BS).
    # Penman "Financial Statement Analysis" 5e §13.4.
    RatioName.PB: "price_per_share / book_value_per_share — Penman FSA 5e §13.4",
    # ROE: net income (TTM) / total equity (latest BS).
    # Higgins "Analysis for Financial Management" 11e §2.3 (avoids two-period averaging in Phase 2).
    RatioName.ROE: "net_income_ttm / total_equity_latest — Higgins AFM 11e §2.3",
    # ROA: net income (TTM) / total assets (latest BS).
    # Higgins "Analysis for Financial Management" 11e §2.3.
    RatioName.ROA: "net_income_ttm / total_assets_latest — Higgins AFM 11e §2.3",
    # Debt/Equity: total liabilities (latest BS) / total equity (latest BS).
    # Brealey-Myers "Principles of Corporate Finance" 13e §28.1; uses TOTAL liabilities not interest-bearing only — matches Vietstock.
    RatioName.DEBT_EQUITY: "total_liabilities_latest / total_equity_latest — Brealey-Myers PCF 13e §28.1",
    # Net Margin: net income (TTM) / revenue (TTM).
    # White-Sondhi-Fried "Analysis and Use of FS" 3e §1.4.
    RatioName.NET_MARGIN: "net_income_ttm / revenue_ttm — White-Sondhi-Fried AUFS 3e §1.4",
}


@dataclass
class RatioService:
    """Deterministic ratio formulas. Stateless — no caching, no I/O."""

    def compute_pe(
        self, *, eps_ttm: Decimal, price_per_share: Money, ticker: Ticker, period_end: date
    ) -> Ratio:
        if eps_ttm == 0:
            raise RatioComputationError(f"P/E denominator zero for {ticker} at {period_end}")
        value = price_per_share.amount / eps_ttm
        return Ratio(
            name=RatioName.PE, value=value, ticker=ticker, period_end=period_end,
            formula_audit=_FORMULA_AUDIT[RatioName.PE], computed_from=(StatementType.IS,),
        )

    def compute_pb(
        self, *, book_value_per_share: Money, price_per_share: Money, ticker: Ticker, period_end: date
    ) -> Ratio:
        if book_value_per_share.amount == 0:
            raise RatioComputationError(f"P/B denominator zero for {ticker} at {period_end}")
        value = price_per_share.amount / book_value_per_share.amount
        return Ratio(
            name=RatioName.PB, value=value, ticker=ticker, period_end=period_end,
            formula_audit=_FORMULA_AUDIT[RatioName.PB], computed_from=(StatementType.BS,),
        )

    def compute_roe(
        self, *, net_income_ttm: Money, total_equity: Money, ticker: Ticker, period_end: date
    ) -> Ratio:
        if total_equity.amount == 0:
            raise RatioComputationError(f"ROE denominator zero for {ticker} at {period_end}")
        value = net_income_ttm.amount / total_equity.amount
        return Ratio(
            name=RatioName.ROE, value=value, ticker=ticker, period_end=period_end,
            formula_audit=_FORMULA_AUDIT[RatioName.ROE],
            computed_from=(StatementType.IS, StatementType.BS),
        )

    def compute_roa(
        self, *, net_income_ttm: Money, total_assets: Money, ticker: Ticker, period_end: date
    ) -> Ratio:
        if total_assets.amount == 0:
            raise RatioComputationError(f"ROA denominator zero for {ticker} at {period_end}")
        value = net_income_ttm.amount / total_assets.amount
        return Ratio(
            name=RatioName.ROA, value=value, ticker=ticker, period_end=period_end,
            formula_audit=_FORMULA_AUDIT[RatioName.ROA],
            computed_from=(StatementType.IS, StatementType.BS),
        )

    def compute_debt_equity(
        self, *, total_liabilities: Money, total_equity: Money, ticker: Ticker, period_end: date
    ) -> Ratio:
        if total_equity.amount == 0:
            raise RatioComputationError(f"D/E denominator zero for {ticker} at {period_end}")
        value = total_liabilities.amount / total_equity.amount
        return Ratio(
            name=RatioName.DEBT_EQUITY, value=value, ticker=ticker, period_end=period_end,
            formula_audit=_FORMULA_AUDIT[RatioName.DEBT_EQUITY], computed_from=(StatementType.BS,),
        )

    def compute_net_margin(
        self, *, net_income_ttm: Money, revenue_ttm: Money, ticker: Ticker, period_end: date
    ) -> Ratio:
        if revenue_ttm.amount == 0:
            raise RatioComputationError(f"NetMargin denominator zero for {ticker} at {period_end}")
        value = net_income_ttm.amount / revenue_ttm.amount
        return Ratio(
            name=RatioName.NET_MARGIN, value=value, ticker=ticker, period_end=period_end,
            formula_audit=_FORMULA_AUDIT[RatioName.NET_MARGIN], computed_from=(StatementType.IS,),
        )

    def compute_ttm_ratios(
        self,
        *,
        ticker: Ticker,
        period_end: date,
        income_statements: list[FinancialStatement],
        latest_balance_sheet: FinancialStatement | None,
        price_per_share: Money | None,
    ) -> dict[RatioName, Ratio]:
        """Compute the 6 Phase-2 ratios from up-to-4 IS quarters + latest BS.

        Returns only the ratios that have all required inputs — missing inputs
        skip silently per Q-S28-3 doctrine ("log + continue") rather than abort
        the whole batch. Caller (Phase1DataGatherer) reads `gaps` separately.
        """
        out: dict[RatioName, Ratio] = {}
        ttm_is = self._aggregate_ttm(income_statements)
        net_income_ttm = ttm_is.get(LineItemKey.NET_INCOME.value)
        revenue_ttm = ttm_is.get(LineItemKey.REVENUE.value)

        if revenue_ttm is not None and net_income_ttm is not None:
            with contextlib.suppress(RatioComputationError):
                out[RatioName.NET_MARGIN] = self.compute_net_margin(
                    net_income_ttm=net_income_ttm, revenue_ttm=revenue_ttm,
                    ticker=ticker, period_end=period_end,
                )

        if latest_balance_sheet is None:
            return out

        equity = latest_balance_sheet.get_line_item(LineItemKey.TOTAL_EQUITY)
        assets = latest_balance_sheet.get_line_item(LineItemKey.TOTAL_ASSETS)
        liab = latest_balance_sheet.get_line_item(LineItemKey.TOTAL_LIABILITIES)
        bvps = latest_balance_sheet.get_line_item(LineItemKey.BOOK_VALUE_PER_SHARE)

        if net_income_ttm is not None and equity is not None:
            with contextlib.suppress(RatioComputationError):
                out[RatioName.ROE] = self.compute_roe(
                    net_income_ttm=net_income_ttm, total_equity=equity,
                    ticker=ticker, period_end=period_end,
                )
        if net_income_ttm is not None and assets is not None:
            with contextlib.suppress(RatioComputationError):
                out[RatioName.ROA] = self.compute_roa(
                    net_income_ttm=net_income_ttm, total_assets=assets,
                    ticker=ticker, period_end=period_end,
                )
        if liab is not None and equity is not None:
            with contextlib.suppress(RatioComputationError):
                out[RatioName.DEBT_EQUITY] = self.compute_debt_equity(
                    total_liabilities=liab, total_equity=equity,
                    ticker=ticker, period_end=period_end,
                )

        if price_per_share is None:
            return out

        eps_ttm = ttm_is.get(LineItemKey.EPS.value)
        if eps_ttm is not None and eps_ttm.amount != 0:
            with contextlib.suppress(RatioComputationError):
                out[RatioName.PE] = self.compute_pe(
                    eps_ttm=eps_ttm.amount, price_per_share=price_per_share,
                    ticker=ticker, period_end=period_end,
                )
        if bvps is not None:
            with contextlib.suppress(RatioComputationError):
                out[RatioName.PB] = self.compute_pb(
                    book_value_per_share=bvps, price_per_share=price_per_share,
                    ticker=ticker, period_end=period_end,
                )
        return out

    @staticmethod
    def _aggregate_ttm(income_statements: list[FinancialStatement]) -> Mapping[str, Money]:
        """Sum flow line items across the most recent 4 quarterly IS records.

        EPS is special-cased: TTM EPS = sum(quarterly EPS) per CFA Institute
        Curriculum 2024 Reading 24 §3.1 (basic EPS aggregation rule).
        Less than 4 quarters available → returns whatever is summable; caller
        decides whether the partial TTM is acceptable.
        """
        ordered = sorted(
            (s for s in income_statements if s.statement_type == StatementType.IS),
            key=lambda s: s.period_end,
            reverse=True,
        )[:4]
        if not ordered:
            return {}
        currency = ordered[0].currency
        sums: dict[str, Money] = {}
        flow_keys = (
            LineItemKey.REVENUE,
            LineItemKey.NET_INCOME,
            LineItemKey.GROSS_PROFIT,
            LineItemKey.EPS,
            LineItemKey.OPERATING_CASH_FLOW,
        )
        for key in flow_keys:
            total = Money(Decimal("0"), currency)
            present = False
            for stmt in ordered:
                v = stmt.get_line_item(key)
                if v is None:
                    continue
                total = total + v
                present = True
            if present:
                sums[key.value] = total
        return sums

    @staticmethod
    def required_line_items(ratio_name: RatioName) -> tuple[LineItemKey, ...]:
        """Re-exported VO mapping for caller-side pre-flight readiness checks."""
        return line_item_required_for_ratio(ratio_name.value)
