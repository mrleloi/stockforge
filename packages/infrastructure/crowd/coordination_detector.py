"""CoordinationDetector — 3-feature ensemble coordination detection (BC-7).

D-032 § (h): 3-feature ensemble (TEMPLATE_SIMILARITY + TIMING_CLUSTER +
ACCOUNT_AGE_DISTRIBUTION). Score in [0, 1]. Conservative threshold ≥ 0.8 per BR-8.

Feature descriptions (verbatim from spec § B.4 + D-032 § h):
1. TEMPLATE_SIMILARITY: embedding-based cosine ≥ 0.9 within 1h sliding window.
   Flag if >10 posts with cosine_similarity ≥ 0.9 within 1h.
   Default weight: 0.4
2. TIMING_CLUSTER: flag if >5 accounts post within 3-min window, ≥3 occurrences in 24h.
   Default weight: 0.3
3. ACCOUNT_AGE_DISTRIBUTION: flag if >50% bullish posters are <30-day-old accounts.
   Default weight: 0.3

BR-10 NO public accusations:
   CoordinationDetected payload CONSTITUTIONALLY FORBIDS poster_id, account_name,
   operator names. This class NEVER exposes individual identity in scores/descriptions.
   Framing: "pattern detected, exercise caution" — never names operators.

I-S1: Score computed deterministically by Python weighted ensemble.
   LLM NEVER judges coordination (D-032 § H2 rejected).

Score is DETERMINISTIC: same posts + same features → identical score.
No randomness in ensemble computation (per BR-8 reproducibility requirement).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-1 + B.4.
ADR: D-032 § (h).
"""

from __future__ import annotations

import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import timedelta

from packages.application.crowd.ports.coordination_detector_port import (
    ClassifiedPost,
    CoordinationFeature,
)
from packages.domain.crowd.value_objects.sentiment import Sentiment

__all__ = ["CoordinationDetector", "CoordinationDetectorConfig"]

logger = logging.getLogger(__name__)

# D-032 § h: default ensemble weights (must sum to 1.0)
_DEFAULT_WEIGHTS: dict[CoordinationFeature, float] = {
    CoordinationFeature.TEMPLATE_SIMILARITY: 0.4,
    CoordinationFeature.TIMING_CLUSTER: 0.3,
    CoordinationFeature.ACCOUNT_AGE_DISTRIBUTION: 0.3,
}

# Template similarity thresholds
_TEMPLATE_SIM_POSTS_THRESHOLD = 10   # >10 similar posts within window
_TEMPLATE_SIM_WINDOW_HOURS = 1.0     # 1h sliding window
_TEMPLATE_SIM_COSINE_THRESHOLD = 0.9  # cosine similarity threshold

# Timing cluster thresholds
_TIMING_CLUSTER_ACCOUNTS = 5         # >5 accounts within 3-min window
_TIMING_CLUSTER_WINDOW_MINUTES = 3
_TIMING_CLUSTER_OCCURRENCES = 3      # ≥3 occurrences in 24h

# Account age thresholds
_ACCOUNT_AGE_BULLISH_FRACTION = 0.5  # >50% bullish posters
_ACCOUNT_AGE_THRESHOLD_DAYS = 30     # <30 days old


@dataclass(frozen=True)
class CoordinationDetectorConfig:
    """Tunable thresholds for CoordinationDetector ensemble.

    Defaults match spec § B.4 + D-032 § h verbatim.
    Weight tuning deferred to Year 2 outer-loop activation per spec 005.
    """

    weights: dict[CoordinationFeature, float] = field(
        default_factory=lambda: dict(_DEFAULT_WEIGHTS)
    )
    template_sim_posts_threshold: int = _TEMPLATE_SIM_POSTS_THRESHOLD
    template_sim_window_hours: float = _TEMPLATE_SIM_WINDOW_HOURS
    timing_cluster_accounts: int = _TIMING_CLUSTER_ACCOUNTS
    timing_cluster_window_minutes: int = _TIMING_CLUSTER_WINDOW_MINUTES
    timing_cluster_occurrences: int = _TIMING_CLUSTER_OCCURRENCES
    account_age_bullish_fraction: float = _ACCOUNT_AGE_BULLISH_FRACTION
    account_age_threshold_days: int = _ACCOUNT_AGE_THRESHOLD_DAYS


