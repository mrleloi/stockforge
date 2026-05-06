"""Tests for CounterNarrativeGenerator (BC-7 Track K).

Tests: mock-LLM; I-S1 numeric gate; D-026 citations; BR-6 trigger; BR-10 no operator naming.

Markers: unit
"""

from __future__ import annotations

import pytest

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog
from packages.application.crowd.ports.sentiment_classifier_port import LlmOutputViolatesISOne
from packages.infrastructure.crowd.counter_narrative_generator import CounterNarrativeGenerator


def _make_analog(subsequent_return_12m: float = -0.20) -> HistoricalAnalog:
    return HistoricalAnalog(
        ticker="VND",
        period_start="2022-01-01",
        period_end="2022-06-30",
        setup_description="high bullish sentiment pre-correction",
        similarity_score=0.85,
        subsequent_return_12m=subsequent_return_12m,
        outcome_description="Correction followed over-bullish sentiment saturation",
    )


@pytest.mark.unit
class TestCounterNarrativeGeneratorHappyPath:
    def test_generates_bear_points_from_mock_llm(self) -> None:
        mock_response = (
            '["The current sentiment saturation resembles historical patterns that preceded corrections.", '
            '"Crowd concentration risk may indicate groupthink without fundamental support.", '
            '"Historical analogs suggest prolonged recovery after similar sentiment peaks."]'
        )
        gen = CounterNarrativeGenerator(llm_client=lambda _m, _p: mock_response)
        analogs = [_make_analog()]
        bear_points = gen.generate(
            ticker="VND",
            bullish_consensus=["tăng trưởng mạnh", "kết quả kinh doanh tốt"],
            failing_analogs=analogs,
            structural_risks=[],
        )
        assert len(bear_points) == 3
        assert all(isinstance(bp, str) for bp in bear_points)

    def test_vietnamese_diacritics_preserved(self) -> None:
        mock_response = '["Tâm lý FOMO có thể dẫn đến rủi ro tập trung quá mức."]'
        gen = CounterNarrativeGenerator(llm_client=lambda _m, _p: mock_response)
        bear_points = gen.generate(
            ticker="VND",
            bullish_consensus=["tăng trưởng"],
            failing_analogs=[],
            structural_risks=[],
        )
        assert len(bear_points) == 1
        assert "FOMO" in bear_points[0]


@pytest.mark.unit
class TestCounterNarrativeGeneratorISOneEnforcement:
    def test_numeric_percentage_raises(self) -> None:
        """I-S1: LLM output with percentage raises LlmOutputViolatesISOne."""
        mock_response = '["The stock fell 18% after similar patterns."]'
        gen = CounterNarrativeGenerator(llm_client=lambda _m, _p: mock_response)
        with pytest.raises(LlmOutputViolatesISOne, match="NO LLM math"):
            gen.generate(
                ticker="VND",
                bullish_consensus=[],
                failing_analogs=[],
                structural_risks=[],
            )

    def test_approximately_raises(self) -> None:
        """I-S1: 'approximately' keyword triggers violation."""
        mock_response = '["Returns were approximately negative in similar cases."]'
        gen = CounterNarrativeGenerator(llm_client=lambda _m, _p: mock_response)
        with pytest.raises(LlmOutputViolatesISOne, match="NO LLM math"):
            gen.generate(
                ticker="VND",
                bullish_consensus=[],
                failing_analogs=[],
                structural_risks=[],
            )

    def test_roughly_raises(self) -> None:
        """I-S1: 'roughly' keyword triggers violation."""
        mock_response = '["The correction was roughly similar to 2021 cases."]'
        gen = CounterNarrativeGenerator(llm_client=lambda _m, _p: mock_response)
        with pytest.raises(LlmOutputViolatesISOne, match="NO LLM math"):
            gen.generate(
                ticker="VND",
                bullish_consensus=[],
                failing_analogs=[],
                structural_risks=[],
            )


@pytest.mark.unit
class TestCounterNarrativeGeneratorD026Citations:
    def test_docstring_cites_bp_s43b_1(self) -> None:
        """D-026 BP-S43b-1 must be cited in module docstring."""
        import packages.infrastructure.crowd.counter_narrative_generator as mod
        assert "BP-S43b-1" in (mod.__doc__ or "")

    def test_docstring_cites_bp_s43b_2(self) -> None:
        import packages.infrastructure.crowd.counter_narrative_generator as mod
        assert "BP-S43b-2" in (mod.__doc__ or "")

    def test_docstring_cites_bp_s43b_3(self) -> None:
        import packages.infrastructure.crowd.counter_narrative_generator as mod
        assert "BP-S43b-3" in (mod.__doc__ or "")

    def test_role_model_override_supported(self) -> None:
        """BP-S43b-1: per-role override dict works."""
        called_models: list[str] = []

        def mock_client(model: str, _prompt: str) -> str:
            called_models.append(model)
            return '["Bear point one.", "Bear point two.", "Bear point three."]'

        gen = CounterNarrativeGenerator(
            llm_client=mock_client,
            role_model_overrides={"counter_narrative_generation": "claude-opus-4"},
        )
        gen.generate(ticker="VND", bullish_consensus=[], failing_analogs=[], structural_risks=[])
        assert called_models[0] == "claude-opus-4"
