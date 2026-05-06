"""HistoricalAnalogFinder — embedding-based historical pump pattern matcher (BC-7).

IMPL-S53-1 decision: OpenAI text-embedding-3-small per architecture.md § LLM.
Jaccard fallback for tests (no API key required).

D-032 § (h): finds top-k historical pump patterns by cosine similarity.
BR-9: returns [] when historical_setups is empty (cold-start behavior).
  → DetectPumpPhaseUseCase caps confidence at 0.6 for novel patterns.

I-S1: similarity scores computed in Python (cosine distance); not from LLM.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § h).
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass, field

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog

__all__ = ["HistoricalAnalogFinder"]


def _jaccard_similarity(text_a: str, text_b: str) -> float:
    """Compute Jaccard similarity between two strings (token-level).

    Fallback for when no embedding_client is available (tests/cold-start).
    I-S1: pure Python; no LLM.
    """
    tokens_a = set(text_a.lower().split())
    tokens_b = set(text_b.lower().split())
    if not tokens_a and not tokens_b:
        return 1.0
    intersection = len(tokens_a & tokens_b)
    union = len(tokens_a | tokens_b)
    return intersection / union if union > 0 else 0.0


@dataclass
class HistoricalAnalogFinder:
    """HistoricalAnalogFinder implementing HistoricalAnalogFinderPort.

    Uses embedding similarity when embedding_client is provided.
    Falls back to Jaccard similarity for tests / cold-start.

    Args:
        historical_setups:  List of HistoricalAnalog records to search against.
        embedding_client:   Callable(model, text) -> list[float] (OpenAI-compatible).
                            None → Jaccard fallback.
        embedding_model:    Model name for embedding (default: text-embedding-3-small).
    """

    historical_setups: list[HistoricalAnalog] = field(default_factory=list)
    embedding_client: Callable[[str, str], list[float]] | None = None
    embedding_model: str = "text-embedding-3-small"

    def find(
        self,
        ticker: str,  # noqa: ARG002
        setup_description: str,
        top_k: int = 5,
    ) -> list[HistoricalAnalog]:
        """Find top-k historical analogs by similarity.

        BR-9: returns [] when historical_setups is empty.
        Uses embedding cosine similarity if embedding_client provided, else Jaccard.

        Args:
            ticker: Stock ticker symbol (reserved for future per-ticker filtering).
            setup_description: Textual description of current setup.
            top_k: Maximum number of analogs to return.
        """
        _ = ticker  # reserved for future per-ticker filtering (BR-9)
        if not self.historical_setups:
            return []

        if self.embedding_client is not None:
            return self._find_by_embedding(setup_description, top_k)
        return self._find_by_jaccard(setup_description, top_k)

    def _find_by_jaccard(
        self, setup_description: str, top_k: int
    ) -> list[HistoricalAnalog]:
        """Jaccard similarity fallback (tests / no embedding client).

        I-S1: pure Python set operations; no LLM.
        """
        scored: list[tuple[float, HistoricalAnalog]] = []
        for analog in self.historical_setups:
            score = _jaccard_similarity(setup_description, analog.setup_description)
            scored.append((score, analog))

        scored.sort(key=lambda x: x[0], reverse=True)
        results = []
        for score, analog in scored[:top_k]:
            # Return new HistoricalAnalog with updated similarity_score
            results.append(
                HistoricalAnalog(
                    ticker=analog.ticker,
                    period_start=analog.period_start,
                    period_end=analog.period_end,
                    setup_description=analog.setup_description,
                    similarity_score=score,
                    subsequent_return_12m=analog.subsequent_return_12m,
                    outcome_description=analog.outcome_description,
                )
            )
        return results

    def _find_by_embedding(
        self, setup_description: str, top_k: int
    ) -> list[HistoricalAnalog]:
        """Embedding cosine similarity (OpenAI text-embedding-3-small).

        I-S1: cosine distance computed in Python; not from LLM output.
        """
        assert self.embedding_client is not None

        query_vec = self.embedding_client(self.embedding_model, setup_description)

        scored: list[tuple[float, HistoricalAnalog]] = []
        for analog in self.historical_setups:
            analog_vec = self.embedding_client(self.embedding_model, analog.setup_description)
            score = _cosine_similarity(query_vec, analog_vec)
            scored.append((score, analog))

        scored.sort(key=lambda x: x[0], reverse=True)
        results = []
        for score, analog in scored[:top_k]:
            results.append(
                HistoricalAnalog(
                    ticker=analog.ticker,
                    period_start=analog.period_start,
                    period_end=analog.period_end,
                    setup_description=analog.setup_description,
                    similarity_score=score,
                    subsequent_return_12m=analog.subsequent_return_12m,
                    outcome_description=analog.outcome_description,
                )
            )
        return results


def _cosine_similarity(vec_a: list[float], vec_b: list[float]) -> float:
    """Compute cosine similarity between two float vectors.

    I-S1: pure Python arithmetic; no LLM.
    """
    if not vec_a or not vec_b or len(vec_a) != len(vec_b):
        return 0.0
    dot: float = sum(a * b for a, b in zip(vec_a, vec_b, strict=False))
    norm_a: float = sum(a * a for a in vec_a) ** 0.5
    norm_b: float = sum(b * b for b in vec_b) ** 0.5
    if norm_a == 0.0 or norm_b == 0.0:
        return 0.0
    return dot / (norm_a * norm_b)
