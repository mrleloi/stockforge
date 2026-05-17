"""EchoValidator — Rule 16 mode #2 deterministic-pipeline echo gate for BC-2.

Implements the post-LLM validation step that asserts the LLM-echoed numeric value
equals the upstream deterministic-pipeline computed value (tolerance=0 exact-match
after canonical-form coercion). Mismatch is a HARD ERROR per Rule 16 mode #2 spec.

Spec reference: agent-workspace/constitution/financial-data-protocol.md:396-402
  "Mismatch is a HARD ERROR (raise + abort; never silently coerce)"
  EchoValidator.validate(llm_value, deterministic_value, tolerance=...)

Plan reference: agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md § E.2 D2
  DD-4: cell-by-cell echo with tolerance=0 exact-match on Decimal + canonical-form coercion.

MUST:
  - tolerance=0 exact-match on Decimal (never tolerance-band)
  - HARD ERROR on mismatch (raise EchoValidationError; never silently coerce)
  - Canonical-form coercion before comparison (whitespace + parens-negative +
    Vietnamese/US thousand-separator + Triệu/Tỷ-đồng unit suffixes)

MUST NOT:
  - Silently coerce LLM-claimed-value on mismatch
  - Use a tolerance-band (financial VND amounts are EXACT; no measurement uncertainty)
  - Be instantiated (static utility class; no state)

ADR: D-082 PROPOSED (agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md)
Source: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md § E.3 D3
"""

from __future__ import annotations

import re
from decimal import Decimal, InvalidOperation

__all__ = ["EchoValidator", "EchoValidationError"]

# ── Unit-suffix patterns ───────────────────────────────────────────────────────
# Vietnamese financial statements use "Triệu đồng" (×1,000,000) and "Tỷ đồng"
# (×1,000,000,000) as unit suffixes in table cells.
# Pattern: optional whitespace + suffix (case-insensitive for robustness).
_TRIEU_DONG_RE = re.compile(r"\s*triệu\s*(?:đồng|dong)\s*$", re.IGNORECASE | re.UNICODE)
_TY_DONG_RE = re.compile(r"\s*t[ỷy]\s*(?:đồng|dong)\s*$", re.IGNORECASE | re.UNICODE)

# Parentheses-negative wrapper: "(1.234)" → "-1.234"
_PARENS_RE = re.compile(r"^\s*\(([^)]+)\)\s*$")

_TRIEU = Decimal("1_000_000")
_TY = Decimal("1_000_000_000")


class EchoValidationError(ValueError):
    """Raised when LLM-echoed numeric value mismatches the deterministic-pipeline value.

    Rule 16 mode #2 HARD ERROR per financial-data-protocol.md:401-402:
      "Mismatch is a HARD ERROR (raise + abort; never silently coerce)"

    Fields:
        cell_label: Adapter-specific label identifying the cell (e.g. 'REVENUE').
        llm_value: The raw string the LLM echoed in its structured output.
        deterministic_value: The Decimal computed by deterministic non-LLM code.
    """

    def __init__(
        self,
        cell_label: str,
        llm_value: str,
        deterministic_value: Decimal,
    ) -> None:
        self.cell_label = cell_label
        self.llm_value = llm_value
        self.deterministic_value = deterministic_value
        super().__init__(
            f"EchoValidator mismatch on cell {cell_label!r}: "
            f"LLM-claimed {llm_value!r} != deterministic {deterministic_value} "
            f"(Rule 16 mode #2 HARD ERROR per financial-data-protocol.md:401-402)"
        )


