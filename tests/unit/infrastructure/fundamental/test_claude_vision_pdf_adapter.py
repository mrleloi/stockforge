"""Tests for ClaudeVisionPdfTableExtractor — Claude vision PDF adapter (plan-043 D1).

Covers:
  1.  V6 subclass-instantiation smoke (source_id='claude-vision'; 4 methods; no TypeError)
  2.  source_id ClassVar = "claude-vision" enforced
  3.  supports() returns True for .pdf paths, False for non-.pdf
  4.  name() returns expected format ("claude-vision vX.Y.Z")
  5.  extractor_version() returns semver string
  6.  extract() invokes claude_cli_transport (mocked subprocess)
  7.  extract() returns ExtractedFinancialStatement with extraction_method='claude-vision'
  8.  extract() populates extracted_at tz-aware (D-059 R1)
  9.  extract() populates source_pdf_sha256 from actual PDF content
 10.  extract() populates raw_cells non-empty
 11.  extract() raises CostBudgetExceeded when cumulative cost > cost_ceiling_usd
 12.  extract() raises EchoValidationError when LLM-claimed != deterministic-parsed
 13.  extract() raises VisionExtractionError on SubagentSubstrateError
 14.  extract() raises VisionExtractionError on empty cell response
 15.  ZERO import anthropic in adapter module (charter compliance check)
 16.  ctor accepts custom cost_ceiling_usd kwarg
 17.  ctor accepts custom model kwarg
 18.  call_records are populated after successful extract()
 19.  missing source_id on concrete subclass raises TypeError at class-definition time
 20.  extract() populates extractor_version = "0.1.0"

Plan:  043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md § E.4 D4
Port:  packages/application/fundamental/pdf_table_extractor_port.py (D-080 ACCEPTED)
"""

from __future__ import annotations

import ast
import importlib.util
import json
import os
import subprocess
from collections.abc import Generator
from datetime import UTC, date
from decimal import Decimal
from pathlib import Path
from unittest.mock import patch

import pytest

from packages.application.fundamental.echo_validator import EchoValidationError
from packages.application.fundamental.extracted_financial_statement import (
    ExtractedFinancialStatement,
)
from packages.application.fundamental.pdf_source import PdfSource
from packages.application.fundamental.pdf_table_extractor_port import PdfTableExtractorPort
from packages.contracts import Ticker
from packages.domain.fundamental.value_objects import StatementType
from packages.infrastructure.fundamental.claude_vision_pdf_adapter import (
    ClaudeVisionPdfTableExtractor,
    CostBudgetExceeded,
    VisionExtractionError,
)

# ── Constants ─────────────────────────────────────────────────────────────────

_VALID_SHA256 = "a" * 64
_VALID_TICKER = Ticker("VHM")
_VALID_PERIOD_END = date(2023, 12, 31)
_VALID_FILING_DATE = date(2024, 4, 1)
_VALID_SOURCE_URL = "https://vinhomes.vn/annual-report-2023.pdf"

# Minimal valid Claude CLI JSON envelope output
_CELLS_RESPONSE = json.dumps({"cells": {"revenue": "1.234.567", "eps": "12.34"}})
_CLAUDE_ENVELOPE = json.dumps(
    {
        "type": "result",
        "subtype": "success",
        "is_error": False,
        "result": _CELLS_RESPONSE,
        "usage": {
            "input_tokens": 100,
            "output_tokens": 50,
            "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": 0,
        },
        "total_cost_usd": 0.001,
    }
)

# Mismatch: LLM claims "9999999" but deterministic parse of "9999999" gives 9999999,
# which won't match Decimal("1234567"). We test this by constructing a response
# that triggers EchoValidator mismatch via a cell we can control.


# ── Fixtures ──────────────────────────────────────────────────────────────────


@pytest.fixture()
def pdf_fixture(tmp_path: Path) -> Generator[Path, None, None]:
    """Create a minimal PDF fixture and configure path-safety to allow it."""
    pdf_file = tmp_path / "test_annual.pdf"
    pdf_file.write_bytes(b"%PDF-1.4\n1 0 obj\n<</Type/Catalog/Pages 2 0 R>>\nendobj\n%%EOF")
    existing = os.environ.get("STOCKFORGE_ALLOWED_FILE_ROOTS", "")
    new_roots = f"{existing},{tmp_path}" if existing else str(tmp_path)
    os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"] = new_roots
    yield pdf_file
    os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"] = existing


