"""PdfSource — value object encapsulating PDF input for PdfTableExtractorPort.

Encapsulates the input to PdfTableExtractorPort.extract() to avoid a 6-positional-arg
method signature anti-pattern. Mirrors the shape of FinancialStatement fields
(ticker, statement_type, period_end, filing_date) with PDF-specific additions
(pdf_path, source_url).

Invariants enforced in __post_init__:
- Rule 1 (point-in-time integrity): filing_date >= period_end per
  packages/domain/fundamental/models/financial_statement.py:69-73.
- D-064 path-safety: pdf_path validated via safe_user_path (P2 user-supplied invariant);
  callers must pass the path within STOCKFORGE_ALLOWED_FILE_ROOTS or data/ defaults.
  Tests override via STOCKFORGE_ALLOWED_FILE_ROOTS env var.
- source_url must start with http:// or https:// (basic URL validity).

Source: agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md § D2
        packages/domain/fundamental/models/financial_statement.py (Rule 1 pattern)
        packages/_shared/path_safety.py (D-064 path-safety helpers)
        agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from pathlib import Path

from packages._shared.path_safety import safe_user_path
from packages.contracts import Ticker
from packages.domain.fundamental.value_objects import StatementType

__all__ = ["PdfSource", "PdfSourceInvariantError"]


class PdfSourceInvariantError(ValueError):
    """Raised when a PdfSource is constructed with values violating Rule 1 / D-064."""


@dataclass(frozen=True, slots=True)
class PdfSource:
    """Immutable value object encapsulating a PDF input for table extraction.

    All fields are required; no defaults. Frozen + slotted for immutability and
    memory efficiency per packages/domain/fundamental/models/financial_statement.py
    frozen+slotted pattern.

    Fields:
        pdf_path: Local filesystem path to the PDF file. D-064 path-safety validated
            via safe_user_path; must be inside STOCKFORGE_ALLOWED_FILE_ROOTS or defaults.
        source_url: HTTP(S) URL where the PDF was originally sourced (I-S2 citation).
        ticker: VN stock ticker (e.g. Ticker('VHM')).
        statement_type: IS / BS / CF per StatementType StrEnum.
        period_end: Financial period end date (e.g. date(2023, 12, 31)).
        filing_date: Date the report was officially filed (>= period_end per Rule 1).
    """

    pdf_path: Path
    source_url: str
    ticker: Ticker
    statement_type: StatementType
    period_end: date
    filing_date: date

    def __post_init__(self) -> None:
        # D-064 path-safety: validate pdf_path is within allowed import roots.
        # safe_user_path raises ValueError on rejection (P2 + P5 invariants).
        try:
            safe_user_path(str(self.pdf_path))
        except ValueError as exc:
            raise PdfSourceInvariantError(
                f"pdf_path {str(self.pdf_path)!r} failed D-064 path-safety check: {exc}"
            ) from exc

        # Basic URL validity — must be HTTP(S) for public source citation (I-S2).
        if not self.source_url.startswith(("http://", "https://")):
            raise PdfSourceInvariantError(
                f"source_url {self.source_url!r} must start with http:// or https:// "
                f"(I-S2 citation discipline — public sources only per I-S34)"
            )

        # Rule 1 (point-in-time integrity): filing_date >= period_end.
        # Mirror: packages/domain/fundamental/models/financial_statement.py:69-73.
        if self.filing_date < self.period_end:
            raise PdfSourceInvariantError(
                f"filing_date {self.filing_date} < period_end {self.period_end} "
                f"(filing cannot precede the period it reports; Rule 1)"
            )