@dataclass
class CoordinationDetector:
    """3-feature deterministic coordination detector implementing CoordinationDetectorPort.

    Args:
        config:              Tunable thresholds (default: spec verbatim).
        embedding_client:    Callable(texts) -> list[list[float]].
                             Inject mock in tests. None → disable TEMPLATE_SIMILARITY feature.
    """

    config: CoordinationDetectorConfig = field(
        default_factory=CoordinationDetectorConfig
    )
    embedding_client: Callable[[list[str]], list[list[float]]] | None = None

    def score(
        self,
        posts: list[ClassifiedPost],
        features: list[CoordinationFeature],
    ) -> float:
        """Compute coordination score in [0.0, 1.0].

        I-S1: DETERMINISTIC Python computation. NOT LLM.
        BR-10: never uses poster_id in output; only aggregate pattern signals.

        Returns 0.0 for empty post list.
        """
        if not posts:
            return 0.0

        feature_flags: dict[CoordinationFeature, bool] = {}

        for feature in features:
            if feature is CoordinationFeature.TEMPLATE_SIMILARITY:
                feature_flags[feature] = self._check_template_similarity(posts)
            elif feature is CoordinationFeature.TIMING_CLUSTER:
                feature_flags[feature] = self._check_timing_cluster(posts)
            elif feature is CoordinationFeature.ACCOUNT_AGE_DISTRIBUTION:
                feature_flags[feature] = self._check_account_age_distribution(posts)

        # Weighted ensemble (I-S1: deterministic float arithmetic)
        score = sum(
            self.config.weights.get(feature, 0.0)
            for feature, flagged in feature_flags.items()
            if flagged
        )

        # Clamp to [0, 1]
        score = min(1.0, max(0.0, score))

        logger.info(
            "coordination_detector posts=%d features=%s flags=%s score=%.3f",
            len(posts),
            [f.value for f in features],
            {f.value: v for f, v in feature_flags.items()},
            score,
        )
        return score

    def _check_template_similarity(self, posts: list[ClassifiedPost]) -> bool:
        """TEMPLATE_SIMILARITY feature: >10 posts with cosine_sim ≥ 0.9 within 1h.

        If embedding_client is None (no API key in tests), falls back to
        simple Jaccard similarity on word sets (approximation for unit tests).

        BR-10: operates on post TEXT only; poster_id never used in similarity.
        """
        if self.embedding_client is not None:
            return self._check_template_similarity_embedding(posts)
        return self._check_template_similarity_jaccard(posts)

    def _check_template_similarity_embedding(
        self, posts: list[ClassifiedPost]
    ) -> bool:
        """Embedding-based cosine similarity (requires embedding_client)."""
        embed_fn = self.embedding_client
        if embed_fn is None:
            return False
        texts = [p.text for p in posts]
        embeddings = embed_fn(texts)

        # Sliding 1h window similarity check
        window_td = timedelta(hours=self.config.template_sim_window_hours)
        similar_pairs = 0

        for i, post_i in enumerate(posts):
            for j, post_j in enumerate(posts):
                if j <= i:
                    continue
                time_diff = abs((post_i.posted_at - post_j.posted_at).total_seconds())
                if time_diff > window_td.total_seconds():
                    continue
                cosine = self._cosine_similarity(embeddings[i], embeddings[j])
                if cosine >= self.config.template_sim_window_hours:
                    similar_pairs += 1

        return similar_pairs > self.config.template_sim_posts_threshold

    def _check_template_similarity_jaccard(self, posts: list[ClassifiedPost]) -> bool:
        """Jaccard similarity fallback when no embedding client (unit test mode)."""
        window_td = timedelta(hours=self.config.template_sim_window_hours)
        similar_pairs = 0

        word_sets = [set(p.text.lower().split()) for p in posts]

        for i, post_i in enumerate(posts):
            for j in range(i + 1, len(posts)):
                post_j = posts[j]
                time_diff = abs((post_i.posted_at - post_j.posted_at).total_seconds())
                if time_diff > window_td.total_seconds():
                    continue
                intersection = len(word_sets[i] & word_sets[j])
                union = len(word_sets[i] | word_sets[j])
                jaccard = intersection / union if union > 0 else 0.0
                if jaccard >= _TEMPLATE_SIM_COSINE_THRESHOLD:
                    similar_pairs += 1

        return similar_pairs > self.config.template_sim_posts_threshold

    def _check_timing_cluster(self, posts: list[ClassifiedPost]) -> bool:
        """TIMING_CLUSTER feature: >5 accounts post within 3-min window, ≥3 occurrences.

        BR-10: we count accounts per window — never expose which accounts.
        """
        window_td = timedelta(minutes=self.config.timing_cluster_window_minutes)
        sorted_posts = sorted(posts, key=lambda p: p.posted_at)

        occurrences = 0
        for i, anchor in enumerate(sorted_posts):
            accounts_in_window = {anchor.poster_id}
            for j in range(i + 1, len(sorted_posts)):
                time_diff = (sorted_posts[j].posted_at - anchor.posted_at).total_seconds()
                if time_diff > window_td.total_seconds():
                    break
                accounts_in_window.add(sorted_posts[j].poster_id)

            if len(accounts_in_window) > self.config.timing_cluster_accounts:
                occurrences += 1

        return occurrences >= self.config.timing_cluster_occurrences

    def _check_account_age_distribution(self, posts: list[ClassifiedPost]) -> bool:
        """ACCOUNT_AGE_DISTRIBUTION: >50% of bullish posters have accounts <30 days old.

        BR-10: fraction-based aggregate metric; no individual account identification.
        Skips accounts where account_age_days is None (unknown — can't flag).
        """
        bullish_sentiments = {Sentiment.BULLISH, Sentiment.STRONGLY_BULLISH}
        bullish_posts_with_age = [
            p for p in posts
            if p.sentiment in bullish_sentiments and p.account_age_days is not None
        ]

        if not bullish_posts_with_age:
            return False

        young_account_count = sum(
            1 for p in bullish_posts_with_age
            if p.account_age_days is not None
            and p.account_age_days < self.config.account_age_threshold_days
        )
        fraction = young_account_count / len(bullish_posts_with_age)
        return fraction > self.config.account_age_bullish_fraction

    @staticmethod
    def _cosine_similarity(vec_a: list[float], vec_b: list[float]) -> float:
        """Compute cosine similarity between two embedding vectors (I-S1: Python math)."""
        dot: float = sum(a * b for a, b in zip(vec_a, vec_b, strict=False))
        norm_a: float = float(sum(a * a for a in vec_a)) ** 0.5
        norm_b: float = float(sum(b * b for b in vec_b)) ** 0.5
        if norm_a == 0.0 or norm_b == 0.0:
            return 0.0
        return float(dot / (norm_a * norm_b))