@pytest.fixture()
def pdf_source(pdf_fixture: Path) -> PdfSource:
    """Create a valid PdfSource for testing."""
    return PdfSource(
        pdf_path=pdf_fixture,
        source_url=_VALID_SOURCE_URL,
        ticker=_VALID_TICKER,
        statement_type=StatementType.IS,
        period_end=_VALID_PERIOD_END,
        filing_date=_VALID_FILING_DATE,
    )


def _make_completed_process(stdout: str, returncode: int = 0) -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess(
        args=["claude"], returncode=returncode, stdout=stdout, stderr=""
    )


# ── Test 1: V6 subclass-instantiation smoke ───────────────────────────────────


def test_subclass_instantiation_no_error() -> None:
    """V6 smoke: ClaudeVisionPdfTableExtractor can be instantiated without TypeError.

    Per S397 V6 verifier pattern: concrete subclass with source_id + 4 methods
    must instantiate OK (mirrors _Stub(PdfTableExtractorPort) programmatic test).
    """
    adapter = ClaudeVisionPdfTableExtractor()
    assert adapter is not None
    assert isinstance(adapter, PdfTableExtractorPort)


def test_subclass_is_pdf_table_extractor_port() -> None:
    """ClaudeVisionPdfTableExtractor subclasses PdfTableExtractorPort."""
    assert issubclass(ClaudeVisionPdfTableExtractor, PdfTableExtractorPort)


# ── Test 2: source_id ClassVar ────────────────────────────────────────────────


def test_source_id_is_claude_vision() -> None:
    """source_id ClassVar = 'claude-vision' per D-080 __init_subclass__ contract."""
    assert ClaudeVisionPdfTableExtractor.source_id == "claude-vision"


def test_source_id_non_empty_on_class() -> None:
    """source_id is non-empty string (enforced by PdfTableExtractorPort.__init_subclass__)."""
    assert ClaudeVisionPdfTableExtractor.source_id.strip()


# ── Test 3: supports() ────────────────────────────────────────────────────────


def test_supports_pdf_extension_true() -> None:
    """supports() returns True for .pdf files."""
    adapter = ClaudeVisionPdfTableExtractor()
    assert adapter.supports(Path("/some/path/annual_report.pdf")) is True


def test_supports_non_pdf_false() -> None:
    """supports() returns False for non-.pdf files."""
    adapter = ClaudeVisionPdfTableExtractor()
    assert adapter.supports(Path("/some/path/report.xlsx")) is False


def test_supports_pdf_case_insensitive() -> None:
    """supports() handles .PDF (uppercase extension)."""
    adapter = ClaudeVisionPdfTableExtractor()
    assert adapter.supports(Path("/some/path/report.PDF")) is True


# ── Test 4: name() ────────────────────────────────────────────────────────────


def test_name_format() -> None:
    """name() returns 'claude-vision vX.Y.Z' format."""
    adapter = ClaudeVisionPdfTableExtractor()
    name = adapter.name()
    assert name.startswith("claude-vision v")
    assert "0.1.0" in name


# ── Test 5: extractor_version() ───────────────────────────────────────────────


def test_extractor_version_is_semver() -> None:
    """extractor_version() returns a semver string (X.Y.Z format)."""
    adapter = ClaudeVisionPdfTableExtractor()
    version = adapter.extractor_version()
    parts = version.split(".")
    assert len(parts) == 3
    assert all(p.isdigit() for p in parts)


def test_extractor_version_is_0_1_0() -> None:
    """extractor_version() returns '0.1.0' for initial V0 implementation."""
    adapter = ClaudeVisionPdfTableExtractor()
    assert adapter.extractor_version() == "0.1.0"


# ── Test 6: extract() invokes claude_cli_transport ───────────────────────────


