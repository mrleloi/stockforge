"""_pdf_cell_mapper — deterministic cell-label→LineItemKey mapper for PDF extraction.

Maps ExtractedFinancialStatement.raw_cells (adapter-specific labels) to canonical
FinancialStatement.line_items (LineItemKey→Money) via a bilingual lookup table.
IS-subset V0: REVENUE / GROSS_PROFIT / NET_INCOME / EPS.

Pattern reference:
    packages/infrastructure/fundamental/vnstock_fundamental_adapter.py _VNSTOCK_LINE_ITEM_MAP
    plan-044 § E.2 D2 (apps/cli/_pdf_cell_mapper.py)

Design decisions:
    DD-2: SourceProvider = SCRAPED_OTHER (existing enum per adjustment_type.py:51)
    DD-3: ADDITIVE-ONLY-DEFAULT — ZERO FinancialStatement schema change V0
    DD-4: Mapper at APPLICATION layer (apps/cli/) NOT inside adapter; adapter returns raw_cells
    DD-5: parse_vnd_to_money delegates to EchoValidator._canonicalize_numeric_string (DRY)
    RM-G4-3: ≥3 Vietnamese variants per LineItemKey for label-drift robustness

Source:
    plan-044 § D DD-2 + § E.2 D2
    packages/domain/fundamental/value_objects/line_item.py:24-45 (LineItemKey)
    packages/contracts/types/adjustment_type.py:51 (SCRAPED_OTHER)
"""

from __future__ import annotations

from datetime import UTC, datetime
from datetime import date as date_type

from apps.cli._vnd_money_parser import VndParserError, parse_vnd_to_money
from packages.application.fundamental.extracted_financial_statement import (
    ExtractedFinancialStatement,
)
from packages.contracts import SourceProvider, Ticker
from packages.contracts.types.money import Currency
from packages.domain.fundamental.models.financial_statement import FinancialStatement
from packages.domain.fundamental.value_objects import LineItemKey

__all__ = [
    "PdfMapperError",
    "RequiredCellMissingError",
    "_PDF_CELL_MAP",
    "map_extracted_to_financial_statement",
]


class PdfMapperError(ValueError):
    """Base error for PDF cell-label mapping failures."""


class RequiredCellMissingError(PdfMapperError):
    """Raised when a required LineItemKey is absent from the extracted cells.

    For IS-subset V0: NET_INCOME is required (ratio_service.compute_net_margin
    + compute_roe + compute_roa all depend on it per line_item.py:59-63).
    """

    def __init__(self, missing_key: LineItemKey, seen_labels: list[str]) -> None:
        self.missing_key = missing_key
        self.seen_labels = seen_labels
        super().__init__(
            f"Required LineItemKey {missing_key.value!r} absent from extracted cells. "
            f"Seen-but-unmapped labels: {seen_labels[:20]} "
            f"(extend _PDF_CELL_MAP with additional Vietnamese/English variants per RM-G4-3)"
        )


# ── Bilingual lookup table ─────────────────────────────────────────────────────
# Keys: raw cell labels as they appear in VHM PDF (Vietnamese + English variants).
# Values: canonical LineItemKey enum members.
# Case-insensitive lookup applied at mapping time (see _normalise_label).
# Per RM-G4-3: ≥3 variants per IS-subset LineItemKey for label-drift robustness.
_PDF_CELL_MAP: dict[str, LineItemKey] = {
    # ── REVENUE ───────────────────────────────────────────────────────────────
    "doanh thu thuần": LineItemKey.REVENUE,
    "doanh thu thuần về bán hàng và cung cấp dịch vụ": LineItemKey.REVENUE,
    "doanh thu bán hàng và cung cấp dịch vụ": LineItemKey.REVENUE,
    "doanh thu bán hàng": LineItemKey.REVENUE,
    "net revenue": LineItemKey.REVENUE,
    "net revenues": LineItemKey.REVENUE,
    "revenue": LineItemKey.REVENUE,
    "revenues": LineItemKey.REVENUE,
    "total revenue": LineItemKey.REVENUE,
    "total revenues": LineItemKey.REVENUE,
    "net sales": LineItemKey.REVENUE,
    # ── GROSS_PROFIT ─────────────────────────────────────────────────────────
    "lợi nhuận gộp": LineItemKey.GROSS_PROFIT,
    "lợi nhuận gộp về bán hàng và cung cấp dịch vụ": LineItemKey.GROSS_PROFIT,
    "gross profit": LineItemKey.GROSS_PROFIT,
    "gross profit from sales": LineItemKey.GROSS_PROFIT,
    "lãi gộp": LineItemKey.GROSS_PROFIT,
    # ── NET_INCOME ───────────────────────────────────────────────────────────
    "lợi nhuận sau thuế": LineItemKey.NET_INCOME,
    "lợi nhuận sau thuế thu nhập doanh nghiệp": LineItemKey.NET_INCOME,
    "lợi nhuận sau thuế của cổ đông công ty mẹ": LineItemKey.NET_INCOME,
    "lợi nhuận thuần": LineItemKey.NET_INCOME,
    "lãi sau thuế": LineItemKey.NET_INCOME,
    "lãi ròng": LineItemKey.NET_INCOME,
    "net income": LineItemKey.NET_INCOME,
    "net profit": LineItemKey.NET_INCOME,
    "net profit after tax": LineItemKey.NET_INCOME,
    "profit after tax": LineItemKey.NET_INCOME,
    "profit after income tax": LineItemKey.NET_INCOME,
    "net profit attributable to shareholders": LineItemKey.NET_INCOME,
    "net earnings": LineItemKey.NET_INCOME,
    # ── EPS ──────────────────────────────────────────────────────────────────
    "lãi cơ bản trên cổ phiếu": LineItemKey.EPS,
    "lãi trên cổ phiếu": LineItemKey.EPS,
    "lãi cơ bản trên mỗi cổ phiếu": LineItemKey.EPS,
    "eps": LineItemKey.EPS,
    "basic eps": LineItemKey.EPS,
    "earnings per share": LineItemKey.EPS,
    "basic earnings per share": LineItemKey.EPS,
}

