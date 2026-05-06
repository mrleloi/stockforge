"""CounterNarrativeGeneratorPort — Protocol for LLM bear-point generation (BC-7).

D-026 LLM Substrate Boundary — all 3 patterns required per D-032 § (d) + (g):
  BP-S43b-1: per-role override dict (Sonnet for quality-driven bear-point generation)
  BP-S43b-2: prose-tolerant JSON (3-tier extractor for LLM list output)
  BP-S43b-3: gatherer-wired compute (CounterNarrativeGatherer prepares inputs)

I-S1: LLM output is list[str] (bear-point prose). NO numeric output.
LlmOutputViolatesISOne raised if output contains: r"\\d+\\s*%|approximately|roughly|around \\d+"

BR-6 MANDATORY: triggered when bullish_ratio() > 0.8 on considered ticker.
BR-10: bear_points must NOT name operators/individuals ("pattern detected, exercise caution").
Q-S53-4 IMPL: each bear-point ≤500 chars per audit-traceability.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § g).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog

__all__ = ["CounterNarrativeGeneratorPort"]


@runtime_checkable
class CounterNarrativeGeneratorPort(Protocol):
    """Port for LLM-grounded bear-point generation.

    Grounded in 3 sources per D-032 § (g):
    1. HistoricalAnalogFinder failing analogs (subsequent_return_12m < -0.10)
    2. Bullish consensus summary (from active narratives)
    3. Sector structural risks (cross-BC query; may be empty stub Phase 3 per IMPL-S53-3)
    """

    def generate(
        self,
        ticker: str,
        bullish_consensus: list[str],
        failing_analogs: list[HistoricalAnalog],
        structural_risks: list[str],
    ) -> list[str]:
        """Generate bear-point strings grounded in inputs.

        Returns list of bear-point strings (each ≤500 chars, per Q-S53-4).
        Raises LlmOutputViolatesISOne if output contains numeric patterns per I-S1.
        BR-10: never names operators/individuals in output.

        Args:
            ticker: Stock ticker symbol.
            bullish_consensus: Aggregated bullish points from active narratives.
            failing_analogs: Historical analogs with bad outcomes (return < -10%).
            structural_risks: Sector-level structural risks (may be empty Phase 3).
        """
        ...
