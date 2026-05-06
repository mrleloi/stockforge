"""CoordinationDetectorPort — Protocol for 3-feature coordination detection (BC-7).

D-032 § (h): 3-feature ensemble (TEMPLATE_SIMILARITY + TIMING_CLUSTER +
ACCOUNT_AGE_DISTRIBUTION). Coordination score in [0, 1]. Conservative threshold
≥ 0.8 per BR-8 before flagging.

BR-10: CoordinationDetected event payload CONSTITUTIONALLY FORBIDS poster_id,
account_name, individual post content, or operator names.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-1 + B.4.
ADR: D-032 § (h).
"""

from __future__ import annotations

from enum import StrEnum
from typing import Protocol, runtime_checkable

from packages.application.crowd.ports.sentiment_classifier_port import ClassifiedPost

__all__ = ["ClassifiedPost", "CoordinationDetectorPort", "CoordinationFeature"]


class CoordinationFeature(StrEnum):
    """3 feature dimensions for coordination detection (D-032 § h verbatim).

    TEMPLATE_SIMILARITY: embedding-based cosine ≥ 0.9 within 1h sliding window
    TIMING_CLUSTER: >5 accounts post within 3-min window, ≥3 occurrences in 24h
    ACCOUNT_AGE_DISTRIBUTION: >50% bullish posters with account < 30 days old
    """

    TEMPLATE_SIMILARITY = "template_similarity"
    TIMING_CLUSTER = "timing_cluster"
    ACCOUNT_AGE_DISTRIBUTION = "account_age_distribution"


@runtime_checkable
class CoordinationDetectorPort(Protocol):
    """Protocol for coordination pattern detector.

    Concrete implementation: CoordinationDetector in packages/infrastructure/crowd/.
    Score is DETERMINISTIC Python (not LLM) — I-S1 enforced.
    """

    def score(
        self,
        posts: list[ClassifiedPost],
        features: list[CoordinationFeature],
    ) -> float:
        """Compute coordination score in [0.0, 1.0] for the given post set.

        Returns 0.0 if posts is empty or no coordination pattern detected.
        Returns value ≥ 0.8 only when strong coordination signal is present (BR-8).
        Score is DETERMINISTIC: same posts + features → same score (D-032 § h).

        I-S1: Score computed by Python ensemble, not LLM. LLM NEVER outputs this number.
        BR-10: This method never uses or returns poster_id/account_name fields.
        """
        ...
