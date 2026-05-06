"""HistoricalAnalogFinderPort — Protocol for embedding-based historical pattern matching (BC-7).

D-032 § (h): HistoricalAnalogFinder uses OpenAI text-embedding-3-small embeddings
(architecture.md § LLM) with cosine similarity to find matching pump patterns.

BR-9: if no historical analogs found → confidence capped at 0.6 (novel pattern).
Cold-start behavior: returns [] when historical_setups is empty.

I-S1: similarity scores are cosine distance (Python/numpy); no LLM generates them.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § h).
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol, runtime_checkable

__all__ = ["HistoricalAnalog", "HistoricalAnalogFinderPort"]


@dataclass(frozen=True)
class HistoricalAnalog:
    """Record of a historical pump pattern similar to current setup.

    I-S1: similarity_score computed by cosine distance in Python; not LLM output.
    I-S2: period_start + period_end provide provenance for historical data.
    """

    ticker: str
    period_start: str         # ISO date string e.g. "2022-01-01"
    period_end: str           # ISO date string e.g. "2022-06-30"
    setup_description: str    # textual description used for embedding
    similarity_score: float   # cosine similarity [0, 1] — Python-computed
    subsequent_return_12m: float  # 12-month return after pump event (e.g. -0.20 = -20%)
    outcome_description: str  # human-readable outcome summary


@runtime_checkable
class HistoricalAnalogFinderPort(Protocol):
    """Port for finding historical pump patterns similar to current setup.

    Implementation uses embedding similarity (D-032 § h).
    BR-9: returns [] on cold start; caller must handle empty list.
    """

    def find(
        self,
        ticker: str,
        setup_description: str,
        top_k: int = 5,
    ) -> list[HistoricalAnalog]:
        """Find top-k historical analogs by embedding similarity.

        Returns empty list on cold start (no historical data yet).
        BR-9: empty return → confidence capped at 0.6 in DetectPumpPhaseUseCase.

        Args:
            ticker: Stock ticker symbol.
            setup_description: Textual description of current pump setup for embedding.
            top_k: Maximum number of analogs to return.
        """
        ...
