"""Unit tests for SentimentSnapshot aggregate.

Coverage:
- Construction + invariants ([0,1] coordination_score; non-empty distribution; non-future captured_at)
- dominant_sentiment() computation
- bullish_ratio() computation per spec § B.1

I-S1 note: all assertions deterministic; no LLM calls.
Markers: unit
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest

from packages.domain.crowd.sentiment_snapshot import SentimentSnapshot
from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.domain.crowd.value_objects.window import Window


def _make_snapshot(**overrides: object) -> SentimentSnapshot:
    """Factory with sensible defaults; override individual fields."""
    defaults: dict[str, object] = {
        "snapshot_id": "snap_001",
        "ticker": "VND",
        "captured_at": datetime.now(UTC) - timedelta(seconds=5),
        "window": Window.ONE_HOUR,
        "mention_count": 10,
        "sentiment_distribution": {Sentiment.BULLISH: 7, Sentiment.NEUTRAL: 3},
        "posting_velocity": 10.0,
        "unique_posters": 5,
        "coordinated_posting_score": 0.1,
        "sources": {"f319": 10},
        "top_terms": ("VND tăng mạnh",),
        "source_posts_sample": ("post_001",),
    }
    defaults.update(overrides)
    return SentimentSnapshot(**defaults)  # type: ignore[arg-type]


@pytest.mark.unit
class TestSentimentSnapshotConstruction:
    def test_happy_path_constructs(self) -> None:
        snap = _make_snapshot()
        assert snap.ticker == "VND"
        assert snap.window is Window.ONE_HOUR

    def test_empty_distribution_raises(self) -> None:
        with pytest.raises(ValueError, match="non-empty"):
            _make_snapshot(sentiment_distribution={})

    def test_coordination_score_above_one_raises(self) -> None:
        with pytest.raises(ValueError, match="coordinated_posting_score"):
            _make_snapshot(coordinated_posting_score=1.1)

    def test_coordination_score_below_zero_raises(self) -> None:
        with pytest.raises(ValueError, match="coordinated_posting_score"):
            _make_snapshot(coordinated_posting_score=-0.01)

    def test_negative_velocity_raises(self) -> None:
        with pytest.raises(ValueError, match="posting_velocity"):
            _make_snapshot(posting_velocity=-1.0)

    def test_future_captured_at_raises(self) -> None:
        future = datetime.now(UTC) + timedelta(hours=2)
        with pytest.raises(ValueError, match="future"):
            _make_snapshot(captured_at=future)

    def test_coordination_score_boundary_zero_allowed(self) -> None:
        snap = _make_snapshot(coordinated_posting_score=0.0)
        assert snap.coordinated_posting_score == 0.0

    def test_coordination_score_boundary_one_allowed(self) -> None:
        snap = _make_snapshot(coordinated_posting_score=1.0)
        assert snap.coordinated_posting_score == 1.0


@pytest.mark.unit
class TestDominantSentiment:
    def test_single_category(self) -> None:
        snap = _make_snapshot(sentiment_distribution={Sentiment.BEARISH: 5})
        assert snap.dominant_sentiment() is Sentiment.BEARISH

    def test_majority_bullish(self) -> None:
        dist = {
            Sentiment.STRONGLY_BULLISH: 3,
            Sentiment.BULLISH: 5,
            Sentiment.NEUTRAL: 2,
        }
        snap = _make_snapshot(sentiment_distribution=dist)
        assert snap.dominant_sentiment() is Sentiment.BULLISH

    def test_strongly_bullish_wins_if_highest(self) -> None:
        dist = {Sentiment.STRONGLY_BULLISH: 10, Sentiment.BULLISH: 3}
        snap = _make_snapshot(sentiment_distribution=dist)
        assert snap.dominant_sentiment() is Sentiment.STRONGLY_BULLISH


@pytest.mark.unit
class TestBullishRatio:
    def test_all_bullish(self) -> None:
        dist = {Sentiment.BULLISH: 5, Sentiment.STRONGLY_BULLISH: 5}
        snap = _make_snapshot(sentiment_distribution=dist)
        assert snap.bullish_ratio() == 1.0

    def test_zero_bullish(self) -> None:
        dist = {Sentiment.BEARISH: 5, Sentiment.NEUTRAL: 5}
        snap = _make_snapshot(sentiment_distribution=dist)
        assert snap.bullish_ratio() == 0.0

    def test_eighty_percent_threshold(self) -> None:
        # Exactly 80% — triggers BR-6 counter-narrative (> 0.8 means strictly above)
        dist = {Sentiment.BULLISH: 8, Sentiment.NEUTRAL: 2}
        snap = _make_snapshot(sentiment_distribution=dist)
        assert snap.bullish_ratio() == 0.8
        assert not (snap.bullish_ratio() > 0.8)

    def test_above_eighty_percent_triggers_br6(self) -> None:
        dist = {Sentiment.STRONGLY_BULLISH: 9, Sentiment.NEUTRAL: 1}
        snap = _make_snapshot(sentiment_distribution=dist)
        assert snap.bullish_ratio() > 0.8

    def test_mixed_counts(self) -> None:
        dist = {
            Sentiment.STRONGLY_BULLISH: 3,
            Sentiment.BULLISH: 2,
            Sentiment.NEUTRAL: 3,
            Sentiment.BEARISH: 2,
        }
        snap = _make_snapshot(sentiment_distribution=dist)
        assert snap.bullish_ratio() == pytest.approx(0.5)
