"""SentimentClassifierPort — Protocol for LLM-based Vietnamese sentiment classification.

BR-4: LLM output MUST be categorical Sentiment enum only.
I-S1: If LLM returns any numeric string (e.g. "80%"), raise LlmOutputViolatesISOne.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-1 + B.4.
ADR: D-032 § (d) LLM substrate boundary.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Protocol, runtime_checkable

from packages.domain.crowd.raw_post import RawPost
from packages.domain.crowd.value_objects.sentiment import Sentiment

__all__ = ["ClassifiedPost", "LlmOutputViolatesISOne", "SentimentClassifierPort"]


class LlmOutputViolatesISOne(RuntimeError):
    """Raised when LLM output contains numeric content instead of categorical sentiment.

    Per I-S1 (NO LLM math): any numeric string in LLM sentiment output is a hard error.
    Examples of forbidden LLM output: "80%", "0.75", "approximately 18%".
    The classifier MUST raise this exception rather than silently coerce.
    """


@dataclass(frozen=True)
class ClassifiedPost:
    """A RawPost with a classified Sentiment label.

    poster_id is retained here for coordination detection (account-age + timing features)
    but MUST NOT appear in CoordinationDetected event payload per BR-10.
    """

    post_id: str
    ticker: str
    source: str
    source_url: str
    posted_at: datetime
    text: str
    poster_id: str
    account_age_days: int | None
    sentiment: Sentiment


@runtime_checkable
class SentimentClassifierPort(Protocol):
    """Protocol for LLM sentiment classifier.

    Concrete implementation: LlmSentimentClassifier in packages/infrastructure/crowd/.
    Batched: 50 posts per LLM call (cost-efficient per D-032 § d).
    """

    def classify_batch(self, posts: list[RawPost]) -> list[ClassifiedPost]:
        """Classify a batch of raw posts into categorical Sentiment levels.

        Returns one ClassifiedPost per input RawPost in the same order.
        Raises LlmOutputViolatesISOne if LLM returns numeric content.
        Raises RuntimeError if batch is empty.

        BR-4 contract: returned ClassifiedPost.sentiment is ALWAYS a Sentiment enum member.
        Never a float, never a percentage string, never a score.
        """
        ...
