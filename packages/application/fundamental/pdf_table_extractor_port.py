# Portions adapted from Crawl4AI (https://github.com/unclecode/crawl4ai),
# Apache-2.0 + Attribution Requirement; see NOTICE at repo root for full text.
# Source pattern: crawl4ai/hub.py:24-35 (BaseCrawler.__init_subclass__ typecheck)
"""PdfTableExtractorPort — abstract port for per-library PDF table extractors in BC-2.

Architecture:
- Port (ABC) lives in the application layer (this file) per stockforge convention
  (architecture.md § BC-2: domain = pure, application = ports, infra = adapters).
- Concrete adapters live in packages/infrastructure/fundamental/.
- The CLI dispatches via adapter.supports(pdf_path) pre-check per DD-2.

Design decisions (plan 041 § D, DD-1 through DD-8):
- ABC over Protocol: runtime-enforced contract via __init_subclass__ (DD-1 + D-066 precedent).
- source_id ClassVar enforced non-empty at class-definition time (DD-2).
- 4 abstract methods: extract + supports + name + extractor_version (DD-2).
- extractor_version is +1 over D-066 CrawlerAdapter's 3 methods — principled extension
  for ExtractedFinancialStatement.extractor_version provenance field per DD-3.
- ZERO pyproject.toml dep addition at G.1 — isolated-venv probe per DD-8.
- Shared base error hierarchy enables cross-adapter error handling (DD-1).

Subclasses MUST:
- Declare a non-empty ``source_id`` ClassVar (e.g. ``source_id = "pdfplumber+camelot"``).
  Violation raises TypeError at class-definition time (not at instantiation).
- Implement all 4 abstract methods below.

Subclasses MUST NOT:
- Import PDF library dependencies at module top-level; use per-adapter lazy import
  guarded by PdfTableExtractorOptionalDepError.
- Emit new LLM-numeric fields in extract() output
  (Rule 16 / D-065 binding — the extractor surface is numeric-free by construction
  at G.1; G.3 Claude vision adapter introduces EchoValidator gate per parent plan-040 § E.3).

Source: agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md § D1
        packages/application/news/ports/crawler_adapter.py (D-066 CrawlerAdapter precedent)
        crawl4ai/hub.py:24-35 (BaseCrawler.__init_subclass__)
        agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from pathlib import Path
from typing import TYPE_CHECKING, ClassVar

if TYPE_CHECKING:
    # Imported under TYPE_CHECKING to avoid circular import at runtime.
    # At runtime, these types are resolved lazily; mypy sees them correctly.
    from packages.application.fundamental.extracted_financial_statement import (
        ExtractedFinancialStatement,
    )
    from packages.application.fundamental.pdf_source import PdfSource

__all__ = [
    "PdfTableExtractorPort",
    "PdfTableExtractorError",
    "PdfTableExtractorOptionalDepError",
]


class PdfTableExtractorError(Exception):
    """Base error for all PDF table extractor failures.

    Subclass with specific error kinds:
    - PdfTableExtractorOptionalDepError — library not installed
    - Use PdfTableExtractorError directly for parse / OCR / network failures
    """


class PdfTableExtractorOptionalDepError(PdfTableExtractorError, ImportError):
    """Raised when an optional PDF library dependency is not installed.

    Pattern: per-adapter lazy import guard (mirrors crawl4ai per-adapter
    optional-import strategy). Callers can catch this to route to a fallback
    adapter without crashing.

    Example::

        class PdfPlumberAdapter(PdfTableExtractorPort):
            source_id = "pdfplumber+camelot"

            def __init__(self) -> None:
                try:
                    import pdfplumber  # noqa: F401
                    import camelot  # noqa: F401
                except ImportError as exc:
                    raise PdfTableExtractorOptionalDepError(
                        "pdfplumber and camelot-py must be installed: "
                        "pip install pdfplumber camelot-py"
                    ) from exc
    """


class PdfTableExtractorPort(ABC):
    """Abstract port for per-library PDF table extractors in BC-2 Fundamental Data.

    Subclasses MUST:
    - Declare a non-empty ``source_id`` ClassVar
      (e.g. ``source_id = "pdfplumber+camelot"``).
      Violation raises TypeError at class-definition time (not at instantiation).
    - Implement the four abstract methods below.

    Subclasses MUST NOT:
    - Import PDF library dependencies at module top-level; use lazy import per
      PdfTableExtractorOptionalDepError pattern.
    - Emit new LLM-numeric fields in extract() output
      (Rule 16 / D-065 binding; G.3 Claude vision adapter uses EchoValidator gate).
    """

    source_id: ClassVar[str]  # enforced non-empty via __init_subclass__

    def __init_subclass__(cls, **kwargs: object) -> None:
        """Enforce non-empty source_id at subclass definition time.

        Pattern adapted from crawl4ai/hub.py:24-35 (BaseCrawler.__init_subclass__
        typecheck) via packages/application/news/ports/crawler_adapter.py:60-78
        (D-066 CrawlerAdapter precedent). Unlike crawl4ai which checks async run()
        signature, this checks source_id ClassVar to ensure registry keying is
        safe at definition time rather than at instantiation or first use.

        Raises:
            TypeError: If the subclass does not declare a non-empty source_id ClassVar.
        """
        super().__init_subclass__(**kwargs)
        # Abstract base itself has no source_id — allow it; concrete subclasses must have one.
        if not getattr(cls, "source_id", "").strip():
            raise TypeError(
                f"{cls.__name__} must declare a non-empty source_id ClassVar "
                f"(e.g. source_id = \"pdfplumber+camelot\"). "
                f"Pattern: crawl4ai/hub.py:24-35 + "
                f"packages/application/news/ports/crawler_adapter.py:60-78."
            )

    @abstractmethod
    def extract(self, pdf_source: PdfSource) -> ExtractedFinancialStatement:
        """Extract financial statement cells from a PDF source.

        Args:
            pdf_source: Encapsulates PDF path + provenance metadata (ticker,
                statement_type, period_end, filing_date, source_url).

        Returns:
            ExtractedFinancialStatement with raw_cells (adapter-specific labels →
            raw string values), provenance fields, and source_pdf_sha256.

        Raises:
            PdfTableExtractorError: On extraction failure (parse error, OCR error,
                corrupted PDF, unsupported PDF version).
            PdfTableExtractorOptionalDepError: If library not installed.
        """

    @abstractmethod
    def supports(self, pdf_path: Path) -> bool:
        """Return True iff this adapter can handle the given PDF file.

        Args:
            pdf_path: Path to the PDF file (D-064 path-safety validated by caller).

        Returns:
            True if this adapter supports extraction from the given PDF
            (e.g. digital vs scanned, PDF version compatibility).
            Used for pre-check before extract() to enable adapter-routing.

        Note:
            MUST NOT raise; return False on any uncertainty.
            Called by the CLI dispatcher before extract() to select the right adapter.
        """

    @abstractmethod
    def name(self) -> str:
        """Human-readable adapter identifier.

        Returns:
            Adapter name string (e.g. 'pdfplumber+camelot v0.10.0').
            Populates ExtractedFinancialStatement.extraction_method provenance field.
        """

    @abstractmethod
    def extractor_version(self) -> str:
        """Semver string for this adapter version.

        Returns:
            Semver string (e.g. '0.1.0').
            Populates ExtractedFinancialStatement.extractor_version provenance field.
            Used for calibration tracing when library is upgraded.
        """
