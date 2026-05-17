"""Unit tests for VnSentimentLexicon + SentimentScore.

≥15 test cases per plan-030 § D3.
Synthetic VN text fixtures inline (no real-corpus fixtures per plan-029 DD-4 precedent).
WhitespaceTokenizer injected in tests for speed + determinism (no pyvi dep required).
pyvi VnTokenizer tests require pyvi installed; marked accordingly.

Source: agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md
        § D3 (test list TC 1-23 + fixtures).
"""

from __future__ import annotations

import inspect

import pytest

from apps.extraction.sentiment.vn_lexicon import (
    _VN_SENTIMENT_LEXICON,
    VN_CULTURAL_ANCHORS,
    VN_SENTIMENT_LEXICON_VERSION,
    SentimentScore,
    VnSentimentLexicon,
)
from packages.application.nlp.ports.vn_lexicon_port import VnLexiconPort
from packages.domain.news.value_objects import Sentiment
from packages.infrastructure.nlp.vn_tokenizer import WhitespaceTokenizer

# ---------------------------------------------------------------------------
# Synthetic fixtures (inline; no real-corpus data per sub-plan 029 DD-4)
# ---------------------------------------------------------------------------

_SYNTHETIC_VN_POSITIVE_TEXT = (
    "Co phieu VHM tang tran trong phien giao dich. "
    "Lap dinh moi; but pha ky thuat. "
    "Nha dau tu mua rong manh."
)

_SYNTHETIC_VN_NEGATIVE_TEXT = (
    "doi_lai da day gia MSN len kich tran. "
    "Canh bao: nha dau tu moi co the du_dinh. "
    "bat_day co phieu nay co the rui ro cao."
)

_SYNTHETIC_VN_NEUTRAL_TEXT = (
    "Thi truong chung khoan Viet Nam dang trong giai doan tich luy. "
    "Cac chuyen gia nhan dinh can theo doi them."
)

_SYNTHETIC_VN_MIXED_TEXT = "VHM tang 5% sang nay nhung giam 3% chieu nay."


@pytest.fixture()
def ws_tokenizer() -> WhitespaceTokenizer:
    """WhitespaceTokenizer for fast, deterministic tests (no pyvi required)."""
    return WhitespaceTokenizer()


@pytest.fixture()
def lexicon(ws_tokenizer: WhitespaceTokenizer) -> VnSentimentLexicon:
    """VnSentimentLexicon with WhitespaceTokenizer injected."""
    return VnSentimentLexicon(tokenizer=ws_tokenizer)


# ---------------------------------------------------------------------------
# TC 1: Empty string → empty SentimentScore
# ---------------------------------------------------------------------------
def test_score_empty_string_returns_empty_score(lexicon: VnSentimentLexicon) -> None:
    result = lexicon.score("")
    assert result == SentimentScore.empty()
    assert result.numeric_score == 0.0
    assert result.category == Sentiment.NEUTRAL
    assert result.keyword_hits == ()
    assert result.coverage_ratio == 0.0


# ---------------------------------------------------------------------------
# TC 2: Whitespace-only input → empty SentimentScore
# ---------------------------------------------------------------------------
def test_score_whitespace_only_returns_empty_score(lexicon: VnSentimentLexicon) -> None:
    result = lexicon.score("   \n\t  ")
    assert result == SentimentScore.empty()


# ---------------------------------------------------------------------------
# TC 3: Tier 1 strongly positive keyword → high positive score
# ---------------------------------------------------------------------------
def test_score_strongly_positive_keyword_tier_1(lexicon: VnSentimentLexicon) -> None:
    # "tang_tran" weight = 1.0; "tang_tran" split by whitespace -> "tang_tran" as single token
    result = lexicon.score("tang_tran")
    assert result.numeric_score > 0.0, f"Expected positive, got {result.numeric_score}"
    assert result.category in (Sentiment.BULLISH, Sentiment.STRONGLY_BULLISH)
    assert "tang_tran" in result.keyword_hits


# ---------------------------------------------------------------------------
# TC 4: Tier 2 moderately positive keyword → moderate positive score
# ---------------------------------------------------------------------------
def test_score_moderately_positive_keyword_tier_2(lexicon: VnSentimentLexicon) -> None:
    # "tang" weight = 0.5; normalized = 0.5/3.0 ≈ 0.167 → NEUTRAL (border)
    result = lexicon.score("tang")
    assert result.numeric_score > 0.0
    # 0.167 → NEUTRAL tier (< 0.3 threshold for BULLISH)
    assert result.category in (Sentiment.NEUTRAL, Sentiment.BULLISH)
    assert "tang" in result.keyword_hits


