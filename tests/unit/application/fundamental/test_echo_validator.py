"""Tests for EchoValidator — Rule 16 mode #2 deterministic-pipeline echo gate.

Covers:
  1. validate() returns None on exact-match
  2. validate() raises EchoValidationError on mismatch (HARD ERROR)
  3. validate() handles whitespace coercion
  4. validate() handles Vietnamese thousand-separator ("1.234.567")
  5. validate() handles US thousand-separator ("1,234,567")
  6. validate() handles parentheses-negative wrapping ("(1234)" → -1234)
  7. validate() handles Triệu-đồng suffix (×1,000,000)
  8. validate() handles Tỷ-đồng suffix (×1,000,000,000)
  9. EchoValidationError exposes cell_label + llm_value + deterministic_value fields
 10. tolerance=0 enforced: near-match still raises
 11. validate() with zero value ("0" or "0.00")
 12. validate() with negative value ("-1234")
 13. validate() with unparseable string raises EchoValidationError
 14. Multiple valid coercions in sequence all pass
 15. EchoValidationError is a subclass of ValueError

Plan:  043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md § E.4 D4
Spec:  agent-workspace/constitution/financial-data-protocol.md:396-402 (Rule 16 mode #2)
"""

from __future__ import annotations

from decimal import Decimal

import pytest

from packages.application.fundamental.echo_validator import (
    EchoValidationError,
    EchoValidator,
)

# ── Test 1: exact match returns None ──────────────────────────────────────────


def test_validate_exact_integer_match() -> None:
    """validate() returns None when LLM echoes exact integer string."""
    result = EchoValidator.validate("1234567", Decimal("1234567"), cell_label="REVENUE")
    assert result is None


def test_validate_exact_decimal_match() -> None:
    """validate() returns None for exact decimal string match."""
    result = EchoValidator.validate("12.34", Decimal("12.34"), cell_label="EPS")
    assert result is None


# ── Test 2: mismatch raises EchoValidationError ───────────────────────────────


def test_validate_mismatch_raises() -> None:
    """validate() raises EchoValidationError on any numeric mismatch."""
    with pytest.raises(EchoValidationError):
        EchoValidator.validate("1234567", Decimal("1234568"), cell_label="REVENUE")


def test_validate_mismatch_exact_value() -> None:
    """EchoValidationError contains correct fields."""
    with pytest.raises(EchoValidationError) as exc_info:
        EchoValidator.validate("1000", Decimal("1001"), cell_label="ASSETS")
    err = exc_info.value
    assert err.cell_label == "ASSETS"
    assert err.llm_value == "1000"
    assert err.deterministic_value == Decimal("1001")


# ── Test 3: whitespace coercion ───────────────────────────────────────────────


def test_validate_leading_trailing_whitespace() -> None:
    """validate() strips whitespace before comparison."""
    result = EchoValidator.validate("  1234567  ", Decimal("1234567"), cell_label="REV")
    assert result is None


def test_validate_internal_whitespace_in_value() -> None:
    """Whitespace around suffix handled correctly."""
    result = EchoValidator.validate("  1 ", Decimal("1"), cell_label="SMALL")
    assert result is None


# ── Test 4: Vietnamese thousand-separator ─────────────────────────────────────


def test_validate_vn_thousand_separator_single_dot() -> None:
    """Vietnamese single-dot thousand-separator '1.234' → Decimal('1234')."""
    result = EchoValidator.validate("1.234", Decimal("1234"), cell_label="PROFIT")
    assert result is None


def test_validate_vn_thousand_separator_multiple_dots() -> None:
    """Vietnamese multi-dot thousand-separator '1.234.567' → Decimal('1234567')."""
    result = EchoValidator.validate("1.234.567", Decimal("1234567"), cell_label="REVENUE")
    assert result is None


# ── Test 5: US thousand-separator ────────────────────────────────────────────


def test_validate_us_thousand_separator_single_comma() -> None:
    """US single-comma thousand-separator '1,234' → Decimal('1234')."""
    result = EchoValidator.validate("1,234", Decimal("1234"), cell_label="PROFIT")
    assert result is None


def test_validate_us_thousand_separator_multiple_commas() -> None:
    """US multi-comma thousand-separator '1,234,567' → Decimal('1234567')."""
    result = EchoValidator.validate("1,234,567", Decimal("1234567"), cell_label="REVENUE")
    assert result is None


# ── Test 6: parentheses-negative ─────────────────────────────────────────────


def test_validate_parens_negative_integer() -> None:
    """Parentheses-negative wrapping '(1234)' → Decimal('-1234')."""
    result = EchoValidator.validate("(1234)", Decimal("-1234"), cell_label="NET_LOSS")
    assert result is None


def test_validate_parens_negative_with_thousand_sep() -> None:
    """Parentheses-negative with Vietnamese thousand-sep '(1.234)' → Decimal('-1234')."""
    result = EchoValidator.validate("(1.234)", Decimal("-1234"), cell_label="LOSS")
    assert result is None


# ── Test 7: Triệu-đồng suffix ────────────────────────────────────────────────


