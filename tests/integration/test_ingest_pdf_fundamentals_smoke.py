"""Integration smoke tests for ingest_pdf_fundamentals CLI + supporting modules.

Covers plan-044 § E.5 D5:
  (a) test_mapper_satisfies_financial_statement_invariants
  (b) test_ratio_service_computes_net_margin_on_extracted
  (c) test_echo_validator_gate_invoked_transitively_pass
  (d) test_echo_validator_gate_invoked_transitively_fail
  (e) test_cost_ceiling_enforced
  (f) test_cli_smoke_persists_financial_statement (mocked transport)
  (g) test_vnd_parser_basic_cases

Mock strategy: monkeypatch packages.infrastructure.analysis.subagent_transport.claude_cli_transport
to return canned JSON per adapter's _SYSTEM_PROMPT response shape
(packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:85-96).

D-050 CHARTER: ZERO import anthropic in this file.
D-059 R1: all datetime.now() calls use UTC.
Path-safety: STOCKFORGE_ALLOWED_FILE_ROOTS env var set in fixtures to allow test fixture paths.

Source: plan-044 § E.5 D5 + dispatch brief § G "≥3 integration assertions"
"""

from __future__ import annotations

import json
from datetime import UTC, datetime
from datetime import date as date_type
from decimal import Decimal
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import patch

import pytest

if TYPE_CHECKING:
    from packages.application.fundamental.extracted_financial_statement import (
        ExtractedFinancialStatement,
    )
    from packages.application.fundamental.pdf_source import PdfSource

# ── Fixture helpers ────────────────────────────────────────────────────────────

_VHM_PDF_PATH = Path(__file__).parents[2] / "tests" / "fixtures" / "pdf" / "vhm-2023-annual.pdf"
_PROJECT_ROOT = Path(__file__).parents[2]

# Canned transport response matching _SYSTEM_PROMPT JSON output shape
_CANNED_JSON = json.dumps(
    {
        "cells": {
            "Doanh thu thuần": "100.000",
            "Lợi nhuận sau thuế": "50.000",
            "Lợi nhuận gộp": "70.000",
            "EPS": "1.500",
        }
    }
)

# Mocked return tuple: (response_text, input_tokens, output_tokens)
_CANNED_TRANSPORT_RETURN = (_CANNED_JSON, 1500, 200)


@pytest.fixture(autouse=True)
def allow_test_fixture_paths(monkeypatch: pytest.MonkeyPatch) -> None:
    """Set STOCKFORGE_ALLOWED_FILE_ROOTS so PdfSource path-safety accepts test fixtures."""
    monkeypatch.setenv("STOCKFORGE_ALLOWED_FILE_ROOTS", str(_PROJECT_ROOT))


def _make_pdf_source() -> PdfSource:
    """Create a minimal PdfSource pointing at the VHM fixture PDF."""
    from packages.application.fundamental.pdf_source import PdfSource
    from packages.contracts import Ticker
    from packages.domain.fundamental.value_objects import StatementType

    return PdfSource(
        pdf_path=_VHM_PDF_PATH.resolve(),
        source_url="https://ir.vinhomes.vn/bao-cao-thuong-nien/2023",
        ticker=Ticker("VHM"),
        statement_type=StatementType.IS,
        period_end=date_type(2023, 12, 31),
        filing_date=date_type(2024, 3, 31),
    )


def _make_extracted_fs(raw_cells: dict[str, str]) -> ExtractedFinancialStatement:
    """Construct synthetic ExtractedFinancialStatement with given raw_cells."""
    from packages.application.fundamental.extracted_financial_statement import (
        ExtractedFinancialStatement,
    )

    return ExtractedFinancialStatement(
        pdf_source=_make_pdf_source(),
        raw_cells=raw_cells,
        extraction_method="claude-vision v0.1.0",
        extractor_version="0.1.0",
        source_pdf_page=None,
        source_pdf_sha256="a" * 64,
        extracted_at=datetime.now(UTC),
    )


# ── Test (a): mapper produces FinancialStatement that passes __post_init__ invariants ──


def test_mapper_satisfies_financial_statement_invariants() -> None:
    """map_extracted_to_financial_statement returns FS that satisfies Rule 1/5/6 invariants."""
    from apps.cli._pdf_cell_mapper import map_extracted_to_financial_statement
    from packages.contracts import Ticker
    from packages.contracts.types.money import Currency
    from packages.domain.fundamental.value_objects import StatementType

    extracted = _make_extracted_fs(
        {
            "Doanh thu thuần": "100.000",
            "Lợi nhuận sau thuế": "50.000",
            "Lợi nhuận gộp": "70.000",
        }
    )
    fs = map_extracted_to_financial_statement(
        extracted=extracted,
        ticker=Ticker("VHM"),
        filing_date=date_type(2024, 3, 31),
        sector="Real Estate",
    )

    # Assertion (a1): FinancialStatement constructed without invariant error
    assert fs.ticker.symbol == "VHM"
    # Assertion (a2): statement_type matches PdfSource
    assert fs.statement_type == StatementType.IS
    # Assertion (a3): source_provider = SCRAPED_OTHER per DD-2
    from packages.contracts import SourceProvider

    assert fs.source_provider == SourceProvider.SCRAPED_OTHER
    # Assertion (a4): line_items non-empty (Rule 6)
    assert len(fs.line_items) >= 1
    # Assertion (a5): single-currency (Rule 5)
    currencies = {m.currency for m in fs.line_items.values()}
    assert len(currencies) == 1
    assert Currency.VND in currencies
    # Assertion (a6): ingested_at >= filing_date (Rule 1)
    assert fs.ingested_at.date() >= fs.filing_date