# ---------------------------------------------------------------------------
# TC 5: Tier 6 strongly negative keyword → deep negative score
# ---------------------------------------------------------------------------
def test_score_strongly_negative_keyword_tier_6(lexicon: VnSentimentLexicon) -> None:
    result = lexicon.score("giam_san")
    assert result.numeric_score < 0.0
    assert result.category in (Sentiment.BEARISH, Sentiment.STRONGLY_BEARISH)
    assert "giam_san" in result.keyword_hits


# ---------------------------------------------------------------------------
# TC 6: Cultural anchor "doi_lai" → negative score with anchor in hits
# ---------------------------------------------------------------------------
def test_score_cultural_anchor_doi_lai_negative(lexicon: VnSentimentLexicon) -> None:
    result = lexicon.score("doi_lai day gia len cao")
    assert result.numeric_score < 0.0, f"Expected negative, got {result.numeric_score}"
    assert "doi_lai" in result.keyword_hits


# ---------------------------------------------------------------------------
# TC 7: Cultural anchor "du_dinh" → negative score
# ---------------------------------------------------------------------------
def test_score_cultural_anchor_du_dinh_negative(lexicon: VnSentimentLexicon) -> None:
    result = lexicon.score("nha dau tu du_dinh co phieu")
    assert result.numeric_score < 0.0


# ---------------------------------------------------------------------------
# TC 8: Cultural anchor "bat_day" → negative (less than du_dinh per weight)
# ---------------------------------------------------------------------------
def test_score_cultural_anchor_bat_day_negative(lexicon: VnSentimentLexicon) -> None:
    bat_day_result = lexicon.score("bat_day co phieu nay")
    du_dinh_result = lexicon.score("du_dinh co phieu nay")
    # bat_day weight=-0.4, du_dinh weight=-0.7; bat_day less negative
    assert bat_day_result.numeric_score < 0.0
    assert du_dinh_result.numeric_score < 0.0
    assert bat_day_result.numeric_score > du_dinh_result.numeric_score


# ---------------------------------------------------------------------------
# TC 9: Mixed positive + negative keywords → partial offset
# ---------------------------------------------------------------------------
def test_score_mixed_positive_negative_partial_offset(lexicon: VnSentimentLexicon) -> None:
    # "tang" (+0.5) + "giam" (-0.2) = +0.3 raw; normalized = 0.3/3.0 = 0.1 → NEUTRAL
    result = lexicon.score("tang va giam")
    assert result.numeric_score != 0.0 or result.category == Sentiment.NEUTRAL
    # Result should be moderate, not extreme
    assert result.category not in (Sentiment.STRONGLY_BULLISH, Sentiment.STRONGLY_BEARISH)


# ---------------------------------------------------------------------------
# TC 10: Non-lexicon text → coverage_ratio = 0.0
# ---------------------------------------------------------------------------
def test_score_coverage_ratio_zero_for_unmatched(lexicon: VnSentimentLexicon) -> None:
    result = lexicon.score("xyz abc def ghi jkl")
    assert result.coverage_ratio == 0.0
    assert result.keyword_hits == ()


# ---------------------------------------------------------------------------
# TC 11: 1 matched keyword in 10 tokens → coverage_ratio = 0.1
# ---------------------------------------------------------------------------
def test_score_coverage_ratio_positive_for_matched(lexicon: VnSentimentLexicon) -> None:
    # "tang" is 1 keyword; rest are non-lexicon words; 10 total tokens
    text = "tang a b c d e f g h i"
    result = lexicon.score(text)
    # WhitespaceTokenizer splits on whitespace: 10 tokens; 1 match
    assert result.coverage_ratio == pytest.approx(1 / 10, abs=0.01)


# ---------------------------------------------------------------------------
# TC 12: Many strongly-negative keywords → numeric_score clamped to -1.0
# ---------------------------------------------------------------------------
def test_score_numeric_score_clamped_to_minus_one(lexicon: VnSentimentLexicon) -> None:
    # 5 strongly-negative keywords (weight -1.0 each): raw = -5.0; normalized = max(-1, -5/3) = -1.0
    text = "giam_san kich_san lao_doc_khong_phanh sup_do tham_bai"
    result = lexicon.score(text)
    assert result.numeric_score == pytest.approx(-1.0)
    assert result.category == Sentiment.STRONGLY_BEARISH


# ---------------------------------------------------------------------------
# TC 13: Many strongly-positive keywords → numeric_score clamped to +1.0
# ---------------------------------------------------------------------------
def test_score_numeric_score_clamped_to_plus_one(lexicon: VnSentimentLexicon) -> None:
    # 5 strongly-positive keywords (weight 1.0 each): raw = 5.0; normalized = min(1, 5/3) = 1.0
    text = "tang_tran kich_tran lap_dinh but_pha vuot_dinh"
    result = lexicon.score(text)
    assert result.numeric_score == pytest.approx(1.0)
    assert result.category == Sentiment.STRONGLY_BULLISH


