"""CaptureSentimentSnapshotUseCase — orchestrate crowd sentiment aggregation.

Per spec § B.3 UC-1 verbatim. Fetches posts → classifies sentiment (LLM, categorical)
→ detects coordination (deterministic) → aggregates snapshot (deterministic) → persists
→ emits events.

I-S1: ALL numeric fields (mention_count, posting_velocity, unique_posters,
coordinated_posting_score, bullish_ratio) computed by Python code. LLM contributes
ONLY categorical Sentiment enum labels per BR-4.

Events emitted:
- SentimentSnapshotCaptured (always)
- CoordinatedPostingDetected (conditional: coordination_score >= 0.8 per BR-8)

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-1.
ADR: D-032 § (b) adapter pattern + (c) domain aggregates + (d) LLM substrate.
"""

from __future__ import annotations

import hashlib
import logging
import random
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.application.crowd.ports.coordination_detector_port import (
    CoordinationDetectorPort,
    CoordinationFeature,
)
from packages.application.crowd.ports.post_aggregator_port import PostAggregatorPort
from packages.application.crowd.ports.sentiment_classifier_port import (
    ClassifiedPost,
    SentimentClassifierPort,
)
from packages.application.crowd.ports.sentiment_snapshot_repository_port import (
    SentimentSnapshotRepositoryPort,
)
from packages.domain.crowd.sentiment_snapshot import SentimentSnapshot
from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.domain.crowd.value_objects.window import Window

__all__ = [
    "CaptureSentimentSnapshotUseCase",
    "CoordinatedPostingDetectedEvent",
    "SentimentSnapshotCapturedEvent",
]

logger = logging.getLogger(__name__)

# BR-8: coordination threshold — conservative to avoid false accusations
_COORDINATION_THRESHOLD = 0.8

# BR-3: max sample posts retained per snapshot
_MAX_SAMPLE_POSTS = 20


@dataclass(frozen=True)
class SentimentSnapshotCapturedEvent:
    """Event emitted after every successful snapshot capture."""

    ticker: str
    window: Window
    captured_at: datetime
    dominant_sentiment: Sentiment
    mention_count: int
    snapshot_id: str


@dataclass(frozen=True)
class CoordinatedPostingDetectedEvent:
    """Event emitted when coordination_score >= 0.8 (BR-8).

    BR-10: payload MUST NOT include poster_id, account_name, or operator names.
    Only the aggregate pattern description + score.
    """

    ticker: str
    posting_pattern: str  # e.g. "10 posts cosine-sim >0.9 within 1h on F319"
    coordination_score: float
    detected_at: datetime


# Simple event bus interface — implementations inject their own bus
EventPublisher = Callable[[object], None]


