"""ClaudeVisionPdfTableExtractor — PDF table extractor using Claude vision via CLI substrate.

Subclasses PdfTableExtractorPort (D-080 ACCEPTED) to implement LLM-assisted PDF
table OCR using the existing claude_cli_transport substrate (D-050 MANDATORY —
ZERO direct anthropic SDK; subscription billing only).

Vision-input shape: Resolution B — @<path> syntax in user_message (per STEP 0.4
cold-probe S399: claude CLI reads files via filesystem access when path is prefixed
with @ in user_message; confirmed for both PNG and PDF inputs).

MUST:
  - Subclass PdfTableExtractorPort; declare source_id = "claude-vision"
  - Use claude_cli_transport from packages/infrastructure/analysis/subagent_transport
    for ALL LLM calls (D-050 CHARTER BINDING; ZERO import anthropic)
  - Invoke EchoValidator.validate() on each extracted cell (Rule 16 mode #2 gate;
    financial-data-protocol.md:396-402)
  - Populate ExtractedFinancialStatement with extraction_method='claude-vision' +
    extractor_version semver + source_pdf_sha256 + extracted_at tz-aware (D-059 R1)

MUST NOT:
  - Import anthropic or reference ANTHROPIC_API_KEY (D-050 CHARTER)
  - Silently coerce LLM-claimed numeric values (Rule 16 mode #2 HARD ERROR)
  - Add pyproject.toml deps (DD-8 — claude CLI is system-installed)

Architecture:
  - Port:    packages/application/fundamental/pdf_table_extractor_port.py (D-080)
  - Adapter: THIS FILE (infrastructure layer per architecture.md § BC-2)
  - Transport: packages/infrastructure/analysis/subagent_transport.py (D-072 BC-5 precedent)

ADR:   D-082 PROPOSED (agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md)
Plan:  agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md § E.1 D1
"""

from __future__ import annotations

import hashlib
import json
import logging
import re
from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path
from typing import ClassVar

from packages.application.fundamental.echo_validator import EchoValidator
from packages.application.fundamental.extracted_financial_statement import (
    ExtractedFinancialStatement,
)
from packages.application.fundamental.pdf_source import PdfSource
from packages.application.fundamental.pdf_table_extractor_port import (
    PdfTableExtractorError,
    PdfTableExtractorPort,
)
from packages.infrastructure.analysis.subagent_transport import (
    SubagentSubstrateError,
    claude_cli_transport,
)

__all__ = [
    "ClaudeVisionPdfTableExtractor",
    "CostBudgetExceeded",
    "VisionExtractionError",
]

log = logging.getLogger(__name__)

# Cost per million tokens (USD) — mirrors claude_llm_perspective_adapter.py rates.
# These are used to estimate per-call cost when total_cost_usd is not available.
# In practice, claude_cli_transport returns CLI-reported total_cost_usd (more accurate).
_COST_PER_MTOK: dict[str, dict[str, Decimal]] = {
    "claude-sonnet-4-6": {
        "input": Decimal("3.00"),
        "output": Decimal("15.00"),
    },
    "claude-opus-4-7": {
        "input": Decimal("15.00"),
        "output": Decimal("75.00"),
    },
}
_DEFAULT_MODEL_RATES = _COST_PER_MTOK["claude-sonnet-4-6"]

# System prompt for vision OCR extraction.
# Instructs Claude to read the PDF and extract financial table cells as JSON.
_SYSTEM_PROMPT = (
    "You are a financial document OCR assistant for Vietnamese stock market annual reports. "
    "Your task is to read a PDF financial statement and extract ALL numeric values from "
    "financial tables (Income Statement, Balance Sheet, or Cash Flow Statement). "
    "Output a JSON object with cell labels as keys and the EXACT raw string values as "
    "you read them from the document (including units like 'Triệu đồng' or 'Tỷ đồng' "
    "if present). Do NOT compute, derive, or modify any numbers. "
    "Output ONLY valid JSON in this format: "
    '{\"cells\": {\"<label>\": \"<raw_value_string>\", ...}}. '
    "Preserve all formatting including thousand-separators and unit suffixes exactly "
    "as they appear in the document."
)


class CostBudgetExceeded(PdfTableExtractorError):
    """Raised when cumulative extraction cost exceeds cost_ceiling_usd.

    Per DD-6: per-call cost ceiling = Decimal("0.50") USD configurable via ctor.
    Prevents runaway cost in pathological cases (very long LLM responses).

    Fields:
        actual_cost: Total cost incurred so far (Decimal, USD).
        ceiling: Configured ceiling (Decimal, USD).
    """

    def __init__(self, actual_cost: Decimal, ceiling: Decimal) -> None:
        self.actual_cost = actual_cost
        self.ceiling = ceiling
        super().__init__(
            f"PDF extraction cost ${actual_cost} exceeded ceiling ${ceiling} "
            f"(DD-6 per-call cost ceiling; configure via cost_ceiling_usd ctor kwarg)"
        )


