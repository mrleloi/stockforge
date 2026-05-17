"""ExtractedFinancialStatement — intermediate dataclass for raw PDF table extraction.

Bundles raw extracted cells from a PDF BEFORE deterministic mapping to canonical
FinancialStatement.line_items: Mapping[str, Money]. The mapping from raw adapter-
specific cell labels to LineItemKey canonical keys happens in the G.2 pure-Python
adapter (sub-plan 042) and G.3 Claude vision adapter (sub-plan 043).

This intermediate dataclass is the return type of PdfTableExtractorPort.extract()
and carries 6 provenance fields per parent plan-040 DD-2/DD-3 (I-S22 data lineage).

Invariants enforced in __post_init__:
- raw_cells must be non-empty (at least 1 extracted cell).
- source_pdf_sha256 must be a valid 64-hex-character SHA-256 string.
- extracted_at must be timezone-aware (D-059 R1 datetime-no-tz invariant).
- extraction_method must be non-empty (provenance field).
- extractor_version must be non-empty (semver provenance field).
- source_pdf_page if not None must be >= 1 (1-indexed page numbers).

Source: agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md § D2
        agent-workspace/constitution/invariants.md (D-059 R1 datetime-tz)
        agent-workspace/memory/decisions/059-python-determinism-contract.md
        parent plan-040 DD-2/DD-3 (provenance field requirements)
"""

from __future__ import annotations

import re
from collections.abc import Mapping
from dataclasses import dataclass
from datetime import datetime

from packages.application.fundamental.pdf_source import PdfSource

__all__ = ["ExtractedFinancialStatement", "ExtractedFinancialStatementInvariantError"]

_SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


class ExtractedFinancialStatementInvariantError(ValueError):
    """Raised when ExtractedFinancialStatement is constructed with invalid field values."""


@dataclass(frozen=True, slots=True)
class ExtractedFinancialStatement:
    """Immutable intermediate dataclass for raw PDF table extraction output.

    Carries raw extracted cells (adapter-specific labels → raw string values)
    BEFORE deterministic mapping to FinancialStatement.line_items. Provenance
    fields trace the exact extractor, version, and source PDF for calibration.

    Fields:
        pdf_source: The PdfSource input that produced this extraction
            (ticker, statement_type, period_end, filing_date, source_url, pdf_path).
        raw_cells: Mapping from adapter-specific cell label → raw extracted string.
            Keys are adapter-internal (e.g. 'Doanh thu thuần' or 'Net revenue');
            canonical mapping to LineItemKey happens in G.2/G.3 adapters.
        extraction_method: Human-readable adapter name (e.g. 'pdfplumber+camelot v0.10.0').
            Populates from PdfTableExtractorPort.name().
        extractor_version: Semver string (e.g. '0.1.0').
            Populates from PdfTableExtractorPort.extractor_version().
        source_pdf_page: 1-indexed page number where the primary table was found,
            or None if the adapter does not track per-cell pages.
        source_pdf_sha256: SHA-256 hex digest of the source PDF file (64 hex chars).
            Enables reproducibility verification: same SHA256 → deterministic re-run.
        extracted_at: UTC-aware datetime when extraction was performed (D-059 R1).
    """

    pdf_source: PdfSource
    raw_cells: Mapping[str, str]
    extraction_method: str
    extractor_version: str
    source_pdf_page: int | None
    source_pdf_sha256: str
    extracted_at: datetime

    def __post_init__(self) -> None:
        # raw_cells non-empty: at least 1 extracted cell required.
        if not self.raw_cells:
            raise ExtractedFinancialStatementInvariantError(
                "raw_cells must not be empty — ExtractedFinancialStatement requires "
                "at least 1 extracted cell (extraction produced zero cells)."
            )

        # source_pdf_sha256 must be a valid 64-char hex SHA-256 string.
        if not _SHA256_RE.match(self.source_pdf_sha256):
            raise ExtractedFinancialStatementInvariantError(
                f"source_pdf_sha256 {self.source_pdf_sha256!r} is not a valid "
                f"64-character lowercase hex SHA-256 string."
            )

        # D-059 R1: extracted_at must be timezone-aware (no naive datetimes).
        if self.extracted_at.tzinfo is None:
            raise ExtractedFinancialStatementInvariantError(
                f"extracted_at {self.extracted_at!r} must be timezone-aware "
                f"(D-059 R1 datetime-no-tz invariant; use datetime.now(UTC))."
            )

        # extraction_method non-empty: provenance tracing requires adapter name.
        if not self.extraction_method.strip():
            raise ExtractedFinancialStatementInvariantError(
                "extraction_method must not be empty or whitespace-only "
                "(provenance field populated by PdfTableExtractorPort.name())."
            )

        # extractor_version non-empty: provenance tracing requires semver.
        if not self.extractor_version.strip():
            raise ExtractedFinancialStatementInvariantError(
                "extractor_version must not be empty or whitespace-only "
                "(provenance field populated by PdfTableExtractorPort.extractor_version())."
            )

        # source_pdf_page if not None must be >= 1 (1-indexed page numbers).
        if self.source_pdf_page is not None and self.source_pdf_page < 1:
            raise ExtractedFinancialStatementInvariantError(
                f"source_pdf_page {self.source_pdf_page} must be >= 1 "
                f"(1-indexed page numbers; None allowed for adapters that don't track pages)."
            )