def test_extract_invokes_claude_cli_transport(pdf_source: PdfSource) -> None:
    """extract() calls claude_cli_transport with correct model and system_prompt."""
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
    ) as mock_transport:
        mock_transport.return_value = (_CELLS_RESPONSE, 100, 50)
        adapter.extract(pdf_source)
    mock_transport.assert_called_once()
    _, kwargs = mock_transport.call_args
    # model kwarg
    assert kwargs.get("model") == "claude-sonnet-4-6"
    # user_message should contain @<pdf_path>
    user_msg = kwargs.get("user_message", "")
    assert "@" in user_msg


# ── Test 7: extract() returns ExtractedFinancialStatement ────────────────────


def test_extract_returns_extracted_financial_statement(pdf_source: PdfSource) -> None:
    """extract() returns ExtractedFinancialStatement with correct extraction_method."""
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100, 50),
    ):
        result = adapter.extract(pdf_source)
    assert isinstance(result, ExtractedFinancialStatement)
    assert result.extraction_method == "claude-vision v0.1.0"


# ── Test 8: extracted_at tz-aware (D-059 R1) ─────────────────────────────────


def test_extract_extracted_at_tz_aware(pdf_source: PdfSource) -> None:
    """extract() sets extracted_at to a tz-aware datetime (D-059 R1)."""
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100, 50),
    ):
        result = adapter.extract(pdf_source)
    assert result.extracted_at.tzinfo is not None
    assert result.extracted_at.tzinfo == UTC


# ── Test 9: source_pdf_sha256 from actual PDF ─────────────────────────────────


def test_extract_source_pdf_sha256_is_64_hex(pdf_source: PdfSource) -> None:
    """extract() sets source_pdf_sha256 to a valid 64-char lowercase hex SHA-256."""
    import re
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100, 50),
    ):
        result = adapter.extract(pdf_source)
    assert re.match(r"^[0-9a-f]{64}$", result.source_pdf_sha256)


# ── Test 10: raw_cells non-empty ─────────────────────────────────────────────


def test_extract_raw_cells_non_empty(pdf_source: PdfSource) -> None:
    """extract() returns non-empty raw_cells dict."""
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100, 50),
    ):
        result = adapter.extract(pdf_source)
    assert len(result.raw_cells) > 0


# ── Test 11: CostBudgetExceeded ───────────────────────────────────────────────


def test_extract_raises_cost_budget_exceeded(pdf_source: PdfSource) -> None:
    """extract() raises CostBudgetExceeded when cost exceeds cost_ceiling_usd."""
    # Set very low ceiling (1 micro-dollar) to trigger immediately
    adapter = ClaudeVisionPdfTableExtractor(cost_ceiling_usd=Decimal("0.000001"))
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100_000, 50_000),  # high token counts
    ), pytest.raises(CostBudgetExceeded) as exc_info:
        adapter.extract(pdf_source)
    assert exc_info.value.actual_cost > exc_info.value.ceiling


# ── Test 12: EchoValidationError propagates ──────────────────────────────────


def test_extract_propagates_echo_validation_error(pdf_source: PdfSource) -> None:
    """extract() propagates EchoValidationError when LLM-claimed != deterministic-parsed.

    We inject a response where the cell value is a valid number but different from
    what the deterministic re-parser would compute. This is achieved by giving
    a non-numeric cell (that passes empty-value guard) — but actually we test
    that a value like '1000' matched against a response of '9999' would fail.

    Strategy: mock the EchoValidator.validate to raise EchoValidationError.
    """
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100, 50),
    ), patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.EchoValidator.validate",
        side_effect=EchoValidationError("revenue", "1.234.567", Decimal("9999999")),
    ), pytest.raises(EchoValidationError):
        adapter.extract(pdf_source)


# ── Test 13: VisionExtractionError on SubagentSubstrateError ──────────────────


def test_extract_raises_vision_error_on_substrate_failure(pdf_source: PdfSource) -> None:
    """extract() wraps SubagentSubstrateError in VisionExtractionError."""
    from packages.infrastructure.analysis.subagent_transport import SubagentSubstrateError

    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        side_effect=SubagentSubstrateError("claude CLI not found"),
    ), pytest.raises(VisionExtractionError):
        adapter.extract(pdf_source)


# ── Test 14: VisionExtractionError on empty cells ────────────────────────────