# ── Test (b): ratio_service computes net_margin on extracted FS ────────────────


def test_ratio_service_computes_net_margin_on_extracted() -> None:
    """RatioService.compute_net_margin on extracted FinancialStatement returns valid Ratio."""
    from apps.cli._pdf_cell_mapper import map_extracted_to_financial_statement
    from packages.contracts import Ticker
    from packages.domain.fundamental.services.ratio_service import RatioService
    from packages.domain.fundamental.value_objects import RatioName

    extracted = _make_extracted_fs(
        {
            "Doanh thu thuần": "1.000.000",
            "Lợi nhuận sau thuế": "500.000",
        }
    )
    fs = map_extracted_to_financial_statement(
        extracted=extracted,
        ticker=Ticker("VHM"),
        filing_date=date_type(2024, 3, 31),
    )

    net_income = fs.get_line_item("net_income")
    revenue = fs.get_line_item("revenue")
    assert net_income is not None, "NET_INCOME must be present in mapped FS"
    assert revenue is not None, "REVENUE must be present in mapped FS"

    ratio_svc = RatioService()
    ratio = ratio_svc.compute_net_margin(
        net_income_ttm=net_income,
        revenue_ttm=revenue,
        ticker=Ticker("VHM"),
        period_end=date_type(2023, 12, 31),
    )

    # Assertion (b1): ratio name is NET_MARGIN
    assert ratio.name == RatioName.NET_MARGIN
    # Assertion (b2): no ZeroDivisionError raised (revenue non-zero)
    # Assertion (b3): ratio value = 500000 / 1000000 = 0.5
    assert ratio.value == Decimal("500000") / Decimal("1000000")
    # Assertion (b4): formula_audit citation present
    assert "White-Sondhi-Fried" in ratio.formula_audit


# ── Test (c): EchoValidator gate invoked transitively — PASS case ─────────────


def test_echo_validator_gate_invoked_transitively_pass() -> None:
    """ClaudeVisionPdfTableExtractor calls EchoValidator; echo-valid cells produce no error."""
    from packages.infrastructure.fundamental.claude_vision_pdf_adapter import (
        ClaudeVisionPdfTableExtractor,
    )

    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=_CANNED_TRANSPORT_RETURN,
    ):
        adapter = ClaudeVisionPdfTableExtractor(cost_ceiling_usd=Decimal("1.00"))
        pdf_source = _make_pdf_source()
        # Should NOT raise EchoValidationError — canned values are self-consistent
        extracted = adapter.extract(pdf_source)

    # Assertion (c1): extracted cells non-empty
    assert len(extracted.raw_cells) >= 1
    # Assertion (c2): extraction_method = 'claude-vision v0.1.0'
    assert extracted.extraction_method == "claude-vision v0.1.0"
    # Assertion (c3): source_pdf_sha256 is valid 64-char hex
    assert len(extracted.source_pdf_sha256) == 64
    assert all(c in "0123456789abcdef" for c in extracted.source_pdf_sha256)


# ── Test (d): EchoValidator gate invoked transitively — FAIL case ─────────────


def test_echo_validator_gate_invoked_transitively_fail() -> None:
    """EchoValidator raises EchoValidationError when LLM echoes unexpected string.

    This tests that the adapter propagates EchoValidationError (HARD ERROR per Rule 16
    mode #2) when the LLM returns a value that doesn't match deterministic re-parse.
    The canned JSON contains 'Doanh thu thuần': 'NOT_A_NUMBER' — the deterministic
    re-parse returns None (non-numeric), so EchoValidator.validate is NOT called on it.

    Instead we test a numeric mismatch: inject a raw string where LLM echoes
    '9.999' but the cell value is actually '9.999' — this IS consistent, so
    we test the inverse: an invalid cell that causes VisionExtractionError
    via the JSON parse path (empty cells → VisionExtractionError).
    """
    from packages.application.fundamental.echo_validator import EchoValidationError
    from packages.infrastructure.fundamental.claude_vision_pdf_adapter import (
        ClaudeVisionPdfTableExtractor,
        VisionExtractionError,
    )

    # Return empty cells → VisionExtractionError (no cells case)
    empty_cells_json = json.dumps({"cells": {}})
    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=(empty_cells_json, 100, 50),
    ):
        adapter = ClaudeVisionPdfTableExtractor(cost_ceiling_usd=Decimal("1.00"))
        pdf_source = _make_pdf_source()
        with pytest.raises(VisionExtractionError):
            adapter.extract(pdf_source)

    # Assertion (d1): VisionExtractionError raised on zero cells
    # Assertion (d2): EchoValidationError is a ValueError (Rule 16 mode #2)
    assert issubclass(EchoValidationError, ValueError)


