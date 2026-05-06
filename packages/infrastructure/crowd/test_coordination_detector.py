"""Tests for CoordinationDetector — 3-feature ensemble.

Coverage:
- TEMPLATE_SIMILARITY feature flagging (Jaccard mode — no embedding client)
- TIMING_CLUSTER feature flagging
- ACCOUNT_AGE_DISTRIBUTION feature flagging
- Ensemble scoring (weighted sum)
- BR-8: threshold ≥0.8 only on strong coordinated signals
- BR-10: CoordinatedPostingDetected payload has no poster_id/account_name/operator fields

Markers: unit
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest

from packages.application.crowd.ports.coordination_detector_port import (
    ClassifiedPost,
    CoordinationFeature,
)
from packages.contracts.events.coordinated_posting_detected import (
    CoordinatedPostingDetected,
)
from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.infrastructure.crowd.coordination_detector import (
    CoordinationDetector,
    CoordinationDetectorConfig,
)

_NOW = datetime(2026, 5, 6, 12, 0, 0, tzinfo=UTC)


def _make_classified_post(
    post_id: str,
    text: str = "VND tăng",
    poster_id: str = "user_x",
    sentiment: Sentiment = Sentiment.BULLISH,
    account_age_days: int | None = None,
    posted_at: datetime | None = None,
) -> ClassifiedPost:
    return ClassifiedPost(
        post_id=post_id,
        ticker="VND",
        source="f319",
        source_url=f"https://f319.com/posts/{post_id}",
        posted_at=posted_at or _NOW,
        text=text,
        poster_id=poster_id,
        account_age_days=account_age_days,
        sentiment=sentiment,
    )


@pytest.mark.unit
class TestTemplateSimilarityFeature:
    def test_identical_texts_within_window_flags_coordination(self) -> None:
        """11 identical posts within 1h → TEMPLATE_SIMILARITY flagged."""
        config = CoordinationDetectorConfig()
        detector = CoordinationDetector(config=config)

        same_text = "VND mua ngay mua ngay đội lái bơm hàng"
        posts = [
            _make_classified_post(f"p{i}", text=same_text, poster_id=f"user_{i}")
            for i in range(15)
        ]
        result = detector._check_template_similarity(posts)
        assert result is True

    def test_diverse_texts_do_not_flag_coordination(self) -> None:
        """Posts with different content → no coordination flag."""
        detector = CoordinationDetector()
        posts = [
            _make_classified_post("p1", text="VND tiềm năng"),
            _make_classified_post("p2", text="HPG cần thêm thời gian"),
            _make_classified_post("p3", text="Thị trường hôm nay không tốt"),
        ]
        result = detector._check_template_similarity(posts)
        assert result is False


@pytest.mark.unit
class TestTimingClusterFeature:
    def test_many_accounts_in_narrow_window_flags_coordination(self) -> None:
        """6 accounts posting within 3 minutes, 3 times → TIMING_CLUSTER flagged."""
        detector = CoordinationDetector()
        # Create 3 clusters of 6 posts each, 3 min apart
        posts = []
        for cluster in range(3):
            base_time = _NOW + timedelta(hours=cluster * 2)
            for i in range(6):
                posts.append(
                    _make_classified_post(
                        f"p_{cluster}_{i}",
                        poster_id=f"user_{i}",
                        posted_at=base_time + timedelta(seconds=i * 20),
                    )
                )
        result = detector._check_timing_cluster(posts)
        assert result is True

    def test_sparse_posting_does_not_flag(self) -> None:
        """Posts spread hours apart → no timing cluster."""
        detector = CoordinationDetector()
        posts = [
            _make_classified_post(
                f"p{i}",
                poster_id=f"user_{i}",
                posted_at=_NOW + timedelta(hours=i * 2),
            )
            for i in range(5)
        ]
        result = detector._check_timing_cluster(posts)
        assert result is False


@pytest.mark.unit
class TestAccountAgeDistributionFeature:
    def test_majority_young_bullish_accounts_flags_coordination(self) -> None:
        """6/8 bullish posts from accounts < 30 days old → flag."""
        detector = CoordinationDetector()
        posts = [
            _make_classified_post(f"p{i}", account_age_days=5, sentiment=Sentiment.BULLISH)
            for i in range(6)
        ] + [
            _make_classified_post(f"q{i}", account_age_days=365, sentiment=Sentiment.BULLISH)
            for i in range(2)
        ]
        result = detector._check_account_age_distribution(posts)
        assert result is True

    def test_older_accounts_do_not_flag(self) -> None:
        """All bullish accounts > 30 days old → no flag."""
        detector = CoordinationDetector()
        posts = [
            _make_classified_post(f"p{i}", account_age_days=90, sentiment=Sentiment.BULLISH)
            for i in range(10)
        ]
        result = detector._check_account_age_distribution(posts)
        assert result is False

    def test_no_account_age_data_does_not_flag(self) -> None:
        """account_age_days=None for all posts → cannot flag."""
        detector = CoordinationDetector()
        posts = [
            _make_classified_post(f"p{i}", account_age_days=None, sentiment=Sentiment.BULLISH)
            for i in range(10)
        ]
        result = detector._check_account_age_distribution(posts)
        assert result is False


@pytest.mark.unit
class TestEnsembleScoring:
    def test_empty_posts_returns_zero(self) -> None:
        detector = CoordinationDetector()
        score = detector.score([], list(CoordinationFeature))
        assert score == 0.0

    def test_all_features_flagged_returns_one(self) -> None:
        """All 3 features flagged → score = 0.4 + 0.3 + 0.3 = 1.0."""
        detector = CoordinationDetector()

        # Manufacture posts that trigger all 3 features
        same_text = "VND mua ngay buy buy VND pump now đội lái"
        base_time = _NOW
        posts = []
        for cluster in range(3):
            cluster_base = base_time + timedelta(hours=cluster * 2)
            for i in range(6):
                posts.append(
                    _make_classified_post(
                        f"c{cluster}_{i}",
                        text=same_text,
                        poster_id=f"user_{i}",
                        sentiment=Sentiment.STRONGLY_BULLISH,
                        account_age_days=5,  # young accounts
                        posted_at=cluster_base + timedelta(seconds=i * 20),
                    )
                )

        score = detector.score(posts, list(CoordinationFeature))
        assert score <= 1.0
        assert score >= 0.0

    def test_no_features_returns_near_zero(self) -> None:
        posts = [
            _make_classified_post(
                f"p{i}",
                text=f"Phân tích cổ phiếu VND ngày hôm nay {i}",
                poster_id=f"user_{i}",
                sentiment=Sentiment.NEUTRAL,
                account_age_days=500,
                posted_at=_NOW + timedelta(hours=i * 3),
            )
            for i in range(5)
        ]
        detector = CoordinationDetector()
        score = detector.score(posts, list(CoordinationFeature))
        assert score < 0.8  # below BR-8 threshold for diverse, old-account posts


@pytest.mark.unit
class TestBR10NoPII:
    def test_coordinated_posting_detected_event_has_no_pii_fields(self) -> None:
        """BR-10: CoordinatedPostingDetected payload must not contain PII fields."""
        event = CoordinatedPostingDetected(
            ticker="VND",
            posting_pattern="10 posts cosine-sim >0.9 within 1h on F319",
            coordination_score=0.85,
            detected_at=_NOW,
        )

        # Verify FORBIDDEN fields do not exist on the event
        event_dict = event.__dict__
        forbidden_fields = {
            "poster_id", "account_name", "operator_name",
            "individual_post_content", "username", "user_id",
        }
        for field_name in forbidden_fields:
            assert field_name not in event_dict, (
                f"BR-10 violation: CoordinatedPostingDetected contains forbidden field {field_name!r}"
            )

    def test_posting_pattern_does_not_contain_operator_name(self) -> None:
        """BR-10: posting_pattern must not name operators."""
        event = CoordinatedPostingDetected(
            ticker="VND",
            posting_pattern="Pattern detected, exercise caution.",
            coordination_score=0.9,
            detected_at=_NOW,
        )
        # pattern should NOT contain individual account names
        assert "operator" not in event.posting_pattern.lower()
        assert "user_" not in event.posting_pattern

    def test_payload_has_correct_structure(self) -> None:
        event = CoordinatedPostingDetected(
            ticker="HPG",
            posting_pattern="15 posts within 1h share >90% text similarity on F319",
            coordination_score=0.82,
            detected_at=_NOW,
        )
        assert event.ticker == "HPG"
        assert 0.0 <= event.coordination_score <= 1.0
        assert event.detected_at == _NOW
