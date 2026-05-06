"""Tests for LLMRecommendationExtractor — BC-6 Track H.

All tests use mock transport; no live LLM calls in pytest path.

Covers:
- Happy path: mock LLM returns valid Vietnamese fixture → Recommendation objects.
- BR-6: extraction_confidence < 0.7 → requires_manual_review=True on Recommendation.
- BR-7: conditional flag preserved in extracted Recommendation.
- Prose-tolerant JSON (BP-S43b-2): preamble before JSON still parsed correctly.
- Vietnamese diacritics (ổ ậ ề ữ ợ) round-trip through extraction + Recommendation.
- Empty transcript → empty list.
- No extractable recommendations → empty list.
- JSON parse failure → empty list (not raise).
- Confidence < 0.5 → item skipped (spec § B.5 rule).
- Unknown intent → item skipped.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.5 + § A.3 BR-6/7/10.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § d).
"""

from __future__ import annotations

import json
from collections.abc import Callable
from datetime import UTC, datetime
from pathlib import Path

import pytest

from packages.domain.influence.models.channel_content import ChannelContent
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.timeframe import Timeframe
from packages.infrastructure.influence.extraction_strategy_picker import (
    ExtractionStrategy,
    pick_extraction_strategy,
)
from packages.infrastructure.influence.llm_recommendation_extractor import (
    LLMExtractionError,
    LLMRecommendationExtractor,
)

# ---- Constants ---------------------------------------------------------------

_PUBLISHED_AT = datetime(2026, 5, 1, 14, 0, tzinfo=UTC)
_EXTRACTED_AT = datetime(2026, 5, 1, 15, 0, tzinfo=UTC)
_FIXTURE_DIR = (
    Path(__file__).parent / "fixtures" / "vi_kol_transcripts"
)


# ---- Helpers -----------------------------------------------------------------


def _make_content(
    source_url: str = "https://www.youtube.com/watch?v=test123",
    channel_id: str = "channel-yt-001",
    published_at: datetime = _PUBLISHED_AT,
    raw_text: str = "",
) -> ChannelContent:
    return ChannelContent(
        content_id="test-content-id",
        channel_id=ChannelId(channel_id),
        source_url=source_url,
        published_at=published_at,
        raw_text=raw_text,
    )


TransportCallable = Callable[[str, str, str, float], tuple[str, int, int]]


def _make_transport(response_json: list[object]) -> TransportCallable:
    """Return a transport callable that returns a JSON-serialised response."""
    raw = json.dumps(response_json, ensure_ascii=False)

    def transport(
        _model: str, _system_prompt: str, _user_message: str, _temperature: float
    ) -> tuple[str, int, int]:
        return raw, 100, 50

    return transport


def _make_extractor(
    transport: TransportCallable | None = None,
    kol_id: str = "kol-test-001",
    persist_raw_responses: bool = False,
) -> LLMRecommendationExtractor:
    """Construct extractor with mock transport and disabled raw persistence."""
    return LLMRecommendationExtractor(
        transport=transport or _make_transport([]),
        kol_id=KolId(kol_id),
        persist_raw_responses=persist_raw_responses,
        clock=lambda: _EXTRACTED_AT,
    )


# ---- Tests: happy path -------------------------------------------------------


def test_happy_path_single_recommendation_vietnamese() -> None:
    """Mock LLM returns valid HPG BUY recommendation → Recommendation object constructed."""
    transport = _make_transport([
        {
            "ticker": "HPG",
            "intent": "STRONG_BUY",
            "timeframe": "MONTHS",
            "conditions": [],
            "timestamp_in_source": "02:34-02:45",
            "transcript_excerpt": "mạnh tay mua HPG ở vùng giá 26.000 mục tiêu 30.000",
            "extraction_confidence": 0.92,
        }
    ])
    extractor = _make_extractor(transport)
    content = _make_content(raw_text="mạnh tay mua HPG ở vùng giá 26.000")

    recs = extractor.extract("mạnh tay mua HPG ở vùng giá 26.000", content)

    assert len(recs) == 1
    rec = recs[0]
    assert rec.ticker == "HPG"
    assert rec.intent == Intent.STRONG_BUY
    assert rec.timeframe == Timeframe.MONTHS
    assert rec.extraction_confidence == pytest.approx(0.92)
    assert not rec.requires_manual_review
    assert rec.source_url == content.source_url