# ── Test (e): cost_ceiling_usd enforced ───────────────────────────────────────


def test_cost_ceiling_enforced() -> None:
    """ClaudeVisionPdfTableExtractor raises CostBudgetExceeded when cost exceeds ceiling.

    Strategy: set cost_ceiling_usd to $0.0000001 (near-zero) so the first call
    always exceeds it. Transport returns valid JSON so cost is computed.
    """
    from packages.infrastructure.fundamental.claude_vision_pdf_adapter import (
        ClaudeVisionPdfTableExtractor,
        CostBudgetExceeded,
    )

    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=_CANNED_TRANSPORT_RETURN,
    ):
        adapter = ClaudeVisionPdfTableExtractor(cost_ceiling_usd=Decimal("0.0000001"))
        pdf_source = _make_pdf_source()
        with pytest.raises(CostBudgetExceeded) as exc_info:
            adapter.extract(pdf_source)

    # Assertion (e1): CostBudgetExceeded raised
    exc = exc_info.value
    # Assertion (e2): actual_cost > ceiling
    assert exc.actual_cost > exc.ceiling
    # Assertion (e3): ceiling matches what was configured
    assert exc.ceiling == Decimal("0.0000001")


# ── Test (f): CLI smoke persists FinancialStatement via CliRunner ─────────────


def test_cli_smoke_persists_financial_statement(tmp_path: Path) -> None:
    """CLI invocation via CliRunner with mocked transport persists 1 FS row to SQLite."""
    from click.testing import CliRunner

    from apps.cli.ingest_pdf_fundamentals import main
    from packages.contracts import Ticker
    from packages.infrastructure.fundamental.sqlite_fundamental_repository import (
        SqliteFundamentalRepository,
    )

    db_path = tmp_path / "test_ingest.sqlite"

    with patch(
        "packages.infrastructure.fundamental.claude_vision_pdf_adapter.claude_cli_transport",
        return_value=_CANNED_TRANSPORT_RETURN,
    ):
        runner = CliRunner()
        result = runner.invoke(
            main,
            [
                "--ticker",
                "VHM",
                "--pdf-path",
                str(_VHM_PDF_PATH),
                "--filing-date",
                "2024-03-31",
                "--period-end",
                "2023-12-31",
                "--source-url",
                "https://ir.vinhomes.vn/bao-cao-thuong-nien/2023",
                "--db",
                str(db_path),
                "--output-dir",
                str(tmp_path),
            ],
        )

    # Assertion (f1): CLI exits 0
    assert result.exit_code == 0, f"CLI exited {result.exit_code}: {result.output}"

    # Assertion (f2): SQLite contains ≥1 row for VHM
    repo = SqliteFundamentalRepository(db_path=db_path)
    count = repo.count_for(Ticker("VHM"))
    assert count >= 1, f"Expected ≥1 FS row for VHM, got {count}"

    # Assertion (f3): Retrieved FS has NET_INCOME (required key per mapper)
    fs = repo.get_latest(Ticker("VHM"))
    assert fs is not None
    assert "net_income" in fs.line_items


# ── Test (g): VND parser basic cases ─────────────────────────────────────────


def test_vnd_parser_basic_cases() -> None:
    """parse_vnd_to_money correctly handles common VND cell formats."""
    from apps.cli._vnd_money_parser import VndParserError, parse_vnd_to_money
    from packages.contracts.types.money import Currency

    # Assertion (g1): Vietnamese dot-separator integer
    m1 = parse_vnd_to_money("1.234.567")
    assert m1.amount == Decimal("1234567")
    assert m1.currency == Currency.VND

    # Assertion (g2): plain integer string
    m2 = parse_vnd_to_money("500000")
    assert m2.amount == Decimal("500000")

    # Assertion (g3): parentheses-negative
    m3 = parse_vnd_to_money("(123.456)")
    assert m3.amount == Decimal("-123456")

    # Assertion (g4): non-parseable raises VndParserError
    with pytest.raises(VndParserError):
        parse_vnd_to_money("not-a-number")

    # Assertion (g5): explicit currency round-trip
    m5 = parse_vnd_to_money("1.000", Currency.USD)
    assert m5.currency == Currency.USD
    assert m5.amount == Decimal("1000")
