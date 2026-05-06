"""PumpEvidenceSummarizerPort — Protocol for LLM pump evidence text summary (BC-7).

D-026 LLM Substrate Boundary — all 3 patterns per D-032 § (d):
  BP-S43b-1: per-role override (Sonnet for qualitative evidence summary)
  BP-S43b-2: prose-tolerant JSON (LLM may return fenced block; extract text)
  BP-S43b-3: gatherer-wired compute (PumpEvidenceGatherer prepares signals)

I-S1: LLM output is single str (evidence prose). NO numeric output.
LlmOutputViolatesISOne raised if output contains: r"\\d+\\s*%|approximately|roughly"
BR-10: summary must NOT name operators/individuals.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4 (UC-3 evidence_summary).
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § d).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog
from packages.domain.crowd.signal_contribution import SignalContribution

__all__ = ["PumpEvidenceSummarizerPort"]


@runtime_checkable
class PumpEvidenceSummarizerPort(Protocol):
    """Port for LLM-generated pump evidence summary text.

    Inputs are Python-computed (gatherer-wired); LLM only produces prose.
    """

    def summarize_pump_evidence(
        self,
        ticker: str,
        signals: list[SignalContribution],
        historical_matches: list[HistoricalAnalog],
    ) -> str:
        """Generate qualitative evidence summary for pump detection.

        Returns single string evidence prose.
        Raises LlmOutputViolatesISOne if output contains numeric patterns.
        BR-10: never names operators/individuals.

        Args:
            ticker: Stock ticker symbol.
            signals: Contributing signals from PumpPhaseClassifier.
            historical_matches: Historical analogs from HistoricalAnalogFinder.
        """
        ...
