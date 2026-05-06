"""CrowdContentGatherer — BP-S43b-3 gatherer-wired compute for sentiment classification.

D-026 Pattern BP-S43b-3 (gatherer-wired compute):
  Numbers (timestamps, mention_counts, posting_velocity, window hours) are prepared by
  this gatherer in Python BEFORE being passed to LLM. LLM receives structured context
  but NEVER computes the numbers.

I-S1: This class ensures the deterministic numeric context is built in Python.
  The LlmSentimentClassifier receives this context and passes it verbatim to the LLM
  prompt — the LLM only interprets text and outputs categorical labels.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4.
ADR: D-032 § (d) BP-S43b-3 gatherer-wired compute pattern.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from packages.domain.crowd.raw_post import RawPost
from packages.domain.crowd.value_objects.window import Window

__all__ = ["BatchContext", "CrowdContentGatherer"]


@dataclass(frozen=True)
class BatchContext:
    """Pre-computed context passed to LlmSentimentClassifier.

    All numeric fields computed by Python (I-S1).
    LLM uses this context to understand the batch but cannot modify the numbers.
    """

    ticker: str
    window: Window
    batch_size: int
    window_hours: float        # window.hours (from Python)
    from_time: datetime        # since = now - window.duration (from Python)
    captured_at: datetime      # snapshot timestamp (from Python)
    unique_sources: int        # distinct source platforms in batch (from Python)


@dataclass
class CrowdContentGatherer:
    """Prepares post batches + window metadata + ticker context for LLM classification.

    BP-S43b-3: gathers all numbers deterministically so LLM receives structured input
    without needing to compute any metrics.
    """

    def prepare_batch_context(
        self,
        posts: list[RawPost],
        ticker: str,
        window: Window,
        captured_at: datetime,
    ) -> BatchContext:
        """Build BatchContext with all numeric fields computed in Python (I-S1).

        Args:
            posts:       The batch of posts about to be classified.
            ticker:      Target ticker.
            window:      Aggregation window.
            captured_at: Snapshot timestamp (from clock, not LLM).

        Returns:
            BatchContext with pre-computed metrics.
        """
        unique_sources = len({p.source for p in posts})
        from_time = captured_at - window.duration

        return BatchContext(
            ticker=ticker,
            window=window,
            batch_size=len(posts),
            window_hours=window.hours,         # I-S1: from enum property, not LLM
            from_time=from_time,               # I-S1: computed subtraction
            captured_at=captured_at,
            unique_sources=unique_sources,     # I-S1: Python set size
        )
