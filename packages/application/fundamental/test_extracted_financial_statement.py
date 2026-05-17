"""Tests for ExtractedFinancialStatement + PdfSource dataclasses (plan-041 D4).

Covers:
1. PdfSource frozen-dataclass immutability (raises FrozenInstanceError)
2. PdfSource path-safety enforcement (raises PdfSourceInvariantError)
3. PdfSource Rule 1 invariant (filing_date < period_end raises)
4. PdfSource source_url must start with http(s)://
5. ExtractedFinancialStatement frozen-dataclass immutability
6. ExtractedFinancialStatement raw_cells non-empty enforced
7. ExtractedFinancialStatement sha256 regex enforced (64-char hex)
8. ExtractedFinancialStatement extracted_at tz-aware (D-059 R1)
9. ExtractedFinancialStatement extraction_method non-empty
10. ExtractedFinancialStatement extractor_version non-empty
11. ExtractedFinancialStatement source_pdf_page >= 1 or None
12. Gold-set fixture SHA256 manifest validation (tests/fixtures/pdf/SHA256.txt)

Source: plan-041 § E.4 D4 Tasks 2-4
        packages/application/fundamental/pdf_source.py
        packages/application/fundamental/extracted_financial_statement.py
        agent-workspace/constitution/invariants.md (D-059 R1 datetime-tz)
"""

from __future__ import annotations

import dataclasses
import hashlib
import os
from collections.abc import Generator
from datetime import UTC, date, datetime
from pathlib import Path

import pytest

from packages.application.fundamental.extracted_financial_statement import (
    ExtractedFinancialStatement,
    ExtractedFinancialStatementInvariantError,
)
from packages.application.fundamental.pdf_source import PdfSource, PdfSourceInvariantError
from packages.contracts import Ticker
from packages.domain.fundamental.value_objects import StatementType

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_VALID_SHA256 = "a" * 64  # 64 lowercase hex chars -- valid format
_VALID_TICKER = Ticker("VHM")
_VALID_PERIOD_END = date(2023, 12, 31)
_VALID_FILING_DATE = date(2024, 4, 1)
_VALID_SOURCE_URL = "https://vinhomes.vn/annual-report-2023.pdf"
_VALID_EXTRACTION_METHOD = "pdfplumber+camelot v0.10.0"
_VALID_EXTRACTOR_VERSION = "0.1.0"
_VALID_EXTRACTED_AT = datetime(2024, 4, 15, 10, 0, 0, tzinfo=UTC)


def _make_pdf_source(pdf_path: Path, *, filing_date: date = _VALID_FILING_DATE) -> PdfSource:
    """Helper: create a valid PdfSource for testing."""
    return PdfSource(
        pdf_path=pdf_path,
        source_url=_VALID_SOURCE_URL,
        ticker=_VALID_TICKER,
        statement_type=StatementType.IS,
        period_end=_VALID_PERIOD_END,
        filing_date=filing_date,
    )


def _make_efs(
    pdf_source: PdfSource,
    *,
    raw_cells: dict[str, str] | None = None,
) -> ExtractedFinancialStatement:
    """Helper: create a valid ExtractedFinancialStatement for testing."""
    cells = {"revenue": "100,000"} if raw_cells is None else raw_cells
    return ExtractedFinancialStatement(
        pdf_source=pdf_source,
        raw_cells=cells,
        extraction_method=_VALID_EXTRACTION_METHOD,
        extractor_version=_VALID_EXTRACTOR_VERSION,
        source_pdf_page=5,
        source_pdf_sha256=_VALID_SHA256,
        extracted_at=_VALID_EXTRACTED_AT,
    )


# ---------------------------------------------------------------------------
# PdfSource tests (uses fixture PDF -- requires path-safety env override)
# ---------------------------------------------------------------------------


@pytest.fixture()
def fixture_pdf_path(tmp_path: Path) -> Generator[Path, None, None]:
    """Create a minimal PDF fixture and configure path-safety to allow it."""
    pdf_file = tmp_path / "test.pdf"
    pdf_file.write_bytes(b"%PDF-1.4\n%EOF\n")  # minimal valid PDF bytes

    # Allow tmp_path in path-safety roots (D-064 compliance for tests)
    existing = os.environ.get("STOCKFORGE_ALLOWED_FILE_ROOTS", "")
    new_roots = f"{existing},{tmp_path}" if existing else str(tmp_path)
    os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"] = new_roots
    yield pdf_file
    # Restore (partial cleanup; other tests may reset too)
    os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"] = existing