@dataclass
class CaptureSentimentSnapshotUseCase:
    """Orchestrate crowd sentiment snapshot capture for a ticker.

    Dependencies injected via constructor (testable without real adapters).
    All live network + LLM calls behind ports — unit-testable with mocks.

    Args:
        aggregator:      Fetches raw posts from crowd sources.
        classifier:      Classifies posts into categorical Sentiment (LLM; mocked in tests).
        coordination_detector: Scores coordination (deterministic; mocked in tests).
        snapshot_repo:   Persists snapshots.
        publish_event:   Optional event publisher; defaults to logging only.
        clock:           Inject for deterministic test timestamps.
    """

    aggregator: PostAggregatorPort
    classifier: SentimentClassifierPort
    coordination_detector: CoordinationDetectorPort
    snapshot_repo: SentimentSnapshotRepositoryPort
    publish_event: EventPublisher = field(
        default_factory=lambda: lambda ev: None  # noqa: ARG005  # no-op by default
    )
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    rng: random.Random = field(
        default_factory=random.Random  # D-059 R2 fix: unseeded by default; tests inject seeded instance
    )

    def execute(self, ticker: str, window: Window) -> SentimentSnapshot:
        """Capture sentiment snapshot for `ticker` over `window` duration.

        Steps per UC-1 spec:
        1. Fetch recent posts (since = now - window.duration)
        2. Classify batch (LLM → categorical Sentiment enum)
        3. Score coordination (deterministic ensemble)
        4. Aggregate deterministic metrics (I-S1: Python only, no LLM)
        5. Construct SentimentSnapshot aggregate
        6. Persist + publish events

        Returns the persisted SentimentSnapshot.
        """
        now = self.clock()
        since = now - window.duration

        # Step 1: fetch posts
        raw_posts = self.aggregator.fetch_recent(ticker, since)
        logger.info(
            "capture_sentiment ticker=%s window=%s raw_posts=%d",
            ticker,
            window.value,
            len(raw_posts),
        )

        if not raw_posts:
            # Even with 0 posts we create a snapshot recording the absence
            classified: list[ClassifiedPost] = []
        else:
            # Step 2: classify (LLM — categorical only per BR-4)
            classified = self.classifier.classify_batch(raw_posts)

        # Step 3: coordination detection (deterministic, not LLM)
        coord_score = (
            self.coordination_detector.score(
                classified,
                [
                    CoordinationFeature.TEMPLATE_SIMILARITY,
                    CoordinationFeature.TIMING_CLUSTER,
                    CoordinationFeature.ACCOUNT_AGE_DISTRIBUTION,
                ],
            )
            if classified
            else 0.0
        )

        # Step 4: deterministic aggregation (I-S1: ALL numbers from Python)
        dist: dict[Sentiment, int] = defaultdict(int)
        sources: dict[str, int] = defaultdict(int)
        for post in classified:
            dist[post.sentiment] += 1
            sources[post.source] += 1

        # posting_velocity = posts_per_hour (I-S1: computed from counts + window)
        posting_velocity = len(classified) / window.hours if window.hours > 0 else 0.0

        # unique_posters: count distinct poster_ids (I-S1: Python set size)
        unique_posters = len({p.poster_id for p in classified})

        # top_terms: simplified frequency extraction (deterministic)
        top_terms = self._extract_top_terms(classified)

        # source_posts_sample: max 20 IDs for debugging (BR-3)
        sample_ids = [p.post_id for p in self.rng.sample(classified, min(_MAX_SAMPLE_POSTS, len(classified)))]

        # Step 5: construct aggregate
        snapshot_id = self._make_snapshot_id(ticker, now)
        snapshot = SentimentSnapshot(
            snapshot_id=snapshot_id,
            ticker=ticker,
            captured_at=now,
            window=window,
            mention_count=len(classified),
            sentiment_distribution=dict(dist) if dist else {Sentiment.NEUTRAL: 0},
            posting_velocity=posting_velocity,
            unique_posters=unique_posters,
            coordinated_posting_score=coord_score,
            sources=dict(sources),
            top_terms=tuple(top_terms),
            source_posts_sample=tuple(sample_ids),
        )

        # Step 6: persist + publish
        self.snapshot_repo.save(snapshot)

        self.publish_event(
            SentimentSnapshotCapturedEvent(
                ticker=ticker,
                window=window,
                captured_at=now,
                dominant_sentiment=snapshot.dominant_sentiment(),
                mention_count=snapshot.mention_count,
                snapshot_id=snapshot_id,
            )
        )

        # Conditional: coordination alert (BR-8 threshold 0.8)
        if coord_score >= _COORDINATION_THRESHOLD:
            pattern_desc = self._describe_coordination_pattern(classified, coord_score)
            self.publish_event(
                CoordinatedPostingDetectedEvent(
                    ticker=ticker,
                    posting_pattern=pattern_desc,  # BR-10: no poster_id/account_name
                    coordination_score=coord_score,
                    detected_at=now,
                )
            )
            logger.warning(
                "coordination_detected ticker=%s score=%.3f",
                ticker,
                coord_score,
            )

        return snapshot

    @staticmethod
    def _extract_top_terms(posts: list[ClassifiedPost]) -> list[str]:
        """Extract most common words from posts (deterministic, no LLM).

        I-S1: simple frequency count in Python.
        Returns up to 10 terms sorted by frequency descending.
        """
        freq: dict[str, int] = defaultdict(int)
        for post in posts:
            for word in post.text.split():
                if len(word) >= 3:  # skip short tokens
                    freq[word.lower()] += 1
        return [w for w, _ in sorted(freq.items(), key=lambda x: -x[1])[:10]]

    @staticmethod
    def _make_snapshot_id(ticker: str, captured_at: datetime) -> str:
        """Deterministic snapshot ID from ticker + timestamp."""
        raw = f"{ticker}:{captured_at.isoformat()}"
        return hashlib.sha256(raw.encode()).hexdigest()[:16]

    @staticmethod
    def _describe_coordination_pattern(posts: list[ClassifiedPost], score: float) -> str:
        """Generate BR-10-safe pattern description (no poster_id/account_name).

        Describes the aggregate pattern, not individuals.
        """
        bullish_count = sum(
            1 for p in posts
            if p.sentiment in (Sentiment.BULLISH, Sentiment.STRONGLY_BULLISH)
        )
        return (
            f"Potential coordinated posting detected: {bullish_count}/{len(posts)} "
            f"bullish posts with coordination_score={score:.3f}. "
            "Pattern detected, exercise caution. Flagged != confirmed pump."
        )
