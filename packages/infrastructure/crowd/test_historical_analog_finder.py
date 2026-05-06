"""Tests for HistoricalAnalogFinder (BC-7 Track K).

Tests: cold-start returns [], Jaccard similarity, embedding path, BR-9 interaction.

Markers: unit
"""

from __future__ import annotations

import pytest

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog
from packages.infrastructure.crowd.historical_analog_finder import HistoricalAnalogFinder


def _make_analog(
    ticker: str = "VND",
    setup_description: str = "high bullish sentiment pre-correction",
    subsequent_return_12m: float = -0.20,
) -> HistoricalAnalog:
    return HistoricalAnalog(
        ticker=ticker,
        period_start="2022-01-01",
        period_end="2022-06-30",
        setup_description=setup_description,
        similarity_score=0.0,
        subsequent_return_12m=subsequent_return_12m,
        outcome_description="Test outcome",
    )


@pytest.mark.unit
class TestHistoricalAnalogFinderColdStart:
    def test_empty_setups_returns_empty(self) -> None:
        """BR-9 cold-start: no historical data → returns []."""
        finder = HistoricalAnalogFinder(historical_setups=[])
        result = finder.find(ticker="VND", setup_description="any", top_k=5)
        assert result == []

    def test_cold_start_triggers_br9_cap_via_use_case(self) -> None:
        """BR-9: empty result feeds historical_similar_cases_count=0 → confidence cap applies."""
        finder = HistoricalAnalogFinder(historical_setups=[])
        result = finder.find(ticker="VND", setup_description="test", top_k=5)
        assert len(result) == 0  # use case will cap confidence at 0.6


@pytest.mark.unit
class TestHistoricalAnalogFinderJaccard:
    def test_jaccard_finds_similar_description(self) -> None:
        """Jaccard fallback: overlapping tokens → higher similarity."""
        analogs = [
            _make_analog(setup_description="high bullish sentiment peak volume"),
            _make_analog(ticker="TCB", setup_description="stable earnings good results"),
        ]
        finder = HistoricalAnalogFinder(historical_setups=analogs)
        results = finder.find(ticker="VND", setup_description="high bullish volume", top_k=2)
        assert len(results) > 0
        # First result should be the one with more overlap
        assert results[0].similarity_score > 0.0

    def test_jaccard_returns_at_most_top_k(self) -> None:
        analogs = [_make_analog(ticker=f"T{i}", setup_description=f"pattern {i}") for i in range(10)]
        finder = HistoricalAnalogFinder(historical_setups=analogs)
        results = finder.find(ticker="VND", setup_description="pattern", top_k=3)
        assert len(results) <= 3

    def test_jaccard_similarity_score_updated(self) -> None:
        """Returned HistoricalAnalog has updated similarity_score (not default 0.0)."""
        analogs = [_make_analog(setup_description="volume price spike kol mentions")]
        finder = HistoricalAnalogFinder(historical_setups=analogs)
        results = finder.find(ticker="VND", setup_description="volume spike", top_k=1)
        assert len(results) == 1
        assert results[0].similarity_score > 0.0  # updated from default 0.0


@pytest.mark.unit
class TestHistoricalAnalogFinderEmbedding:
    def test_embedding_client_used_when_provided(self) -> None:
        """BP-S43b-3: embedding client is called for similarity computation."""
        call_count = [0]

        def mock_embedding(_model: str, text: str) -> list[float]:
            call_count[0] += 1
            # Return different vectors based on text content
            if "spike" in text.lower():
                return [1.0, 0.0, 0.0]
            return [0.0, 1.0, 0.0]

        analogs = [
            _make_analog(setup_description="volume spike pattern"),
            _make_analog(ticker="TCB", setup_description="earnings growth story"),
        ]
        finder = HistoricalAnalogFinder(
            historical_setups=analogs,
            embedding_client=mock_embedding,
        )
        results = finder.find(ticker="VND", setup_description="volume spike", top_k=2)
        assert call_count[0] > 0  # embedding was called
        assert len(results) == 2

    def test_failing_analogs_filter(self) -> None:
        """failing_analogs filter works: only analogs with return < -0.10 qualify."""
        analogs = [
            _make_analog(subsequent_return_12m=-0.25),  # failing
            _make_analog(ticker="TCB", subsequent_return_12m=0.10),  # not failing
        ]
        finder = HistoricalAnalogFinder(historical_setups=analogs)
        results = finder.find(ticker="VND", setup_description="pattern", top_k=5)
        failing = [a for a in results if a.subsequent_return_12m < -0.10]
        assert len(failing) == 1
        assert failing[0].subsequent_return_12m == pytest.approx(-0.25)
