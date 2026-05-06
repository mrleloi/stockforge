"""Tests for PumpEvidenceSummarizer (BC-7 Track K).

Tests: mock-LLM; I-S1 numeric gate; gatherer-wired compute.

Markers: unit
"""

from __future__ import annotations

import pytest

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog
from packages.application.crowd.ports.sentiment_classifier_port import LlmOutputViolatesISOne
from packages.domain.crowd.signal_contribution import SignalContribution
from packages.domain.crowd.value_objects.pump_phase import PumpPhase
from packages.infrastructure.crowd.pump_evidence_summarizer import PumpEvidenceSummarizer

_SIGNAL = SignalContribution(
    signal_name="volume_price_spike",
    signal_value=0.8,
    weight=0.4,
    contribution=0.4,
    phase=PumpPhase.PUMP,
)

_ANALOG = HistoricalAnalog(
    ticker="VND",
    period_start="2022-01-01",
    period_end="2022-06-30",
    setup_description="volume spike pattern",
    similarity_score=0.80,
    subsequent_return_12m=-0.15,
    outcome_description="Correction followed rapid price spike",
)


@pytest.mark.unit
class TestPumpEvidenceSummarizerHappyPath:
    def test_generates_summary_text(self) -> None:
        mock_response = "Pattern detected: volume and price signals suggest elevated risk. Historical analogs indicate caution warranted. Exercise careful review before any position changes."
        summarizer = PumpEvidenceSummarizer(llm_client=lambda _m, _p: mock_response)
        result = summarizer.summarize_pump_evidence(
            ticker="VND",
            signals=[_SIGNAL],
            historical_matches=[_ANALOG],
        )
        assert isinstance(result, str)
        assert len(result) > 10

    def test_returns_stripped_text(self) -> None:
        mock_response = "  Pattern detected with elevated volume signals.  "
        summarizer = PumpEvidenceSummarizer(llm_client=lambda _m, _p: mock_response)
        result = summarizer.summarize_pump_evidence("VND", [_SIGNAL], [])
        assert not result.startswith(" ")
        assert not result.endswith(" ")


@pytest.mark.unit
class TestPumpEvidenceSummarizerISOneEnforcement:
    def test_numeric_percentage_raises(self) -> None:
        """I-S1: numeric percentage in LLM output raises LlmOutputViolatesISOne."""
        mock_response = "The volume increased by 40% above the normal range."
        summarizer = PumpEvidenceSummarizer(llm_client=lambda _m, _p: mock_response)
        with pytest.raises(LlmOutputViolatesISOne, match="NO LLM math"):
            summarizer.summarize_pump_evidence("VND", [_SIGNAL], [])

    def test_approximately_raises(self) -> None:
        mock_response = "Volume was approximately three times normal levels."
        summarizer = PumpEvidenceSummarizer(llm_client=lambda _m, _p: mock_response)
        with pytest.raises(LlmOutputViolatesISOne, match="NO LLM math"):
            summarizer.summarize_pump_evidence("VND", [_SIGNAL], [])


@pytest.mark.unit
class TestPumpEvidenceSummarizerGathererWired:
    def test_signals_description_in_prompt(self) -> None:
        """BP-S43b-3: signal descriptions prepared in Python before LLM call."""
        prompts_seen: list[str] = []

        def mock_client(_model: str, prompt: str) -> str:
            prompts_seen.append(prompt)
            return "Pattern detected from Python-computed signals."

        summarizer = PumpEvidenceSummarizer(llm_client=mock_client)
        summarizer.summarize_pump_evidence("VND", [_SIGNAL], [])
        assert len(prompts_seen) == 1
        # Signal name should appear in the Python-prepared prompt
        assert "volume_price_spike" in prompts_seen[0]