class VisionExtractionError(PdfTableExtractorError):
    """Raised when Claude vision fails to extract or parse cells from a PDF.

    Wraps SubagentSubstrateError, JSON parse failures, and other vision-path errors.
    Callers can catch this to route to a fallback adapter.
    """


def _compute_cost(model: str, input_tokens: int, output_tokens: int) -> Decimal:
    """Deterministic cost computation from token counts. No LLM math — pure arithmetic."""
    rates = _COST_PER_MTOK.get(model, _DEFAULT_MODEL_RATES)
    return (
        rates["input"] * Decimal(input_tokens) / Decimal("1_000_000")
        + rates["output"] * Decimal(output_tokens) / Decimal("1_000_000")
    )


@dataclass
class _CallRecord:
    """Per-call cost + metadata record for I-S20 calibration telemetry."""

    cells_extracted: int
    input_tokens: int
    output_tokens: int
    cost_usd: Decimal
    wall_ms: int


class ClaudeVisionPdfTableExtractor(PdfTableExtractorPort):
    """Claude vision-based PDF table extractor for VN financial statement PDFs.

    Uses claude_cli_transport (D-050 substrate; ZERO anthropic SDK) with
    Resolution B: @<pdf_path> syntax in user_message passes the PDF file to
    Claude's filesystem access capability for direct PDF reading.

    The extract() method:
    1. Reads the PDF via claude_cli_transport with @<path> in user_message.
    2. Parses the JSON response to get raw cell strings.
    3. For each cell, deterministically re-parses the raw string to Decimal.
    4. Invokes EchoValidator.validate() — HARD ERROR if LLM-claimed != deterministic.
    5. Accumulates per-call cost; raises CostBudgetExceeded if ceiling exceeded.
    6. Returns ExtractedFinancialStatement with full provenance.

    Per DD-6: default cost_ceiling_usd = Decimal("0.50") USD (configurable via ctor).
    This prevents runaway for long model responses or many-page PDFs.

    Source: plan-043 § E.1 D1 + DD-1 + DD-2 + DD-6.
    """

    source_id: ClassVar[str] = "claude-vision"

    def __init__(
        self,
        *,
        cost_ceiling_usd: Decimal = Decimal("0.50"),
        model: str = "claude-sonnet-4-6",
    ) -> None:
        """Initialise the ClaudeVisionPdfTableExtractor.

        Args:
            cost_ceiling_usd: Maximum total cost per extract() call (Decimal, USD).
                Default 0.50 USD per DD-6. Raises CostBudgetExceeded if exceeded.
            model: Claude model ID to use for vision OCR.
                Default 'claude-sonnet-4-6' (Sonnet for cost-efficiency; configurable
                to 'claude-opus-4-7' for higher-quality OCR on complex tables).
        """
        self._cost_ceiling_usd = cost_ceiling_usd
        self._model = model
        self._call_records: list[_CallRecord] = []

    def extract(self, pdf_source: PdfSource) -> ExtractedFinancialStatement:
        """Extract financial statement cells from a PDF source via Claude vision.

        Resolution B: @<path> syntax in user_message. Claude CLI reads the PDF
        via filesystem access when user_message contains '@<absolute_path>'.

        Args:
            pdf_source: Encapsulates PDF path + provenance metadata.

        Returns:
            ExtractedFinancialStatement with raw_cells from Claude vision OCR,
            validated by EchoValidator.validate() for each cell (Rule 16 mode #2).

        Raises:
            VisionExtractionError: If claude_cli_transport fails or response
                cannot be parsed as valid JSON with a "cells" dict.
            EchoValidationError: HARD ERROR if any cell's LLM-claimed value
                mismatches the deterministic re-parse (Rule 16 mode #2).
            CostBudgetExceeded: If cumulative call cost exceeds cost_ceiling_usd.
            PdfTableExtractorError: Base class for other extraction failures.
        """
        pdf_path = pdf_source.pdf_path
        source_sha256 = _compute_sha256(pdf_path)

        user_message = (
            f"Please read the financial statement PDF at @{pdf_path} and extract "
            f"all numeric cell values from financial tables. Output JSON only."
        )

        log.info(
            "ClaudeVisionPdfTableExtractor.extract: model=%s pdf=%s sha256=%s...",
            self._model,
            pdf_path.name,
            source_sha256[:12],
        )

        start_ms = _now_ms()
        try:
            text, in_tok, out_tok = claude_cli_transport(
                model=self._model,
                system_prompt=_SYSTEM_PROMPT,
                user_message=user_message,
                temperature=0.0,
            )
        except SubagentSubstrateError as exc:
            raise VisionExtractionError(
                f"claude_cli_transport failed during PDF extraction: {exc}"
            ) from exc
        wall_ms = _now_ms() - start_ms

        call_cost = _compute_cost(self._model, in_tok, out_tok)
        self._call_records.append(
            _CallRecord(
                cells_extracted=0,  # updated below after parse
                input_tokens=in_tok,
                output_tokens=out_tok,
                cost_usd=call_cost,
                wall_ms=wall_ms,
            )
        )

        cumulative_cost: Decimal = sum(
            (r.cost_usd for r in self._call_records), Decimal("0")
        )
        if cumulative_cost > self._cost_ceiling_usd:
            raise CostBudgetExceeded(cumulative_cost, self._cost_ceiling_usd)

        raw_cells = _parse_cells_from_response(text)
        if not raw_cells:
            raise VisionExtractionError(
                f"Claude vision returned zero cells for {pdf_path.name}. "
                f"Response text: {text[:300]!r}"
            )

        # Update call record with actual cell count
        self._call_records[-1] = _CallRecord(
            cells_extracted=len(raw_cells),
            input_tokens=in_tok,
            output_tokens=out_tok,
            cost_usd=call_cost,
            wall_ms=wall_ms,
        )

        # Rule 16 mode #2: EchoValidator.validate() on each cell.
        # Deterministic re-parse of raw string → Decimal; compare with LLM-claimed value.
        for cell_label, raw_value in raw_cells.items():
            deterministic_decimal = _parse_vnd_string(raw_value)
            if deterministic_decimal is not None:
                # EchoValidator raises EchoValidationError (HARD ERROR) on mismatch.
                EchoValidator.validate(
                    raw_value,
                    deterministic_decimal,
                    cell_label=cell_label,
                )

        log.info(
            "ClaudeVisionPdfTableExtractor.extract: cells=%d cost_usd=%s wall_ms=%d",
            len(raw_cells),
            call_cost,
            wall_ms,
        )

        return ExtractedFinancialStatement(
            pdf_source=pdf_source,
            raw_cells=raw_cells,
            extraction_method=self.name(),
            extractor_version=self.extractor_version(),
            source_pdf_page=None,  # V0: whole-document extraction; no per-cell page tracking
            source_pdf_sha256=source_sha256,
            extracted_at=datetime.now(UTC),  # D-059 R1: tz-aware
        )

    def supports(self, pdf_path: Path) -> bool:
        """Return True for any .pdf file path.

        G.3 attempts vision OCR on all PDFs; failure surfaces as VisionExtractionError.
        Does NOT pre-discriminate digital vs scanned — vision handles both.

        MUST NOT raise; return False on any uncertainty (per ABC contract).
        """
        try:
            return pdf_path.suffix.lower() == ".pdf"
        except Exception:  # noqa: BLE001
            return False

    def name(self) -> str:
        """Human-readable adapter identifier."""
        return f"claude-vision v{self.extractor_version()}"

    def extractor_version(self) -> str:
        """Semver string for this adapter version."""
        return "0.1.0"

    @property
    def call_records(self) -> list[_CallRecord]:
        """Per-call cost + metadata records for I-S20 calibration telemetry (read-only copy)."""
        return list(self._call_records)


