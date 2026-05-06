"""CounterNarrativeGenerator — LLM-backed bear-point generator (BC-7).

D-026 LLM Substrate Boundary — all 3 patterns applied:
  BP-S43b-1: per-role override dict (role="counter_narrative_generation" → Sonnet)
  BP-S43b-2: prose-tolerant JSON (3-tier extraction: fenced → first '[' → empty fallback)
  BP-S43b-3: gatherer-wired compute (analog details + bullish consensus prepared in Python)

I-S1 enforcement:
    Regex gate on LLM output for numeric leakage:
    Pattern: r"\\d+\\s*%|approximately|roughly|around \\d+"
    Raises LlmOutputViolatesISOne if matched.

BR-10 enforcement:
    Regex gate on output for operator/individual naming:
    Pattern: `by\\s+[A-Z][a-z]+|from\\s+[A-Z][a-z]+\\s+(?:company|group|fund)`
    LLM prompt instructs: "NEVER name individuals, operators, or companies; frame as patterns."

Q-S53-4 IMPL: each bear-point capped at 500 chars.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § g).
"""

from __future__ import annotations

import json
import re
from collections.abc import Callable
from dataclasses import dataclass, field

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog
from packages.application.crowd.ports.sentiment_classifier_port import LlmOutputViolatesISOne

__all__ = ["CounterNarrativeGenerator"]

# I-S1: numeric leakage patterns to reject
_NUMERIC_LEAKAGE_PATTERN = re.compile(
    r"\d+\s*%|approximately|roughly|around\s+\d+",
    re.IGNORECASE,
)

# BR-10: individual/operator naming patterns to reject
_OPERATOR_NAMING_PATTERN = re.compile(
    r"by\s+[A-Z][a-z]+|from\s+[A-Z][a-z]+\s+(?:company|group|fund)",
    re.IGNORECASE,
)

# Default role for BP-S43b-1 per-role override
_DEFAULT_ROLE = "counter_narrative_generation"
_DEFAULT_MODEL = "claude-sonnet-4-5"

# Q-S53-4: max chars per bear point
_MAX_BEAR_POINT_CHARS = 500


@dataclass
class CounterNarrativeGenerator:
    """LLM-backed bear-point generator implementing CounterNarrativeGeneratorPort.

    D-026 all 3 patterns applied per D-032 § (g).
    I-S1: validates LLM output has no numeric leakage before returning.
    BR-10: validates LLM output has no operator/individual naming.

    Args:
        llm_client:           Callable(model, prompt) -> str (LLM-agnostic).
        role_model_overrides: Dict of role -> model override (BP-S43b-1).
    """

    llm_client: Callable[[str, str], str]
    role_model_overrides: dict[str, str] = field(default_factory=dict)

    def generate(
        self,
        ticker: str,
        bullish_consensus: list[str],
        failing_analogs: list[HistoricalAnalog],
        structural_risks: list[str],
    ) -> list[str]:
        """Generate bear-point strings grounded in Python-computed inputs.

        BP-S43b-3: all inputs are Python-computed before LLM call.
        BP-S43b-1: uses per-role model override if configured.
        BP-S43b-2: 3-tier JSON extraction for LLM output.

        Raises LlmOutputViolatesISOne if output contains numeric patterns (I-S1).

        Returns list of bear-point strings (each ≤500 chars, Q-S53-4).
        """
        # BP-S43b-1: per-role model override
        model = self.role_model_overrides.get(_DEFAULT_ROLE, _DEFAULT_MODEL)

        # BP-S43b-3: gatherer-wired prompt construction (Python, not LLM)
        prompt = self._build_prompt(ticker, bullish_consensus, failing_analogs, structural_risks)

        # LLM call
        raw_output = self.llm_client(model, prompt)

        # BP-S43b-2: 3-tier JSON extraction
        bear_points = self._extract_bear_points(raw_output)

        # I-S1 gate: reject numeric leakage
        for bp in bear_points:
            if _NUMERIC_LEAKAGE_PATTERN.search(bp):
                raise LlmOutputViolatesISOne(
                    f"NO LLM math: bear-point contains numeric pattern: {bp!r}"
                )

        # BR-10 gate: reject operator/individual naming (best-effort regex)
        for bp in bear_points:
            if _OPERATOR_NAMING_PATTERN.search(bp):
                raise LlmOutputViolatesISOne(
                    f"BR-10: bear-point names operator/individual: {bp!r}"
                )

        # Q-S53-4: cap each bear point at 500 chars
        return [bp[:_MAX_BEAR_POINT_CHARS] for bp in bear_points]

    def _build_prompt(
        self,
        ticker: str,
        bullish_consensus: list[str],
        failing_analogs: list[HistoricalAnalog],
        structural_risks: list[str],
    ) -> str:
        """Build gatherer-wired prompt from Python-computed inputs (BP-S43b-3)."""
        bullish_str = "\n".join(f"- {pt}" for pt in bullish_consensus) or "(none)"
        analog_str = (
            "\n".join(
                f"- {a.ticker} {a.period_start}~{a.period_end}: {a.outcome_description}"
                for a in failing_analogs
            )
            or "(none)"
        )
        risks_str = "\n".join(f"- {r}" for r in structural_risks) or "(none)"

        return (
            f"You are a risk analyst generating bear-point considerations for {ticker}.\n"
            f"RULES:\n"
            f"- Output a JSON array of strings (bear points only)\n"
            f"- NEVER include numbers, percentages, or approximate quantities\n"
            f"- NEVER name individuals, operators, or companies; frame as patterns\n"
            f"- Each point must be ≤500 characters\n"
            f"- Frame as risk considerations, not sell recommendations\n\n"
            f"CONTEXT (Python-computed):\n"
            f"Bullish consensus points:\n{bullish_str}\n\n"
            f"Failing historical analogs:\n{analog_str}\n\n"
            f"Structural risks:\n{risks_str}\n\n"
            f"Generate 3-5 bear-point considerations as a JSON array of strings."
        )

    @staticmethod
    def _extract_bear_points(raw_output: str) -> list[str]:
        """3-tier JSON array extraction (BP-S43b-2).

        Tier 1: Try fenced code block extraction.
        Tier 2: Try first '[' ... ']' substring.
        Tier 3: Return empty list as safe fallback.
        """
        # Tier 1: fenced block
        fenced_match = re.search(r"```(?:json)?\s*(\[.*?\])\s*```", raw_output, re.DOTALL)
        if fenced_match:
            try:
                result = json.loads(fenced_match.group(1))
                if isinstance(result, list):
                    return [str(item) for item in result]
            except (json.JSONDecodeError, ValueError):
                pass

        # Tier 2: first array
        bracket_start = raw_output.find("[")
        bracket_end = raw_output.rfind("]")
        if bracket_start != -1 and bracket_end > bracket_start:
            try:
                result = json.loads(raw_output[bracket_start : bracket_end + 1])
                if isinstance(result, list):
                    return [str(item) for item in result]
            except (json.JSONDecodeError, ValueError):
                pass

        # Tier 3: empty fallback
        return []
