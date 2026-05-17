"""_vnd_money_parser — VND string to Money converter for PDF cell values.

Delegates to EchoValidator._canonicalize_numeric_string (DRY reuse per DD-5).
Single canonical parser — matches the same logic used by G.3 ClaudeVisionPdfTableExtractor.

Source:
    plan-044 § E.1 D1 (apps/cli/_vnd_money_parser.py)
    DD-5: VND-parser DELEGATES to EchoValidator._canonicalize_numeric_string
    packages/application/fundamental/echo_validator.py:78-157
    packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:400-403
"""

from __future__ import annotations

from decimal import Decimal

from packages.application.fundamental.echo_validator import _canonicalize_numeric_string
from packages.contracts.types.money import Currency, Money

__all__ = ["VndParserError", "parse_vnd_to_money"]


class VndParserError(ValueError):
    """Raised when a raw VND string cannot be parsed to Money.

    Wraps ValueError from _canonicalize_numeric_string with context about the
    raw input. Callers MUST NOT silently skip on this error — it indicates
    an unexpected cell format that needs _PDF_CELL_MAP attention.
    """

    def __init__(self, raw: str, cause: Exception | None = None) -> None:
        self.raw = raw
        super().__init__(
            f"Cannot parse {raw!r} to VND Money "
            f"(DRY delegates to EchoValidator._canonicalize_numeric_string per DD-5)"
        )
        if cause is not None:
            self.__cause__ = cause


def parse_vnd_to_money(raw: str, currency: Currency = Currency.VND) -> Money:
    """Parse a raw VND string cell value to a canonical Money instance.

    Delegates canonicalization to EchoValidator._canonicalize_numeric_string
    (same function used by G.3 ClaudeVisionPdfTableExtractor for EchoValidator gate).
    Ensures ONE canonical parser across the full pipeline (DD-5 DRY reuse).

    Args:
        raw: Raw string from ExtractedFinancialStatement.raw_cells (e.g.
            '1.234.567', '500.000 triệu đồng', '(123.456)').
        currency: Currency enum value (default VND for domestic financials).

    Returns:
        Money(amount=Decimal, currency=currency) with amount from canonical parse.

    Raises:
        VndParserError: If raw cannot be parsed to Decimal after all coercions.
            Caller MUST handle — do NOT silently skip.
    """
    try:
        amount: Decimal = _canonicalize_numeric_string(raw)
    except ValueError as exc:
        raise VndParserError(raw, exc) from exc
    return Money(amount=amount, currency=currency)
