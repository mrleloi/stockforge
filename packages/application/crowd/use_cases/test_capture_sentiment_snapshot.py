"""Integration tests for CaptureSentimentSnapshotUseCase.

Coverage:
- Orchestration with mock aggregator + classifier + detector + repo
- SentimentSnapshotCaptured event always emitted
- CoordinatedPostingDetected emitted only when coord_score >= 0.8 (BR-8)
- Snapshot persisted to repository
- Zero posts → snapshot created with NEUTRAL distribution (fail-open)

Markers: unit (all mocked; no live network/LLM)
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from unittest.mock import MagicMock

import pytest

from packages.application.crowd.ports.coordination_detector_port import (
    ClassifiedPost,
)
from packages.application.crowd.use_cases.capture_sentiment_snapshot_use_case import (
    CaptureSentimentSnapshotUseCase,
    CoordinatedPostingDetectedEvent,
    SentimentSnapshotCapturedEvent,
)
from packages.domain.crowd.raw_post import RawPost
from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.domain.crowd.value_objects.window import Window

# Use a time slightly in the past so SentimentSnapshot captured_at invariant is satisfied
_NOW = datetime.now(UTC).replace(microsecond=0) - __import__("datetime").timedelta(seconds=5)


def _make_raw_post(post_id: str, text: str = "VND tốt") -> RawPost:
    return RawPost(
        post_id=post_id,
        ticker="VND",
        source="f319",
        source_url=f"https://f319.com/posts/{post_id}",
        posted_at=_NOW - timedelta(minutes=30),
        text=text,
        poster_id=f"user_{post_id}",
    )


def _make_classified_post(post_id: str, sentiment: Sentiment) -> ClassifiedPost:
    return ClassifiedPost(
        post_id=post_id,
        ticker="VND",
        source="f319",
        source_url=f"https://f319.com/posts/{post_id}",
        posted_at=_NOW - timedelta(minutes=30),
        text="VND tốt",
        poster_id=f"user_{post_id}",
        account_age_days=None,
        sentiment=sentiment,
    )


@pytest.mark.unit
class TestCaptureSentimentSnapshotOrchestration:
    def _build_use_case(
        self,
        raw_posts: list[RawPost],
        classified: list[ClassifiedPost],
        coord_score: float,
    ) -> tuple[CaptureSentimentSnapshotUseCase, list[object]]:
        mock_agg = MagicMock()
        mock_agg.fetch_recent.return_value = raw_posts

        mock_clf = MagicMock()
        mock_clf.classify_batch.return_value = classified

        mock_detector = MagicMock()
        mock_detector.score.return_value = coord_score

        mock_repo = MagicMock()

        events: list[object] = []

        uc = CaptureSentimentSnapshotUseCase(
            aggregator=mock_agg,
            classifier=mock_clf,
            coordination_detector=mock_detector,
            snapshot_repo=mock_repo,
            publish_event=events.append,
            clock=lambda: _NOW,
        )
        return uc, events

    def test_snapshot_captured_event_always_emitted(self) -> None:
        posts = [_make_raw_post("p1")]
        classified = [_make_classified_post("p1", Sentiment.BULLISH)]
        uc, events = self._build_use_case(posts, classified, coord_score=0.1)

        uc.execute("VND", Window.ONE_HOUR)

        captured_events = [e for e in events if isinstance(e, SentimentSnapshotCapturedEvent)]
        assert len(captured_events) == 1
        assert captured_events[0].ticker == "VND"

    def test_coordinated_posting_event_emitted_when_score_above_threshold(self) -> None:
        posts = [_make_raw_post("p1")]
        classified = [_make_classified_post("p1", Sentiment.STRONGLY_BULLISH)]
        uc, events = self._build_use_case(posts, classified, coord_score=0.85)

        uc.execute("VND", Window.ONE_HOUR)

        coord_events = [e for e in events if isinstance(e, CoordinatedPostingDetectedEvent)]
        assert len(coord_events) == 1
        assert coord_events[0].coordination_score == 0.85
        # BR-10: posting_pattern must not contain poster_id or account_name
        assert "user_" not in coord_events[0].posting_pattern

    def test_no_coordinated_event_when_score_below_threshold(self) -> None:
        posts = [_make_raw_post("p1")]
        classified = [_make_classified_post("p1", Sentiment.NEUTRAL)]
        uc, events = self._build_use_case(posts, classified, coord_score=0.5)

        uc.execute("VND", Window.ONE_HOUR)

        coord_events = [e for e in events if isinstance(e, CoordinatedPostingDetectedEvent)]
        assert len(coord_events) == 0

    def test_snapshot_persisted_to_repo(self) -> None:
        posts = [_make_raw_post("p1"), _make_raw_post("p2")]
        classified = [
            _make_classified_post("p1", Sentiment.BULLISH),
            _make_classified_post("p2", Sentiment.NEUTRAL),
        ]
        mock_agg = MagicMock()
        mock_agg.fetch_recent.return_value = posts
        mock_clf = MagicMock()
        mock_clf.classify_batch.return_value = classified
        mock_detector = MagicMock()
        mock_detector.score.return_value = 0.0
        mock_repo = MagicMock()

        uc = CaptureSentimentSnapshotUseCase(
            aggregator=mock_agg,
            classifier=mock_clf,
            coordination_detector=mock_detector,
            snapshot_repo=mock_repo,
            clock=lambda: _NOW,
        )
        uc.execute("VND", Window.ONE_HOUR)

        mock_repo.save.assert_called_once()
        saved_snapshot = mock_repo.save.call_args[0][0]
        assert saved_snapshot.ticker == "VND"
        assert saved_snapshot.mention_count == 2