def test_validate_trieu_dong_suffix() -> None:
    """'1.234 Triệu đồng' → Decimal('1234') * 1_000_000 = Decimal('1234000000')."""
    result = EchoValidator.validate(
        "1.234 Triệu đồng", Decimal("1234000000"), cell_label="REVENUE"
    )
    assert result is None


def test_validate_trieu_dong_suffix_case_insensitive() -> None:
    """Triệu-đồng suffix matching is case-insensitive."""
    result = EchoValidator.validate(
        "500 TRIỆU ĐỒNG", Decimal("500000000"), cell_label="ASSETS"
    )
    assert result is None


# ── Test 8: Tỷ-đồng suffix ───────────────────────────────────────────────────


def test_validate_ty_dong_suffix() -> None:
    """'1.234 Tỷ đồng' → Decimal('1234') * 1_000_000_000 = Decimal('1234000000000')."""
    result = EchoValidator.validate(
        "1.234 Tỷ đồng", Decimal("1234000000000"), cell_label="TOTAL_ASSETS"
    )
    assert result is None


def test_validate_ty_dong_suffix_y_variant() -> None:
    """'Ty dong' (ASCII variant) also recognized."""
    result = EchoValidator.validate(
        "2 Ty dong", Decimal("2000000000"), cell_label="EQUITY"
    )
    assert result is None


# ── Test 9: EchoValidationError fields ───────────────────────────────────────


def test_echo_validation_error_fields() -> None:
    """EchoValidationError exposes cell_label, llm_value, deterministic_value."""
    cell = "REVENUE"
    llm_val = "99999"
    det_val = Decimal("100000")
    with pytest.raises(EchoValidationError) as exc_info:
        EchoValidator.validate(llm_val, det_val, cell_label=cell)
    err = exc_info.value
    assert err.cell_label == cell
    assert err.llm_value == llm_val
    assert err.deterministic_value == det_val
    # Error message must mention key fields
    assert "REVENUE" in str(err)
    assert "99999" in str(err)


# ── Test 10: tolerance=0 enforced ────────────────────────────────────────────


def test_validate_near_match_still_raises() -> None:
    """tolerance=0: '1234567' vs Decimal('1234567.01') raises — no tolerance band."""
    with pytest.raises(EchoValidationError):
        EchoValidator.validate("1234567", Decimal("1234567.01"), cell_label="REVENUE")


def test_validate_one_unit_off_raises() -> None:
    """tolerance=0: off by exactly 1 unit raises EchoValidationError."""
    with pytest.raises(EchoValidationError):
        EchoValidator.validate("1000", Decimal("1001"), cell_label="COST")


# ── Test 11: zero value ───────────────────────────────────────────────────────


def test_validate_zero_string() -> None:
    """validate() handles zero value '0'."""
    result = EchoValidator.validate("0", Decimal("0"), cell_label="ZERO_ITEM")
    assert result is None


def test_validate_zero_decimal_string() -> None:
    """validate() handles '0.00'."""
    result = EchoValidator.validate("0.00", Decimal("0"), cell_label="ZERO_DEC")
    assert result is None


# ── Test 12: negative value ───────────────────────────────────────────────────


def test_validate_negative_plain() -> None:
    """validate() handles plain negative '-1234'."""
    result = EchoValidator.validate("-1234", Decimal("-1234"), cell_label="NET_LOSS")
    assert result is None


# ── Test 13: unparseable string raises EchoValidationError ───────────────────


def test_validate_unparseable_raises_echo_error() -> None:
    """Unparseable LLM string (not a number) raises EchoValidationError."""
    with pytest.raises(EchoValidationError):
        EchoValidator.validate("N/A", Decimal("1000"), cell_label="REVENUE")


def test_validate_empty_string_raises() -> None:
    """Empty string raises EchoValidationError."""
    with pytest.raises(EchoValidationError):
        EchoValidator.validate("", Decimal("0"), cell_label="ZERO")


# ── Test 14: multiple coercions in sequence ────────────────────────────────────


def test_multiple_validations_sequence() -> None:
    """Multiple sequential validate() calls all return None on correct values."""
    cases: list[tuple[str, Decimal, str]] = [
        ("1.234.567", Decimal("1234567"), "REVENUE"),
        ("(500)", Decimal("-500"), "LOSS"),
        ("2 Tỷ đồng", Decimal("2000000000"), "ASSETS"),
        ("100,000", Decimal("100000"), "EQUITY"),
        ("0", Decimal("0"), "ZERO"),
    ]
    for llm_val, det_val, label in cases:
        result = EchoValidator.validate(llm_val, det_val, cell_label=label)
        assert result is None, f"Expected None for {llm_val!r} vs {det_val}"


# ── Test 15: EchoValidationError is ValueError subclass ───────────────────────


def test_echo_validation_error_is_value_error() -> None:
    """EchoValidationError subclasses ValueError per plan-043 § E.2 spec."""
    err = EchoValidationError("REVENUE", "1000", Decimal("1001"))
    assert isinstance(err, ValueError)
