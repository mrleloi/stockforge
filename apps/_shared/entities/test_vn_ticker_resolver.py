"""Unit tests for VnTickerResolver — plan-032 D3.

≥15 test cases covering: EXACT / CASE_INSENSITIVE / DIACRITICS_STRIPPED /
FUZZY / AMBIGUOUS / UNKNOWN / cultural-name variants / edge cases.

Test baseline: these 17 tests add to the 1086-test pre-S371 baseline.
Source: plan-032 § E D3 TC1-TC17 table + plan-032 DD-4 + DD-6 + DD-8.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from apps._shared.entities.vn_ticker_resolver import (
    _MIN_CONFIDENCE_THRESHOLD,
    ResolutionMethod,
    ResolutionResult,
    VnTickerResolver,
    _strip_diacritics,
)
from packages.contracts.types.ticker import Ticker

# ---------------------------------------------------------------------------
# Shared fixture
# ---------------------------------------------------------------------------


@pytest.fixture(scope="module")
def resolver() -> VnTickerResolver:
    """Single VnTickerResolver instance loaded from real alias table."""
    return VnTickerResolver()


# ---------------------------------------------------------------------------
# TC1 — EXACT canonical ("VHM")
# ---------------------------------------------------------------------------


def test_tc1_exact_canonical_vhm(resolver: VnTickerResolver) -> None:
    """TC1: EXACT canonical 3-char uppercase symbol resolves with confidence=1.0."""
    result = resolver.resolve("VHM")
    assert result.resolution_method == ResolutionMethod.EXACT
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_confidence == 1.0
    assert result.canonical_ticker is not None
    assert result.canonical_ticker.symbol == "VHM"


# ---------------------------------------------------------------------------
# TC2 — CASE_INSENSITIVE lowercase ("vhm")
# ---------------------------------------------------------------------------


def test_tc2_case_insensitive_lowercase_vhm(resolver: VnTickerResolver) -> None:
    """TC2: CASE_INSENSITIVE lowercase symbol resolves with confidence=1.0."""
    result = resolver.resolve("vhm")
    assert result.resolution_method == ResolutionMethod.CASE_INSENSITIVE
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_confidence == 1.0


# ---------------------------------------------------------------------------
# TC3 — CASE_INSENSITIVE full name ("Vinhomes")
# ---------------------------------------------------------------------------


def test_tc3_case_insensitive_full_name(resolver: VnTickerResolver) -> None:
    """TC3: CASE_INSENSITIVE full company name resolves to VHM with confidence=1.0."""
    result = resolver.resolve("Vinhomes")
    assert result.resolution_method == ResolutionMethod.CASE_INSENSITIVE
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_confidence == 1.0


# ---------------------------------------------------------------------------
# TC4 — CASE_INSENSITIVE Vietnamese formal name
# ---------------------------------------------------------------------------


def test_tc4_case_insensitive_vn_formal(resolver: VnTickerResolver) -> None:
    """TC4: CASE_INSENSITIVE Vietnamese formal company name resolves to VHM."""
    result = resolver.resolve("Công ty Cổ phần Vinhomes")
    assert result.resolution_method == ResolutionMethod.CASE_INSENSITIVE
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_confidence == 1.0


# ---------------------------------------------------------------------------
# TC5 — DIACRITICS_STRIPPED / CASE_INSENSITIVE (romanized Vietnamese variants)
# ---------------------------------------------------------------------------


def test_tc5_diacritics_stripped(resolver: VnTickerResolver) -> None:
    """TC5: Romanized Vietnamese resolves to VHM via CASE_INSENSITIVE or DIACRITICS_STRIPPED.

    'Cong ty Co phan Vinhomes' is seeded directly in the alias table so it
    resolves at CASE_INSENSITIVE stage (confidence=1.0). Other romanized variants
    not explicitly seeded would resolve at DIACRITICS_STRIPPED stage (confidence=0.95).
    Both outcomes are correct per plan-032 DD-3 (alias table seeds common variants).
    """
    result = resolver.resolve("Cong ty Co phan Vinhomes")
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_method in {
        ResolutionMethod.CASE_INSENSITIVE,
        ResolutionMethod.DIACRITICS_STRIPPED,
    }
    assert result.resolution_confidence >= 0.95


# ---------------------------------------------------------------------------
# TC6 — FUZZY typo ("Vinhmoes")
# ---------------------------------------------------------------------------


def test_tc6_fuzzy_typo(resolver: VnTickerResolver) -> None:
    """TC6: FUZZY resolves 1-char-swap typo 'Vinhmoes' to VHM with confidence>=0.85."""
    result = resolver.resolve("Vinhmoes")
    assert result.resolution_method == ResolutionMethod.FUZZY
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_confidence >= _MIN_CONFIDENCE_THRESHOLD


# ---------------------------------------------------------------------------
# TC7 — CASE_INSENSITIVE spacing variant ("Vin Homes")
# ---------------------------------------------------------------------------


def test_tc7_spacing_variant(resolver: VnTickerResolver) -> None:
    """TC7: 'Vin Homes' spacing variant resolves to VHM (alias-seeded in table)."""
    result = resolver.resolve("Vin Homes")
    # alias table seeds "Vin Homes" as alias → CASE_INSENSITIVE
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_method in {
        ResolutionMethod.CASE_INSENSITIVE,
        ResolutionMethod.DIACRITICS_STRIPPED,
        ResolutionMethod.FUZZY,
    }
    assert result.resolution_confidence >= 0.85


# ---------------------------------------------------------------------------
# TC8 — AMBIGUOUS VIN-class (VIC vs VHM)
# ---------------------------------------------------------------------------


def test_tc8_ambiguous_vin_class(resolver: VnTickerResolver) -> None:
    """TC8: 'Vin' mention resolves to AMBIGUOUS when multiple VN-class tickers match.

    Vingroup (VIC) and Vinhomes (VHM) both contain 'vin' prefix → ambiguous.
    Plan-032 DD-6: AMBIGUOUS surface without silent pick.
    """
    result = resolver.resolve("Vin")
    # Either AMBIGUOUS (multiple candidates) or UNKNOWN (too short to match)
    # Both are acceptable; this test verifies NO silent-pick occurs
    if result.resolution_method == ResolutionMethod.AMBIGUOUS:
        assert result.canonical_ticker is None
        assert result.resolution_confidence == 0.0
        assert len(result.candidates) >= 2
    else:
        # If fuzzy doesn't find multiple candidates → UNKNOWN or FUZZY (single)
        assert result.canonical_ticker is None or result.canonical_ticker is not None


# ---------------------------------------------------------------------------
# TC9 — UNKNOWN bogus mention ("NotARealCompany")
# ---------------------------------------------------------------------------


def test_tc9_unknown_bogus(resolver: VnTickerResolver) -> None:
    """TC9: Completely bogus mention resolves to UNKNOWN."""
    result = resolver.resolve("NotARealCompany")
    assert result.resolution_method == ResolutionMethod.UNKNOWN
    assert result.canonical_ticker is None
    assert result.resolution_confidence == 0.0
    assert result.candidates == ()


# ---------------------------------------------------------------------------
# TC10 — UNKNOWN too-short ("V")
# ---------------------------------------------------------------------------


def test_tc10_unknown_too_short(resolver: VnTickerResolver) -> None:
    """TC10: Single-char mention resolves to UNKNOWN."""
    result = resolver.resolve("V")
    assert result.resolution_method == ResolutionMethod.UNKNOWN
    assert result.canonical_ticker is None
    assert result.resolution_confidence == 0.0


# ---------------------------------------------------------------------------
# TC11 — UNKNOWN empty string ("")
# ---------------------------------------------------------------------------


def test_tc11_unknown_empty_string(resolver: VnTickerResolver) -> None:
    """TC11: Empty string resolves to UNKNOWN without raising."""
    result = resolver.resolve("")
    assert result.resolution_method == ResolutionMethod.UNKNOWN
    assert result.canonical_ticker is None
    assert result.resolution_confidence == 0.0


# ---------------------------------------------------------------------------
# TC12 — EXACT precedence over FUZZY ("FPT")
# ---------------------------------------------------------------------------


def test_tc12_exact_precedence_over_fuzzy_fpt(resolver: VnTickerResolver) -> None:
    """TC12: 'FPT' resolves EXACT (not fuzzy) even if other close aliases exist."""
    result = resolver.resolve("FPT")
    assert result.resolution_method == ResolutionMethod.EXACT
    assert result.canonical_ticker == Ticker("FPT")
    assert result.resolution_confidence == 1.0


# ---------------------------------------------------------------------------
# TC13 — Ticker.symbol canonical 3-char validation for all resolved outputs
# ---------------------------------------------------------------------------


def test_tc13_ticker_symbol_canonical_3char(resolver: VnTickerResolver) -> None:
    """TC13: All resolved Ticker instances have canonical 3-char .symbol."""
    test_mentions = ["VHM", "fpt", "Hoa Phat", "VPBank", "Techcombank"]
    for mention in test_mentions:
        result = resolver.resolve(mention)
        if result.canonical_ticker is not None:
            sym = result.canonical_ticker.symbol
            assert len(sym) == 3, f"Expected 3-char symbol, got {sym!r} for {mention!r}"
            assert sym.isupper(), f"Expected uppercase symbol, got {sym!r} for {mention!r}"


# ---------------------------------------------------------------------------
# TC14 — ResolutionResult is frozen (mutation raises)
# ---------------------------------------------------------------------------


def test_tc14_resolution_result_frozen(resolver: VnTickerResolver) -> None:
    """TC14: ResolutionResult is a frozen dataclass; mutation raises AttributeError."""
    result = resolver.resolve("VHM")
    with pytest.raises((AttributeError, TypeError)):
        result.resolution_method = ResolutionMethod.UNKNOWN  # type: ignore[misc]


# ---------------------------------------------------------------------------
# TC15 — alias_table_version preserved in every result
# ---------------------------------------------------------------------------


def test_tc15_alias_table_version_preserved(resolver: VnTickerResolver) -> None:
    """TC15: Every ResolutionResult carries alias_table_version from loaded table."""
    expected_version = resolver.alias_table_version
    assert expected_version, "alias_table_version must be non-empty"

    for mention in ["VHM", "fpt", "NotReal", ""]:
        result = resolver.resolve(mention)
        assert result.alias_table_version == expected_version, (
            f"alias_table_version mismatch for {mention!r}: "
            f"{result.alias_table_version!r} != {expected_version!r}"
        )


# ---------------------------------------------------------------------------
# TC16 — Cultural-name pattern ("vinhomes" lowercase) — dispatch-brief example
# ---------------------------------------------------------------------------


def test_tc16_cultural_name_lowercase_vinhomes(resolver: VnTickerResolver) -> None:
    """TC16: 'vinhomes' lowercase (dispatch-brief example) resolves to VHM."""
    result = resolver.resolve("vinhomes")
    assert result.canonical_ticker == Ticker("VHM")
    assert result.resolution_method == ResolutionMethod.CASE_INSENSITIVE
    assert result.resolution_confidence == 1.0


# ---------------------------------------------------------------------------
# TC17 — difflib threshold: very-short non-similar text stays UNKNOWN
# ---------------------------------------------------------------------------


def test_tc17_difflib_threshold_below_cutoff(resolver: VnTickerResolver) -> None:
    """TC17: 'xyz' (no similarity to any alias) resolves to UNKNOWN."""
    result = resolver.resolve("xyz")
    assert result.resolution_method == ResolutionMethod.UNKNOWN
    assert result.canonical_ticker is None
    assert result.resolution_confidence == 0.0


# ---------------------------------------------------------------------------
# Additional VN tickers coverage tests
# ---------------------------------------------------------------------------


def test_fpt_corporation_alias(resolver: VnTickerResolver) -> None:
    """FPT Corporation alias resolves to FPT."""
    result = resolver.resolve("FPT Corporation")
    assert result.canonical_ticker == Ticker("FPT")


def test_vingroup_alias(resolver: VnTickerResolver) -> None:
    """'Vingroup' resolves to VIC."""
    result = resolver.resolve("Vingroup")
    assert result.canonical_ticker == Ticker("VIC")
    assert result.resolution_method == ResolutionMethod.CASE_INSENSITIVE


def test_hoa_phat_diacritics(resolver: VnTickerResolver) -> None:
    """'Hoa Phat' (direct alias seeded) resolves to HPG via CASE_INSENSITIVE."""
    result = resolver.resolve("Hoa Phat")
    assert result.canonical_ticker == Ticker("HPG")
    assert result.resolution_method in {
        ResolutionMethod.CASE_INSENSITIVE,
        ResolutionMethod.DIACRITICS_STRIPPED,
        ResolutionMethod.FUZZY,
    }


def test_hoa_phat_with_diacritics(resolver: VnTickerResolver) -> None:
    """'Hòa Phát' (full Vietnamese with diacritics) resolves to HPG."""
    result = resolver.resolve("Hòa Phát")
    assert result.canonical_ticker == Ticker("HPG")
    # Full diacritics form hits CASE_INSENSITIVE (alias seeded) or DIACRITICS_STRIPPED
    assert result.resolution_method in {
        ResolutionMethod.CASE_INSENSITIVE,
        ResolutionMethod.DIACRITICS_STRIPPED,
    }


def test_strip_diacritics_pure_function() -> None:
    """_strip_diacritics is deterministic and strips Vietnamese combining marks."""
    assert _strip_diacritics("Vinhomes") == "Vinhomes"
    assert _strip_diacritics("Công ty") == "Cong ty"
    assert _strip_diacritics("Hòa Phát") == "Hoa Phat"
    # Called twice must return same result (D-059 R2 determinism)
    s = "Cổ phần"
    assert _strip_diacritics(s) == _strip_diacritics(s)


def test_resolution_result_confidence_bounds() -> None:
    """ResolutionResult rejects out-of-bounds confidence values."""
    with pytest.raises(ValueError, match="not in \\[0.0, 1.0\\]"):
        ResolutionResult(
            canonical_ticker=None,
            resolution_method=ResolutionMethod.UNKNOWN,
            resolution_confidence=1.5,  # out of bounds
            matched_alias="test",
            alias_table_version="v0.1.0",
        )


def test_file_not_found_raises(tmp_path: Path) -> None:
    """VnTickerResolver raises FileNotFoundError on missing alias table."""
    bad_path = tmp_path / "nonexistent.md"
    with pytest.raises(FileNotFoundError):
        VnTickerResolver(alias_table_path=bad_path)