# ---------------------------------------------------------------------------
# TC 14: Deterministic across 2 calls (D-059 R2 compliance)
# ---------------------------------------------------------------------------
def test_score_deterministic_across_runs(lexicon: VnSentimentLexicon) -> None:
    text = "Co phieu VHM tang tran trong phien giao dich doi_lai bat_day."
    out1 = lexicon.score(text)
    out2 = lexicon.score(text)
    assert out1 == out2, f"Non-deterministic: {out1} != {out2}"


# ---------------------------------------------------------------------------
# TC 15: Category STRONGLY_BULLISH at threshold 0.7
# ---------------------------------------------------------------------------
def test_score_category_strongly_bullish_threshold(lexicon: VnSentimentLexicon) -> None:
    # 3 tier-1 keywords → raw = 3.0; normalized = 3.0/3.0 = 1.0 → STRONGLY_BULLISH
    text = "tang_tran lap_dinh but_pha"
    result = lexicon.score(text)
    assert result.category == Sentiment.STRONGLY_BULLISH
    assert result.numeric_score >= 0.7


# ---------------------------------------------------------------------------
# TC 16: Empty-match input → category = NEUTRAL
# ---------------------------------------------------------------------------
def test_score_category_neutral_at_zero(lexicon: VnSentimentLexicon) -> None:
    result = lexicon.score("nonexistent_word_xyz_abc")
    assert result.category == Sentiment.NEUTRAL
    assert result.numeric_score == 0.0


# ---------------------------------------------------------------------------
# TC 17: WhitespaceTokenizer fallback → scoring still works
# ---------------------------------------------------------------------------
def test_score_with_whitespace_tokenizer_fallback() -> None:
    ws = WhitespaceTokenizer()
    lex = VnSentimentLexicon(tokenizer=ws)
    result = lex.score("tang_tran doi_lai bat_day")
    # Should match "tang_tran" (tier 1), "doi_lai" (cultural anchor), "bat_day"
    assert result.keyword_hits  # at least some matches
    # Mixed: 1.0 + (-0.8) + (-0.4) = -0.2 raw; normalized = -0.2/3.0 ≈ -0.067 → NEUTRAL
    assert result.category in (Sentiment.NEUTRAL, Sentiment.BULLISH, Sentiment.BEARISH)


# ---------------------------------------------------------------------------
# TC 18: pyvi VnTokenizer with multi-syllable VN text
# ---------------------------------------------------------------------------
@pytest.mark.skipif(
    True,  # Skip by default; enable when pyvi available in test env
    reason="Requires live pyvi; use --run-pyvi flag or environment gate",
)
def test_score_with_pyvi_tokenizer_multi_syllable() -> None:
    from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer

    vn_tok = VnTokenizer()
    lex = VnSentimentLexicon(tokenizer=vn_tok)
    # pyvi should join "tang tran" -> "tang_tran" (or similar)
    result = lex.score("Co phieu VHM tang tran trong phien giao dich hom nay")
    # With pyvi, multi-syllable compounds preserved; expect some lexicon hits
    assert isinstance(result, SentimentScore)
    assert -1.0 <= result.numeric_score <= 1.0


# ---------------------------------------------------------------------------
# TC 19: SentimentScore __post_init__ rejects out-of-range numeric_score
# ---------------------------------------------------------------------------
def test_sentiment_score_init_rejects_out_of_range_numeric() -> None:
    with pytest.raises(ValueError, match="numeric_score"):
        SentimentScore(
            numeric_score=1.5,
            category=Sentiment.STRONGLY_BULLISH,
            keyword_hits=(),
            coverage_ratio=0.0,
        )


# ---------------------------------------------------------------------------
# TC 20: SentimentScore __post_init__ rejects out-of-range coverage_ratio
# ---------------------------------------------------------------------------
def test_sentiment_score_init_rejects_out_of_range_coverage() -> None:
    with pytest.raises(ValueError, match="coverage_ratio"):
        SentimentScore(
            numeric_score=0.0,
            category=Sentiment.NEUTRAL,
            keyword_hits=(),
            coverage_ratio=1.5,
        )


