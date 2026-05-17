"""Tests for PdfTableExtractorPort ABC + error hierarchy (plan-041 D4).

Covers:
1. __init_subclass__ raises TypeError on empty source_id (firing-test)
2. __init_subclass__ raises TypeError on missing source_id ClassVar
3. Cannot instantiate PdfTableExtractorPort directly (abstract methods block it)
4. Subclass with all 4 abstract methods + source_id instantiates successfully
5. PdfTableExtractorError + PdfTableExtractorOptionalDepError hierarchy

Source: plan-041 § E.4 D4 Tasks 1-5
        packages/application/news/ports/test_crawler_adapter.py (shape mirror)
        packages/application/fundamental/pdf_table_extractor_port.py
"""

from __future__ import annotations

from pathlib import Path

import pytest

from packages.application.fundamental.pdf_table_extractor_port import (
    PdfTableExtractorError,
    PdfTableExtractorOptionalDepError,
    PdfTableExtractorPort,
)

if False:  # TYPE_CHECKING equivalent for avoiding import at runtime
    from packages.application.fundamental.extracted_financial_statement import (
        ExtractedFinancialStatement,
    )
    from packages.application.fundamental.pdf_source import PdfSource


# ---------------------------------------------------------------------------
# Concrete test adapter (valid)
# ---------------------------------------------------------------------------


class _ValidAdapter(PdfTableExtractorPort):
    """Valid concrete adapter for testing."""

    source_id = "test_pdfplumber"

    def extract(self, pdf_source: PdfSource) -> ExtractedFinancialStatement:
        raise NotImplementedError

    def supports(self, pdf_path: Path) -> bool:
        return pdf_path.suffix.lower() == ".pdf"

    def name(self) -> str:
        return "test_pdfplumber v0.1.0"

    def extractor_version(self) -> str:
        return "0.1.0"


# ---------------------------------------------------------------------------
# Test 1: __init_subclass__ raises TypeError on missing source_id
# ---------------------------------------------------------------------------


def test_subclass_missing_source_id_raises_type_error_at_definition() -> None:
    """A subclass that declares no source_id raises TypeError at class-definition time."""
    with pytest.raises(TypeError, match="must declare a non-empty source_id"):

        class _MissingId(PdfTableExtractorPort):  # TypeError fires here
            def extract(self, pdf_source: PdfSource) -> ExtractedFinancialStatement:
                raise NotImplementedError

            def supports(self, _pdf_path: Path) -> bool:
                return False

            def name(self) -> str:
                return "missing"

            def extractor_version(self) -> str:
                return "0.0.0"


# ---------------------------------------------------------------------------
# Test 2: __init_subclass__ raises TypeError on empty / whitespace-only source_id
# ---------------------------------------------------------------------------


def test_subclass_with_empty_source_id_raises_type_error() -> None:
    """A subclass with source_id = '' raises TypeError at class-definition time."""
    with pytest.raises(TypeError, match="must declare a non-empty source_id"):

        class _EmptyId(PdfTableExtractorPort):
            source_id = "   "  # whitespace-only; .strip() == "" -> rejected

            def extract(self, pdf_source: PdfSource) -> ExtractedFinancialStatement:
                raise NotImplementedError

            def supports(self, _pdf_path: Path) -> bool:
                return False

            def name(self) -> str:
                return "empty"

            def extractor_version(self) -> str:
                return "0.0.0"


# ---------------------------------------------------------------------------
# Test 3: Cannot instantiate PdfTableExtractorPort directly
# ---------------------------------------------------------------------------


def test_pdf_table_extractor_port_cannot_be_instantiated_directly() -> None:
    """PdfTableExtractorPort ABC cannot be instantiated -- abstract methods block it."""
    with pytest.raises(TypeError, match="Can't instantiate abstract class"):
        PdfTableExtractorPort()  # type: ignore[abstract]


# ---------------------------------------------------------------------------
# Test 4: Subclass with all 4 abstract methods + source_id instantiates successfully
# ---------------------------------------------------------------------------


def test_subclass_with_valid_source_id_instantiates() -> None:
    """A subclass with a non-empty source_id and all 4 methods instantiates without error."""
    adapter = _ValidAdapter()
    assert adapter.source_id == "test_pdfplumber"
    assert adapter.name() == "test_pdfplumber v0.1.0"
    assert adapter.extractor_version() == "0.1.0"
    assert adapter.supports(Path("test.pdf")) is True
    assert adapter.supports(Path("test.xlsx")) is False


# ---------------------------------------------------------------------------
# Test 5: source_id accessible on class and instance
# ---------------------------------------------------------------------------


def test_source_id_accessible_on_class_and_instance() -> None:
    """source_id is accessible both as class attribute and instance attribute."""
    assert _ValidAdapter.source_id == "test_pdfplumber"
    assert _ValidAdapter().source_id == "test_pdfplumber"


# ---------------------------------------------------------------------------
# Test 6: PdfTableExtractorError is a subclass of Exception
# ---------------------------------------------------------------------------


def test_pdf_table_extractor_error_is_exception() -> None:
    """PdfTableExtractorError subclasses Exception (base error hierarchy)."""
    err = PdfTableExtractorError("parse failed")
    assert isinstance(err, Exception)
    assert str(err) == "parse failed"


# ---------------------------------------------------------------------------
# Test 7: PdfTableExtractorOptionalDepError is PdfTableExtractorError + ImportError
# ---------------------------------------------------------------------------


def test_pdf_table_extractor_optional_dep_error_hierarchy() -> None:
    """PdfTableExtractorOptionalDepError subclasses both PdfTableExtractorError and ImportError."""
    err = PdfTableExtractorOptionalDepError("pdfplumber not installed")
    assert isinstance(err, PdfTableExtractorError)
    assert isinstance(err, ImportError)
    assert isinstance(err, Exception)


# ---------------------------------------------------------------------------
# Test 8: __init_subclass__ enforces at DEFINITION TIME (not instantiation time)
# ---------------------------------------------------------------------------


def test_init_subclass_fires_at_class_definition_not_instantiation() -> None:
    """TypeError fires at class-definition, not at instantiation of a valid class."""
    # _ValidAdapter was defined at module level without raising -- proves D-time enforcement.
    # Just instantiate it here to confirm no TypeError at instantiation time.
    adapter = _ValidAdapter()
    assert adapter is not None