# ---------------------------------------------------------------------------
# Test 1: PdfSource frozen-dataclass immutability
# ---------------------------------------------------------------------------


def test_pdf_source_is_frozen(fixture_pdf_path: Path) -> None:
    """PdfSource is a frozen dataclass; field assignment raises FrozenInstanceError."""
    source = _make_pdf_source(fixture_pdf_path)
    with pytest.raises(dataclasses.FrozenInstanceError):
        source.ticker = Ticker("HPG")  # type: ignore[misc]


# ---------------------------------------------------------------------------
# Test 2: PdfSource path-safety enforcement
# ---------------------------------------------------------------------------


def test_pdf_source_rejects_path_outside_allowed_roots(tmp_path: Path) -> None:
    """PdfSource raises PdfSourceInvariantError if pdf_path is outside allowed roots."""
    # Use a path NOT in allowed roots (do NOT add tmp_path to env here)
    bad_path = tmp_path / "bad_dir" / "annual_report.pdf"
    bad_path.parent.mkdir(parents=True, exist_ok=True)
    bad_path.write_bytes(b"%PDF-1.4\n%EOF\n")

    # Ensure the bad_path directory is NOT in STOCKFORGE_ALLOWED_FILE_ROOTS
    existing = os.environ.get("STOCKFORGE_ALLOWED_FILE_ROOTS", "")
    # Remove bad_dir from roots if present
    filtered = ",".join(r for r in existing.split(",") if str(bad_path.parent) not in r)
    os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"] = filtered

    with pytest.raises(PdfSourceInvariantError, match="D-064 path-safety"):
        PdfSource(
            pdf_path=bad_path,
            source_url=_VALID_SOURCE_URL,
            ticker=_VALID_TICKER,
            statement_type=StatementType.BS,
            period_end=_VALID_PERIOD_END,
            filing_date=_VALID_FILING_DATE,
        )

    os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"] = existing


# ---------------------------------------------------------------------------
# Test 3: PdfSource Rule 1 invariant (filing_date < period_end raises)
# ---------------------------------------------------------------------------


def test_pdf_source_rule1_filing_before_period_raises(fixture_pdf_path: Path) -> None:
    """PdfSource raises PdfSourceInvariantError if filing_date < period_end (Rule 1)."""
    with pytest.raises(PdfSourceInvariantError, match="Rule 1"):
        _make_pdf_source(fixture_pdf_path, filing_date=date(2023, 6, 1))  # before period_end


# ---------------------------------------------------------------------------
# Test 4: PdfSource source_url must start with http(s)://
# ---------------------------------------------------------------------------


def test_pdf_source_rejects_invalid_source_url(fixture_pdf_path: Path) -> None:
    """PdfSource raises PdfSourceInvariantError if source_url is not http(s)://."""
    with pytest.raises(PdfSourceInvariantError, match="http"):
        PdfSource(
            pdf_path=fixture_pdf_path,
            source_url="ftp://invalid.example.com/report.pdf",
            ticker=_VALID_TICKER,
            statement_type=StatementType.IS,
            period_end=_VALID_PERIOD_END,
            filing_date=_VALID_FILING_DATE,
        )


# ---------------------------------------------------------------------------
# Test 5: ExtractedFinancialStatement frozen-dataclass immutability
# ---------------------------------------------------------------------------