def test_happy_path_multiple_recommendations() -> None:
    """Two tickers in one transcript → two Recommendation objects."""
    transport = _make_transport([
        {
            "ticker": "FPT",
            "intent": "BUY",
            "timeframe": "WEEKS",
            "conditions": [],
            "timestamp_in_source": "01:10-01:30",
            "transcript_excerpt": "mua FPT trong ngắn hạn",
            "extraction_confidence": 0.88,
        },
        {
            "ticker": "VIC",
            "intent": "WATCH",
            "timeframe": "WEEKS",
            "conditions": [],
            "timestamp_in_source": "03:00-03:20",
            "transcript_excerpt": "theo dõi VIC thêm một thời gian",
            "extraction_confidence": 0.75,
        },
    ])
    extractor = _make_extractor(transport)
    content = _make_content()

    recs = extractor.extract("mua FPT, theo dõi VIC", content)

    assert len(recs) == 2
    tickers = {r.ticker for r in recs}
    assert tickers == {"FPT", "VIC"}


def test_empty_transcript_returns_empty() -> None:
    """Empty transcript → no LLM call, returns empty list immediately."""
    extractor = _make_extractor()
    recs = extractor.extract("", _make_content())
    assert recs == []


def test_whitespace_transcript_returns_empty() -> None:
    """Whitespace-only transcript → empty list."""
    extractor = _make_extractor()
    recs = extractor.extract("   \n\t", _make_content())
    assert recs == []


# ---- Tests: BR-6 confidence threshold ----------------------------------------