def _canonicalize_numeric_string(raw: str) -> Decimal:
    """Coerce a raw LLM-emitted numeric string to a canonical Decimal.

    Coercions applied IN ORDER (NOT a tolerance — each step is a bijection on
    the underlying numeric value per DD-4):

    1. Strip leading/trailing whitespace.
    2. Detect parentheses-negative wrapping: "(1.234)" → "-1.234"
    3. Detect Tỷ-đồng suffix (×1,000,000,000) BEFORE Triệu-đồng (longer suffix first).
    4. Detect Triệu-đồng suffix (×1,000,000).
    5. Normalize thousand-separator: Vietnamese "." or US "," → "" (remove).
    6. Parse to Decimal.

    Raises:
        ValueError: If the coerced string cannot be parsed to Decimal
            (propagates as EchoValidationError caller).
    """
    s = raw.strip()

    # Step 2: parentheses-negative wrapping
    parens_match = _PARENS_RE.match(s)
    if parens_match:
        s = "-" + parens_match.group(1).strip()

    # Step 3 + 4: unit suffixes (check Tỷ before Triệu; longer match priority)
    multiplier = Decimal("1")
    if _TY_DONG_RE.search(s):
        s = _TY_DONG_RE.sub("", s).strip()
        multiplier = _TY
    elif _TRIEU_DONG_RE.search(s):
        s = _TRIEU_DONG_RE.sub("", s).strip()
        multiplier = _TRIEU

    # Step 5: normalize thousand-separators
    # Vietnamese: "1.234.567" (dot = thousand-sep, no decimal point in integer cells)
    # US: "1,234,567" (comma = thousand-sep)
    # Decimal point: "1234.56" or "1234,56" — preserve the last separator as decimal
    # Strategy: remove all "." and "," that are not the decimal point.
    # Heuristic: if both "." and "," appear, the last one is decimal separator.
    # If only "." or "," appears, it's a thousand-separator (VN integer style).
    dot_pos = s.rfind(".")
    comma_pos = s.rfind(",")
    if dot_pos >= 0 and comma_pos >= 0:
        # Both present: US "1,234.56" (dot last) vs VN "1.234,56" (comma last).
        # US: remove commas, keep dot.  VN: remove dots, replace comma with dot.
        s = s.replace(",", "") if dot_pos > comma_pos else s.replace(".", "").replace(",", ".")
    elif dot_pos >= 0:
        # Only dots: VN thousand-separator style "1.234.567"
        # Count dots: if >1 or if dot is not 3 chars from end, it's thousand-sep
        dot_count = s.count(".")
        if dot_count > 1:
            # Definitely thousand-separators (e.g. "1.234.567")
            s = s.replace(".", "")
        else:
            # Single dot: could be decimal (e.g. "12.34") or thousand-sep (e.g. "1.234")
            # If exactly 3 digits after dot → likely thousand-sep in VN context
            after_dot = s[dot_pos + 1:]
            if len(after_dot) == 3 and after_dot.isdigit():
                s = s.replace(".", "")
            # else keep as decimal separator
    elif comma_pos >= 0:
        # Only commas: US-style thousand-sep "1,234,567"
        comma_count = s.count(",")
        if comma_count > 1:
            s = s.replace(",", "")
        else:
            # Single comma: could be decimal (EU style) or thousand-sep
            after_comma = s[comma_pos + 1:]
            if len(after_comma) == 3 and after_comma.isdigit():
                s = s.replace(",", "")
            else:
                s = s.replace(",", ".")

    # Step 6: parse to Decimal
    try:
        return Decimal(s) * multiplier
    except InvalidOperation as exc:
        raise ValueError(
            f"Cannot parse {raw!r} to Decimal after canonicalization (result: {s!r})"
        ) from exc


class EchoValidator:
    """Cell-by-cell echo validation gate for Rule 16 mode #2.

    Single classmethod: validate(llm_value, deterministic_value, *, cell_label)
    No instance state needed; methods are classmethods for namespace clarity.

    Rule 16 mode #2 (financial-data-protocol.md:396-402):
      The field's value is computed by deterministic code. The LLM is permitted only
      to ECHO that computed value back inside its structured output. Mismatch is a
      HARD ERROR (raise + abort; never silently coerce).
    """

    @classmethod
    def validate(
        cls,
        llm_value: str,
        deterministic_value: Decimal,
        *,
        cell_label: str,
    ) -> None:
        """Assert LLM-echoed value equals the upstream deterministic-pipeline value.

        Args:
            llm_value: Raw string from LLM structured output for this cell.
            deterministic_value: Decimal computed by deterministic (non-LLM) code.
            cell_label: Cell identifier for diagnostic error message.

        Returns:
            None on exact-match (post-canonical-form coercion).

        Raises:
            EchoValidationError: HARD ERROR per Rule 16 mode #2 spec if
                canonical(llm_value) != deterministic_value after coercion.
                Never silently coerces — caller MUST abort on this error.
        """
        try:
            llm_decimal = _canonicalize_numeric_string(llm_value)
        except ValueError:
            # Unparseable LLM output is also a mismatch (LLM cannot echo None as numeric)
            raise EchoValidationError(cell_label, llm_value, deterministic_value) from None

        if llm_decimal != deterministic_value:
            raise EchoValidationError(cell_label, llm_value, deterministic_value)