# ── Helpers ───────────────────────────────────────────────────────────────────


def _compute_sha256(path: Path) -> str:
    """Compute SHA-256 hex digest of a file. Returns 64-char lowercase hex string."""
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def _now_ms() -> int:
    """Current time in milliseconds (wall clock; for timing only — not persisted)."""
    return int(datetime.now(UTC).timestamp() * 1000)


_JSON_FENCE_RE = re.compile(r"```(?:json)?\s*\n?(.*?)\n?```", re.DOTALL)


def _parse_cells_from_response(text: str) -> dict[str, str]:
    """Parse Claude's JSON response to extract cells dict.

    Handles:
    - Plain JSON: {"cells": {"label": "value", ...}}
    - JSON wrapped in ```json...``` fence
    - JSON with "cells" key at any nesting level

    Returns empty dict if parsing fails (caller raises VisionExtractionError).
    """
    # Try unwrap fence first
    fence_matches = _JSON_FENCE_RE.findall(text)
    candidate = fence_matches[-1].strip() if fence_matches else text.strip()

    try:
        parsed = json.loads(candidate)
    except (json.JSONDecodeError, ValueError):
        return {}

    if isinstance(parsed, dict):
        # Direct {"cells": {...}} format
        cells = parsed.get("cells")
        if isinstance(cells, dict):
            return {str(k): str(v) for k, v in cells.items() if v is not None}
        # Flat format: all string values directly
        flat = {str(k): str(v) for k, v in parsed.items() if isinstance(v, str)}
        if flat:
            return flat

    return {}


def _parse_vnd_string(raw: str) -> Decimal | None:
    """Deterministic re-parse of a raw VND cell string to Decimal.

    Used as the "deterministic_value" input to EchoValidator.validate().
    Returns None if the string cannot be parsed (e.g. non-numeric cell like a label).

    This is the upstream deterministic-pipeline computation that the LLM must echo.
    Per Rule 16 mode #2: LLM echoes this value; EchoValidator asserts the echo matches.
    """
    if not raw or not raw.strip():
        return None

    s = raw.strip()

    # Skip non-numeric strings (e.g. labels, dates, text annotations)
    # Quick check: must contain at least one digit
    if not any(c.isdigit() for c in s):
        return None

    # Delegate to EchoValidator's canonical form for consistency
    try:
        from packages.application.fundamental.echo_validator import _canonicalize_numeric_string
        return _canonicalize_numeric_string(s)
    except (ValueError, InvalidOperation):
        return None
