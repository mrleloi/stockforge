"""PumpEvidenceSummarizer — LLM-backed pump evidence text summarizer (BC-7).

D-026 LLM Substrate Boundary — all 3 patterns applied:
  BP-S43b-1: per-role override dict (role="pump_evidence_summary" → Sonnet)
  BP-S43b-2: prose-tolerant JSON (LLM returns plain text; strip and validate)
  BP-S43b-3: gatherer-wired compute (signals + historical prepared in Python)

I-S1 enforcement:
    Regex gate: `\\d+\\s*%|approximately|roughly|around\\s+\\d+`
    Raises LlmOutputViolatesISOne if numeric patterns detected.

BR-10: evidence summary must NOT name operators/individuals.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4 (UC-3 evidence_summary).
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § d).
"""

from __future__ import annotations

import re
from collections.abc import Callable
from dataclasses import dataclass, field

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog
from packages.application.crowd.ports.sentiment_classifier_port import LlmOutputViolatesISOne
from packages.domain.crowd.signal_contribution import SignalContribution

__all__ = ["PumpEvidenceSummarizer"]

# I-S1: numeric leakage patterns to reject
_NUMERIC_LEAKAGE_PATTERN = re.compile(
    r"\d+\s*%|approximately|roughly|around\s+\d+",
    re.IGNORECASE,
)

# Default role for BP-S43b-1 per-role override
_DEFAULT_ROLE = "pump_evidence_summary"
_DEFAULT_MODEL = "claude-sonnet-4-5"


@dataclass
class PumpEvidenceSummarizer:
    """LLM-backed pump evidence summarizer implementing PumpEvidenceSummarizerPort.

    D-026 all 3 patterns applied per D-032 § (d).
    I-S1: validates LLM output has no numeric leakage before returning.
    BR-10: prompt instructs to never name operators/individuals.

    Args:
        llm_client:           Callable(model, prompt) -> str (LLM-agnostic).
        role_model_overrides: Dict of role -> model override (BP-S43b-1).
    """

    llm_client: Callable[[str, str], str]
    role_model_overrides: dict[str, str] = field(default_factory=dict)

    def summarize_pump_evidence(
        self,
        ticker: str,
        signals: list[SignalContribution],
        historical_matches: list[HistoricalAnalog],
    ) -> str:
        """Generate qualitative evidence summary for pump detection.

        BP-S43b-3: signals and historical_matches are Python-computed before LLM call.
        BP-S43b-1: uses per-role model override if configured.
        Returns stripped plain text.

        Raises LlmOutputViolatesISOne if numeric patterns detected (I-S1).
        """
        # BP-S43b-1: per-role model override
        model = self.role_model_overrides.get(_DEFAULT_ROLE, _DEFAULT_MODEL)

        # BP-S43b-3: Python-prepared prompt
        prompt = self._build_prompt(ticker, signals, historical_matches)

        # LLM call
        raw_output = self.llm_client(model, prompt)

        # Strip whitespace (BP-S43b-2: plain text, not JSON)
        summary = raw_output.strip()

        # I-S1 gate: reject numeric leakage
        if _NUMERIC_LEAKAGE_PATTERN.search(summary):
            raise LlmOutputViolatesISOne(
                f"NO LLM math: evidence summary contains numeric pattern: {summary!r}"
            )

        return summary

    @staticmethod
    def _describe_signals(signals: list[SignalContribution]) -> str:
        """Convert SignalContribution list to descriptive text (BP-S43b-3)."""
        if not signals:
            return "(no contributing signals)"
        lines = []
        for s in signals:
            lines.append(f"- {s.signal_name} (phase={s.phase.value}, weight={s.weight:.2f})")
        return "\n".join(lines)

    @staticmethod
    def _describe_historical(historical_matches: list[HistoricalAnalog]) -> str:
        """Convert HistoricalAnalog list to descriptive text (BP-S43b-3)."""
        if not historical_matches:
            return "(no historical analogs; novel pattern)"
        lines = []
        for a in historical_matches:
            lines.append(f"- {a.ticker} {a.period_start}~{a.period_end}: {a.outcome_description}")
        return "\n".join(lines)

    def _build_prompt(
        self,
        ticker: str,
        signals: list[SignalContribution],
        historical_matches: list[HistoricalAnalog],
    ) -> str:
        """Build gatherer-wired prompt from Python-computed inputs (BP-S43b-3)."""
        signals_str = self._describe_signals(signals)
        historical_str = self._describe_historical(historical_matches)

        return (
            f"You are a risk analyst summarizing pump detection evidence for {ticker}.\n"
            f"RULES:\n"
            f"- Write ONE paragraph of qualitative evidence prose\n"
            f"- NEVER include numbers, percentages, or approximate quantities\n"
            f"- NEVER name individuals, operators, or companies\n"
            f"- Frame as pattern observation, not financial advice\n\n"
            f"CONTRIBUTING SIGNALS (Python-computed):\n{signals_str}\n\n"
            f"HISTORICAL ANALOGS:\n{historical_str}\n\n"
            f"Write a qualitative evidence summary (1-3 sentences)."
        )