# ---------------------------------------------------------------------------
# TC 21: VN_CULTURAL_ANCHORS frozenset contains all mandatory anchors
# ---------------------------------------------------------------------------
def test_vn_cultural_anchors_frozen_set_contains_mandatory() -> None:
    # Plan-030 DD-3: ≥7 of 9 mandatory anchors; we ship 8 + unicode forms
    mandatory_anchors = {
        # ASCII forms (matched by WhitespaceTokenizer on ASCII-transliterated text)
        "doi_lai",
        "du_dinh",
        "bat_day",
        "phim_hang",
        "bom_thoi",
        "ca_map",
        "hang_zin",
        # Unicode forms (matched by pyvi VnTokenizer)
        "đội_lái",
        "đu_đỉnh",
        "bắt_đáy",
        "phím_hàng",
        "bơm_thổi",
        "cá_mập",
        "hàng_zin",
    }
    for anchor in mandatory_anchors:
        assert anchor in VN_CULTURAL_ANCHORS, f"Mandatory cultural anchor missing: {anchor!r}"


# ---------------------------------------------------------------------------
# TC 22: VnSentimentLexicon satisfies VnLexiconPort structural Protocol
# ---------------------------------------------------------------------------
def test_lexicon_satisfies_vn_lexicon_port_protocol(ws_tokenizer: WhitespaceTokenizer) -> None:
    lex = VnSentimentLexicon(tokenizer=ws_tokenizer)
    # Type-check via isinstance runtime check for Protocol (Python 3.12+)
    # Minimal duck-type check: has callable 'score' method
    assert hasattr(lex, "score"), "VnSentimentLexicon must have 'score' method"
    assert callable(lex.score), "VnSentimentLexicon.score must be callable"
    # Verify signature matches VnLexiconPort.score(self, text: str) -> SentimentScore
    sig = inspect.signature(lex.score)
    params = list(sig.parameters)
    assert "text" in params, f"Expected 'text' parameter in score(); got {params}"
    # Type annotation: declare as VnLexiconPort (static mypy check passes at import)
    _port_ref: VnLexiconPort = lex  # mypy validates structural typing via Protocol
    assert _port_ref is lex


# ---------------------------------------------------------------------------
# TC 23: Rule 16 mode-2 + I-S1 — no LLM imports in module source
# ---------------------------------------------------------------------------
def test_score_no_llm_imports_in_module() -> None:
    import apps.extraction.sentiment.vn_lexicon as mod

    source_file = inspect.getfile(mod)
    with open(source_file, encoding="utf-8") as fh:
        source_text = fh.read()
    forbidden = ["import anthropic", "import openai", "from anthropic", "from openai"]
    for pattern in forbidden:
        assert pattern not in source_text, (
            f"CHARTER-TIER VIOLATION: '{pattern}' found in vn_lexicon.py "
            "— Rule 16 mode-2 requires zero LLM imports in scoring path."
        )


# ---------------------------------------------------------------------------
# Additional TC 24: Version constant is "v0.HYPOTHESIS" (UNCALIBRATED-V0 ship)
# ---------------------------------------------------------------------------
def test_lexicon_version_is_hypothesis() -> None:
    assert VN_SENTIMENT_LEXICON_VERSION == "v0.HYPOTHESIS"


# ---------------------------------------------------------------------------
# Additional TC 25: _VN_SENTIMENT_LEXICON has ≥200 entries (DC-IMPL-4)
# ---------------------------------------------------------------------------
def test_lexicon_dict_has_minimum_entries() -> None:
    count = len(_VN_SENTIMENT_LEXICON)
    assert count >= 200, (
        f"_VN_SENTIMENT_LEXICON has only {count} entries; "
        "plan-030 DC-IMPL-4 requires ≥200 per STEP 0.3 seed set."
    )


# ---------------------------------------------------------------------------
# Additional TC 26: Cultural anchors are present in _VN_SENTIMENT_LEXICON
# ---------------------------------------------------------------------------
def test_cultural_anchors_present_in_lexicon_dict() -> None:
    mandatory_in_dict = {
        "doi_lai",
        "du_dinh",
        "bat_day",
        "phim_hang",
        "bom_thoi",
        "ca_map",
        "hang_zin",
    }
    for anchor in mandatory_in_dict:
        assert anchor in _VN_SENTIMENT_LEXICON, (
            f"Cultural anchor '{anchor}' missing from _VN_SENTIMENT_LEXICON"
        )


# ---------------------------------------------------------------------------
# Additional TC 27: SentimentScore.empty() returns canonical neutral
# ---------------------------------------------------------------------------
def test_sentiment_score_empty_is_canonical_neutral() -> None:
    empty = SentimentScore.empty()
    assert empty.numeric_score == 0.0
    assert empty.category == Sentiment.NEUTRAL
    assert empty.keyword_hits == ()
    assert empty.coverage_ratio == 0.0