def test_extract_raises_vision_error_on_empty_cells(pdf_source: PdfSource) -> None:
    """extract() raises VisionExtractionError when response contains zero cells."""
    empty_response = json.dumps({"cells": {}})
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(empty_response, 10, 5),
    ), pytest.raises(VisionExtractionError):
        adapter.extract(pdf_source)


# ── Test 15: ZERO import anthropic (charter compliance) ───────────────────────


def test_zero_import_anthropic_in_adapter() -> None:
    """CHARTER COMPLIANCE: adapter module must not import anthropic (D-050).

    Per plan-043 DoD: 'ZERO import anthropic in adapter module'.
    Verified via AST parse of the source file (deterministic; not import-side-effect).
    """
    spec = importlib.util.find_spec("packages.infrastructure.fundamental.claude_vision_pdf_adapter")
    assert spec is not None and spec.origin is not None, "Adapter module not found"
    source = Path(spec.origin).read_text(encoding="utf-8")
    tree = ast.parse(source)
    for node in ast.walk(tree):
        if isinstance(node, (ast.Import, ast.ImportFrom)):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    assert "anthropic" not in alias.name, (
                        f"CHARTER VIOLATION: 'import {alias.name}' in adapter "
                        f"(D-050 anthropic_api_to_subagent MANDATORY)"
                    )
            elif isinstance(node, ast.ImportFrom):
                module = node.module or ""
                assert "anthropic" not in module, (
                    f"CHARTER VIOLATION: 'from {module} import ...' in adapter "
                    f"(D-050 anthropic_api_to_subagent MANDATORY)"
                )


# ── Test 16: ctor accepts custom cost_ceiling_usd ────────────────────────────


def test_ctor_custom_cost_ceiling() -> None:
    """ctor accepts custom cost_ceiling_usd kwarg (DD-6 configurable ceiling)."""
    adapter = ClaudeVisionPdfTableExtractor(cost_ceiling_usd=Decimal("2.00"))
    assert adapter._cost_ceiling_usd == Decimal("2.00")


# ── Test 17: ctor accepts custom model kwarg ─────────────────────────────────


def test_ctor_custom_model() -> None:
    """ctor accepts custom model kwarg for Opus vs Sonnet selection."""
    adapter = ClaudeVisionPdfTableExtractor(model="claude-opus-4-7")
    assert adapter._model == "claude-opus-4-7"


# ── Test 18: call_records populated after extract ─────────────────────────────


def test_call_records_populated_after_extract(pdf_source: PdfSource) -> None:
    """call_records contain one record per successful extract() call."""
    adapter = ClaudeVisionPdfTableExtractor()
    assert len(adapter.call_records) == 0
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100, 50),
    ):
        adapter.extract(pdf_source)
    assert len(adapter.call_records) == 1
    record = adapter.call_records[0]
    assert record.input_tokens == 100
    assert record.output_tokens == 50
    assert record.cells_extracted > 0


# ── Test 19: missing source_id raises TypeError at class-definition ────────────


def test_missing_source_id_raises_type_error() -> None:
    """Concrete subclass without source_id raises TypeError at definition time.

    Per PdfTableExtractorPort.__init_subclass__ (pdf_table_extractor_port.py:111-131).
    """
    with pytest.raises(TypeError, match="source_id"):
        # This class definition itself triggers __init_subclass__ → TypeError
        exec(
            "from packages.application.fundamental.pdf_table_extractor_port import PdfTableExtractorPort\n"
            "class _NoSourceId(PdfTableExtractorPort):\n"
            "    def extract(self, pdf_source): ...\n"
            "    def supports(self, path): return True\n"
            "    def name(self): return 'x'\n"
            "    def extractor_version(self): return '0.0.1'\n"
        )


# ── Test 20: extractor_version propagates to ExtractedFinancialStatement ──────


def test_extractor_version_in_result(pdf_source: PdfSource) -> None:
    """extract() sets extractor_version = '0.1.0' in returned ExtractedFinancialStatement."""
    adapter = ClaudeVisionPdfTableExtractor()
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(_CELLS_RESPONSE, 100, 50),
    ):
        result = adapter.extract(pdf_source)
    assert result.extractor_version == "0.1.0"