def test_confidence_below_threshold_sets_manual_review_flag() -> None:
    """BR-6: extraction_confidence = 0.65 (< 0.7) → requires_manual_review=True on Recommendation."""
    transport = _make_transport([
        {
            "ticker": "MSN",
            "intent": "AVOID",
            "timeframe": "WEEKS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": "cẩn thận với MSN ở vùng giá này",
            "extraction_confidence": 0.65,
        }
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract("cẩn thận với MSN", _make_content())

    assert len(recs) == 1
    assert recs[0].requires_manual_review is True
    assert recs[0].extraction_confidence == pytest.approx(0.65)


def test_confidence_at_exactly_070_not_manual_review() -> None:
    """Exactly 0.7 → NOT manual review (boundary condition)."""
    transport = _make_transport([
        {
            "ticker": "VHM",
            "intent": "BUY",
            "timeframe": "MONTHS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": "mua VHM ở vùng 45.000",
            "extraction_confidence": 0.7,
        }
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract("mua VHM", _make_content())

    assert len(recs) == 1
    assert recs[0].requires_manual_review is False


def test_confidence_below_050_item_skipped() -> None:
    """Spec § B.5: confidence < 0.5 → DO NOT extract → item skipped entirely."""
    transport = _make_transport([
        {
            "ticker": "HPG",
            "intent": "BUY",
            "timeframe": "WEEKS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": "không chắc về HPG",
            "extraction_confidence": 0.45,
        }
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract("không chắc về HPG", _make_content())

    assert recs == []


# ---- Tests: BR-7 conditional flag --------------------------------------------


def test_conditional_recommendation_preserved() -> None:
    """BR-7: conditions list preserved verbatim in extracted Recommendation."""
    transport = _make_transport([
        {
            "ticker": "VIC",
            "intent": "WATCH",
            "timeframe": "WEEKS",
            "conditions": ["nếu giá phá vỡ ngưỡng 45.000", "sau khi VN-Index vượt 1.300"],
            "timestamp_in_source": "",
            "transcript_excerpt": "theo dõi VIC nếu giá phá vỡ ngưỡng 45.000",
            "extraction_confidence": 0.78,
        }
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract("theo dõi VIC", _make_content())

    assert len(recs) == 1
    assert recs[0].is_conditional()
    assert "nếu giá phá vỡ ngưỡng 45.000" in recs[0].conditions
    assert len(recs[0].conditions) == 2


def test_unconditional_recommendation_has_empty_conditions() -> None:
    """Unconditional recommendation has empty conditions and is_conditional() = False."""
    transport = _make_transport([
        {
            "ticker": "FPT",
            "intent": "BUY",
            "timeframe": "WEEKS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": "mua FPT ngay bây giờ",
            "extraction_confidence": 0.85,
        }
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract("mua FPT ngay bây giờ", _make_content())

    assert len(recs) == 1
    assert not recs[0].is_conditional()


# ---- Tests: BP-S43b-2 prose-tolerant JSON ------------------------------------


def test_json_with_prose_preamble_still_parsed() -> None:
    """BP-S43b-2: LLM wraps JSON in prose preamble → still parsed correctly."""
    raw_json_array = json.dumps([
        {
            "ticker": "HPG",
            "intent": "BUY",
            "timeframe": "MONTHS",
            "conditions": [],
            "timestamp_in_source": "05:00-05:30",
            "transcript_excerpt": "mua HPG cho dài hạn",
            "extraction_confidence": 0.82,
        }
    ], ensure_ascii=False)
    response_with_preamble = (
        "Dưới đây là các khuyến nghị đầu tư được trích xuất từ nội dung:\n\n"
        f"```json\n{raw_json_array}\n```"
    )

    def transport(_model: str, _sys: str, _usr: str, _temp: float) -> tuple[str, int, int]:
        return response_with_preamble, 120, 80

    extractor = _make_extractor(transport)
    recs = extractor.extract("mua HPG cho dài hạn", _make_content())

    assert len(recs) == 1
    assert recs[0].ticker == "HPG"


def test_json_without_fence_first_brace_heuristic() -> None:
    """BP-S43b-2 tier 2: JSON array without fence → first [...] heuristic extracts it."""
    raw_json_array = json.dumps([
        {
            "ticker": "VHM",
            "intent": "STRONG_BUY",
            "timeframe": "MONTHS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": "mạnh tay mua VHM",
            "extraction_confidence": 0.90,
        }
    ], ensure_ascii=False)
    response_without_fence = f"Phân tích: {raw_json_array}"

    def transport(_model: str, _sys: str, _usr: str, _temp: float) -> tuple[str, int, int]:
        return response_without_fence, 100, 60

    extractor = _make_extractor(transport)
    recs = extractor.extract("mạnh tay mua VHM", _make_content())

    assert len(recs) == 1
    assert recs[0].ticker == "VHM"


def test_invalid_json_returns_empty_not_raise() -> None:
    """Completely unparseable LLM output → empty list, not exception."""
    def transport(_model: str, _sys: str, _usr: str, _temp: float) -> tuple[str, int, int]:
        return "This is not JSON at all", 100, 20

    extractor = _make_extractor(transport)
    recs = extractor.extract("some transcript", _make_content())
    assert recs == []


def test_empty_json_array_returns_empty() -> None:
    """LLM returns [] → empty list."""
    transport = _make_transport([])
    extractor = _make_extractor(transport)
    recs = extractor.extract("chỉ nói về thị trường chung", _make_content())
    assert recs == []


# ---- Tests: Vietnamese diacritics round-trip ---------------------------------


def test_vietnamese_diacritics_preserved_in_excerpt() -> None:
    """Diacritics ổ ậ ề ữ ợ survive extraction → Recommendation.transcript_excerpt intact."""
    excerpt = "mua cổ phiếu ổn định ậu ề ữ ợ HPG ở vùng 26.000 đồng"
    transport = _make_transport([
        {
            "ticker": "HPG",
            "intent": "BUY",
            "timeframe": "MONTHS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": excerpt,
            "extraction_confidence": 0.88,
        }
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract(excerpt, _make_content())

    assert len(recs) == 1
    # All target diacritics must survive round-trip
    for diacritic in ["ổ", "ậ", "ề", "ữ", "ợ"]:
        assert diacritic in recs[0].transcript_excerpt, (
            f"Diacritic {diacritic!r} lost in round-trip"
        )


def test_vietnamese_ticker_and_conditions_preserved() -> None:
    """Vietnamese text in conditions list preserves diacritics."""
    transport = _make_transport([
        {
            "ticker": "FPT",
            "intent": "WATCH",
            "timeframe": "WEEKS",
            "conditions": ["nếu giá vượt ngưỡng kháng cự 130.000 ổn định"],
            "timestamp_in_source": "",
            "transcript_excerpt": "theo dõi FPT nếu giá vượt ngưỡng kháng cự",
            "extraction_confidence": 0.75,
        }
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract("theo dõi FPT", _make_content())

    assert len(recs) == 1
    cond = recs[0].conditions[0]
    assert "ngưỡng" in cond
    assert "ổn định" in cond


# ---- Tests: strategy picker --------------------------------------------------


def test_default_strategy_is_s3_haiku_sonnet() -> None:
    """pick_extraction_strategy() returns S3_HAIKU_SONNET by default (S47 empirical probe winner).

    S47 probe (2026-05-05): S3 precision=1.0, recall=0.889, cost=$0.27 — best precision+cost.
    Probe matrix: data/track-H-probe/probe-matrix.json.
    """
    config = pick_extraction_strategy()
    assert config.strategy == ExtractionStrategy.S3_HAIKU_SONNET
    assert "sonnet" in config.primary_model
    assert config.prefilter_model is not None
    assert "haiku" in (config.prefilter_model or "")


def test_strategy_override_opus() -> None:
    """Override to Opus returns Opus config."""
    config = pick_extraction_strategy(ExtractionStrategy.S1_OPUS)
    assert "opus" in config.primary_model


def test_strategy_override_haiku_sonnet() -> None:
    """Override to hybrid strategy returns prefilter_model."""
    config = pick_extraction_strategy(ExtractionStrategy.S3_HAIKU_SONNET)
    assert config.prefilter_model is not None
    assert "haiku" in (config.prefilter_model or "")


# ---- Tests: error paths ------------------------------------------------------


def test_no_transport_raises_extraction_error() -> None:
    """No transport injected → LLMExtractionError on extract()."""
    extractor = LLMRecommendationExtractor(
        transport=None,
        kol_id=KolId("kol-test"),
        persist_raw_responses=False,
    )
    with pytest.raises(LLMExtractionError, match="transport"):
        extractor.extract("some transcript", _make_content())


def test_transport_failure_raises_extraction_error() -> None:
    """Transport raises RuntimeError → wrapped in LLMExtractionError."""
    def failing_transport(
        _model: str, _sys: str, _usr: str, _temp: float
    ) -> tuple[str, int, int]:
        raise RuntimeError("connection refused")

    extractor = _make_extractor(failing_transport)
    with pytest.raises(LLMExtractionError, match="Transport call failed"):
        extractor.extract("some content", _make_content())


def test_unknown_intent_item_skipped() -> None:
    """Item with unrecognised intent is skipped; other valid items still returned."""
    transport = _make_transport([
        {
            "ticker": "HPG",
            "intent": "GIBBERISH_INTENT",
            "timeframe": "WEEKS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": "mua HPG",
            "extraction_confidence": 0.85,
        },
        {
            "ticker": "FPT",
            "intent": "BUY",
            "timeframe": "WEEKS",
            "conditions": [],
            "timestamp_in_source": "",
            "transcript_excerpt": "mua FPT",
            "extraction_confidence": 0.88,
        },
    ])
    extractor = _make_extractor(transport)
    recs = extractor.extract("mua HPG và FPT", _make_content())

    # HPG skipped (bad intent); FPT passes
    assert len(recs) == 1
    assert recs[0].ticker == "FPT"


# ---- Tests: fixture loading --------------------------------------------------


def test_fixture_01_hpg_strong_buy_loads() -> None:
    """Fixture 01 (HPG STRONG_BUY) JSON file is valid and contains expected fields."""
    fix_path = _FIXTURE_DIR / "fix_01_hpg_strong_buy.json"
    assert fix_path.exists(), f"Fixture not found: {fix_path}"
    data = json.loads(fix_path.read_text(encoding="utf-8"))
    assert data["expected_recommendations"][0]["ticker"] == "HPG"
    # Check diacritics in transcript
    for diacritic in data.get("diacritics_present", []):
        # The diacritic must appear somewhere in the fixture (transcript or expected)
        fixture_text = json.dumps(data, ensure_ascii=False)
        assert diacritic in fixture_text, f"Diacritic {diacritic!r} missing from fixture"


def test_fixture_05_no_recommendations_empty_expected() -> None:
    """Fixture 05 (market commentary) has empty expected_recommendations."""
    fix_path = _FIXTURE_DIR / "fix_05_no_recommendations.json"
    assert fix_path.exists()
    data = json.loads(fix_path.read_text(encoding="utf-8"))
    assert data["expected_recommendations"] == []