# Required keys for IS-subset V0 (ratio_service.compute_net_margin depends on both)
_IS_REQUIRED_KEYS: frozenset[LineItemKey] = frozenset({LineItemKey.NET_INCOME})


def _normalise_label(label: str) -> str:
    """Normalize a cell label for case-insensitive lookup.

    Strips leading/trailing whitespace and converts to lowercase.
    Matches the canonicalization applied at lookup time in _PDF_CELL_MAP keys.
    """
    return label.strip().lower()


def map_extracted_to_financial_statement(
    extracted: ExtractedFinancialStatement,
    ticker: Ticker,
    filing_date: date_type,
    sector: str | None = None,
) -> FinancialStatement:
    """Map ExtractedFinancialStatement to a canonical FinancialStatement.

    Iterates extracted.raw_cells; looks up each label in _PDF_CELL_MAP
    (case-insensitive); calls parse_vnd_to_money on matched values;
    constructs FinancialStatement with SourceProvider.SCRAPED_OTHER (DD-2).

    Args:
        extracted: Validated ExtractedFinancialStatement from G.3 adapter
            (raw_cells already passed EchoValidator gate per DD-4).
        ticker: VN stock ticker (e.g. Ticker('VHM')).
        filing_date: Report filing date (>= period_end per Rule 1).
        sector: Optional sector string (passed to FinancialStatement.sector).

    Returns:
        FinancialStatement with line_items keyed by LineItemKey.value strings,
        source_provider=SCRAPED_OTHER, ingested_at=datetime.now(UTC).

    Raises:
        RequiredCellMissingError: If NET_INCOME is absent from extracted cells
            after mapping (required for IS ratio computations).
        PdfMapperError: On unexpected mapping failure.
    """
    line_items = {}
    seen_but_unmapped: list[str] = []
    currency = Currency.VND  # IS V0 always VND

    for raw_label, raw_value in extracted.raw_cells.items():
        normalised = _normalise_label(raw_label)
        canonical_key = _PDF_CELL_MAP.get(normalised)
        if canonical_key is None:
            seen_but_unmapped.append(raw_label)
            continue
        try:
            money = parse_vnd_to_money(raw_value, currency=currency)
        except VndParserError:
            # Skip non-parseable cells; RequiredCellMissingError fires below if needed
            seen_but_unmapped.append(raw_label)
            continue
        line_items[canonical_key.value] = money

    # Validate required keys for IS-subset V0
    for required_key in _IS_REQUIRED_KEYS:
        if required_key.value not in line_items:
            raise RequiredCellMissingError(required_key, seen_but_unmapped)

    return FinancialStatement(
        ticker=ticker,
        statement_type=extracted.pdf_source.statement_type,
        period_end=extracted.pdf_source.period_end,
        filing_date=filing_date,
        ingested_at=datetime.now(UTC),  # D-059 R1: tz-aware
        line_items=line_items,
        source_provider=SourceProvider.SCRAPED_OTHER,  # DD-2
        sector=sector,
        restated_at=None,
        fiscal_period_label="",  # default per FinancialStatement.fiscal_period_label
    )