def test_extracted_financial_statement_is_frozen(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement is frozen; field assignment raises FrozenInstanceError."""
    source = _make_pdf_source(fixture_pdf_path)
    efs = _make_efs(source)
    with pytest.raises(dataclasses.FrozenInstanceError):
        efs.extraction_method = "changed"  # type: ignore[misc]


# ---------------------------------------------------------------------------
# Test 6: ExtractedFinancialStatement raw_cells non-empty enforced
# ---------------------------------------------------------------------------


def test_extracted_financial_statement_empty_raw_cells_raises(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement raises if raw_cells is empty."""
    source = _make_pdf_source(fixture_pdf_path)
    with pytest.raises(ExtractedFinancialStatementInvariantError, match="raw_cells"):
        _make_efs(source, raw_cells={})


# ---------------------------------------------------------------------------
# Test 7: ExtractedFinancialStatement sha256 regex enforced (64-char hex)
# ---------------------------------------------------------------------------


def test_extracted_financial_statement_invalid_sha256_raises(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement raises if source_pdf_sha256 is not 64-char hex."""
    source = _make_pdf_source(fixture_pdf_path)
    with pytest.raises(ExtractedFinancialStatementInvariantError, match="sha256"):
        ExtractedFinancialStatement(
            pdf_source=source,
            raw_cells={"revenue": "100"},
            extraction_method=_VALID_EXTRACTION_METHOD,
            extractor_version=_VALID_EXTRACTOR_VERSION,
            source_pdf_page=1,
            source_pdf_sha256="not_a_valid_sha256",  # too short + invalid chars
            extracted_at=_VALID_EXTRACTED_AT,
        )


def test_extracted_financial_statement_valid_sha256_accepts(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement accepts valid 64-char lowercase hex SHA256."""
    source = _make_pdf_source(fixture_pdf_path)
    efs = _make_efs(source)  # uses _VALID_SHA256 = 'a' * 64
    assert efs.source_pdf_sha256 == "a" * 64


# ---------------------------------------------------------------------------
# Test 8: ExtractedFinancialStatement extracted_at tz-aware (D-059 R1)
# ---------------------------------------------------------------------------


def test_extracted_financial_statement_naive_datetime_raises(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement raises if extracted_at is timezone-naive (D-059 R1)."""
    source = _make_pdf_source(fixture_pdf_path)
    naive_dt = datetime(2024, 4, 15, 10, 0, 0)  # no tzinfo -- naive!
    with pytest.raises(ExtractedFinancialStatementInvariantError, match="timezone-aware"):
        ExtractedFinancialStatement(
            pdf_source=source,
            raw_cells={"revenue": "100"},
            extraction_method=_VALID_EXTRACTION_METHOD,
            extractor_version=_VALID_EXTRACTOR_VERSION,
            source_pdf_page=1,
            source_pdf_sha256=_VALID_SHA256,
            extracted_at=naive_dt,
        )


def test_extracted_financial_statement_tz_aware_accepts(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement accepts timezone-aware extracted_at."""
    source = _make_pdf_source(fixture_pdf_path)
    # Use a non-UTC timezone to confirm any tzinfo works
    efs = ExtractedFinancialStatement(
        pdf_source=source,
        raw_cells={"revenue": "100"},
        extraction_method=_VALID_EXTRACTION_METHOD,
        extractor_version=_VALID_EXTRACTOR_VERSION,
        source_pdf_page=None,
        source_pdf_sha256=_VALID_SHA256,
        extracted_at=datetime(2024, 4, 15, 17, 0, 0, tzinfo=UTC),
    )
    assert efs.extracted_at.tzinfo is not None


# ---------------------------------------------------------------------------
# Test 9: ExtractedFinancialStatement extraction_method non-empty
# ---------------------------------------------------------------------------


def test_extracted_financial_statement_empty_extraction_method_raises(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement raises if extraction_method is empty."""
    source = _make_pdf_source(fixture_pdf_path)
    with pytest.raises(ExtractedFinancialStatementInvariantError, match="extraction_method"):
        ExtractedFinancialStatement(
            pdf_source=source,
            raw_cells={"revenue": "100"},
            extraction_method="   ",  # whitespace-only
            extractor_version=_VALID_EXTRACTOR_VERSION,
            source_pdf_page=1,
            source_pdf_sha256=_VALID_SHA256,
            extracted_at=_VALID_EXTRACTED_AT,
        )


# ---------------------------------------------------------------------------
# Test 10: ExtractedFinancialStatement extractor_version non-empty
# ---------------------------------------------------------------------------


def test_extracted_financial_statement_empty_extractor_version_raises(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement raises if extractor_version is empty."""
    source = _make_pdf_source(fixture_pdf_path)
    with pytest.raises(ExtractedFinancialStatementInvariantError, match="extractor_version"):
        ExtractedFinancialStatement(
            pdf_source=source,
            raw_cells={"revenue": "100"},
            extraction_method=_VALID_EXTRACTION_METHOD,
            extractor_version="",  # empty string
            source_pdf_page=1,
            source_pdf_sha256=_VALID_SHA256,
            extracted_at=_VALID_EXTRACTED_AT,
        )


# ---------------------------------------------------------------------------
# Test 11: ExtractedFinancialStatement source_pdf_page >= 1 or None
# ---------------------------------------------------------------------------


def test_extracted_financial_statement_invalid_page_raises(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement raises if source_pdf_page is 0 or negative."""
    source = _make_pdf_source(fixture_pdf_path)
    with pytest.raises(ExtractedFinancialStatementInvariantError, match="source_pdf_page"):
        ExtractedFinancialStatement(
            pdf_source=source,
            raw_cells={"revenue": "100"},
            extraction_method=_VALID_EXTRACTION_METHOD,
            extractor_version=_VALID_EXTRACTOR_VERSION,
            source_pdf_page=0,  # 0 is invalid; pages are 1-indexed
            source_pdf_sha256=_VALID_SHA256,
            extracted_at=_VALID_EXTRACTED_AT,
        )


def test_extracted_financial_statement_none_page_accepts(fixture_pdf_path: Path) -> None:
    """ExtractedFinancialStatement accepts source_pdf_page=None (adapter doesn't track pages)."""
    source = _make_pdf_source(fixture_pdf_path)
    # Create with None page directly
    efs2 = ExtractedFinancialStatement(
        pdf_source=source,
        raw_cells={"revenue": "100"},
        extraction_method=_VALID_EXTRACTION_METHOD,
        extractor_version=_VALID_EXTRACTOR_VERSION,
        source_pdf_page=None,
        source_pdf_sha256=_VALID_SHA256,
        extracted_at=_VALID_EXTRACTED_AT,
    )
    assert efs2.source_pdf_page is None


# ---------------------------------------------------------------------------
# Test 12: Gold-set fixture SHA256 manifest validation
# ---------------------------------------------------------------------------


def _find_fixtures_dir() -> Path:
    """Locate tests/fixtures/pdf/ relative to project root."""
    # Navigate from this file's location upward to project root
    current = Path(__file__).resolve()
    for ancestor in current.parents:
        candidate = ancestor / "tests" / "fixtures" / "pdf"
        if candidate.exists():
            return candidate
    raise FileNotFoundError(
        "tests/fixtures/pdf/ not found. Run S394 IMPL to create the gold-set fixtures."
    )


def test_gold_set_fixture_sha256_manifest() -> None:
    """Gold-set fixture SHA256 manifest matches actual file SHA256s."""
    fixtures_dir = _find_fixtures_dir()
    sha_file = fixtures_dir / "SHA256.txt"

    if not sha_file.exists():
        pytest.skip("SHA256.txt manifest not found; skip gold-set manifest test")

    content = sha_file.read_text(encoding="utf-8")
    mismatches: list[str] = []

    for line in content.splitlines():
        # Skip comments and blank lines
        if not line.strip() or line.strip().startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 2:
            continue
        expected_sha = parts[0].strip()
        filename = parts[1].strip()
        if len(expected_sha) != 64 or not all(c in "0123456789abcdef" for c in expected_sha):
            continue  # Skip non-SHA lines

        pdf_path = fixtures_dir / filename
        if not pdf_path.exists():
            mismatches.append(f"MISSING: {filename}")
            continue

        actual_sha = hashlib.sha256(pdf_path.read_bytes()).hexdigest()
        if actual_sha != expected_sha:
            mismatches.append(
                f"SHA256 MISMATCH for {filename}: expected {expected_sha[:8]}... got {actual_sha[:8]}..."
            )

    if mismatches:
        pytest.fail(
            "Gold-set fixture SHA256 manifest validation failed:\n"
            + "\n".join(f"  {m}" for m in mismatches)
        )
