"""BullPerspectiveAgent — concrete BULL LLMPerspectivePort implementation.

Wraps a ClaudeLLMPerspectiveAdapter with the BULL system prompt (spec § B.5.2).
BULL seeks credible reasons a long position might be warranted — advocacy stance,
grounded in data, never using banned verbs (buy/sell/recommend/should).

Post-LLM validation mirrors bear_agent.py: JSON parse → GroundedPoint validation
→ Jaccard distinctness filter.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.5.2.
"""

from __future__ import annotations

import json
import logging
from decimal import Decimal

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import (
    GroundedPoint,
    GroundedPointInvariantError,
)

__all__ = ["BullPerspectiveAgent", "SYSTEM_PROMPT"]

log = logging.getLogger(__name__)

# Verbatim from spec § B.5.2 (≥40 LOC)
SYSTEM_PROMPT = """\
You are a BULL analyst for {TICKER} (Vietnamese stock market). Your role is
ADVOCACY -- find every credible reason a long position might be reasonable at
the current price as of {AS_OF}, while remaining grounded.

You have read access to the same SharedContext bundle as the Bear analyst:
Bar history, TTM ratios from code, FinancialStatement point-in-time, peer
comparables, recent news + ExtractedClaim.

HARD RULES (violations void your output):
1. NO LLM MATH. NEVER produce a numeric value in prose. Call the deterministic
   tool for any number. Forbidden phrasings: "approximately X%", "around X%",
   "roughly X", "~X%", "about X%". Tool returns the exact value.
2. EVERY CLAIM CITES SOURCE_URL + SOURCE_EXCERPT (<=500 chars verbatim).
3. MINIMUM 3 bull points across categories chosen from {FUNDAMENTAL,
   GROWTH, VALUATION, COMPETITIVE, MACRO, NARRATIVE}. Distinct categories.
4. Conviction declared per point in {STRONG, MODERATE, WEAK}.
5. Specific evidence -- "company has good moat" is boilerplate; "company holds
   54% market share in segment X per FY2025 10-K p.42" is specific.
6. CATALYSTS section: list events that could trigger re-rating, with timeframe
   and likelihood. Each catalyst is a GroundedPoint.
7. Vietnamese-market-aware -- surface foreign-flow trends, Room ngoai
   availability, sector tailwinds (credit cycle, regulatory) when present.
8. If you cannot find >=3 substantive bull points (e.g., all data leans
   structurally negative), state so explicitly. Honest absence of bull case
   is acceptable and informs the synthesizer.
9. NEVER use "buy", "sell", "recommend", or "should". Frame as "consideration",
   "investigate further", "thesis exploration". You are not making a
   recommendation; you are surfacing reasons that warrant further investigation.

Output JSON matching PerspectiveAnalysis schema.

REMEMBER: research aid, not financial advice. Even a strong bull case is a
hypothesis to be falsified by the user, not a directive.
"""


def _jaccard(set_a: set[str], set_b: set[str]) -> float:
    """Jaccard similarity coefficient for two keyword sets."""
    if not set_a and not set_b:
        return 0.0
    intersection = len(set_a & set_b)
    union = len(set_a | set_b)
    return intersection / union if union > 0 else 0.0


def _parse_grounded_points(raw_points: list[object]) -> list[GroundedPoint]:
    """Parse and validate a list of raw point objects from LLM JSON output."""
    import datetime as dt

    out: list[GroundedPoint] = []
    for raw in raw_points:
        if not isinstance(raw, dict):
            continue
        raw_dict = dict(raw)  # narrow to dict[str, object]
        try:
            as_of_raw = raw_dict.get("as_of", "")
            as_of_date = (
                dt.date.fromisoformat(str(as_of_raw))
                if isinstance(as_of_raw, str) and as_of_raw
                else dt.date.today()
            )
            conviction = Conviction(str(raw_dict.get("conviction", "weak")).lower())
            category_raw = raw_dict.get("category")
            category = str(category_raw) if category_raw is not None else None
            kp_raw = raw_dict.get("key_phrases", [])
            key_phrases = (
                tuple(str(k) for k in kp_raw)
                if isinstance(kp_raw, list)
                else ()
            )
            point = GroundedPoint(
                text=str(raw_dict.get("text", "")),
                source_url=str(raw_dict.get("source_url", "")),
                source_excerpt=str(raw_dict.get("source_excerpt", ""))[:500],
                as_of=as_of_date,
                conviction=conviction,
                category=category,
                key_phrases=key_phrases,
            )
            out.append(point)
        except (GroundedPointInvariantError, ValueError, KeyError) as exc:
            log.debug("Skipping invalid bull point: %s", exc)
    return out


def _filter_by_jaccard(points: list[GroundedPoint]) -> list[GroundedPoint]:
    """Remove bull points with key_phrase overlap >=40% vs earlier kept points."""
    kept: list[GroundedPoint] = []
    for p in points:
        p_phrases = set(p.key_phrases)
        if any(_jaccard(p_phrases, set(k.key_phrases)) >= 0.40 for k in kept):
            continue
        kept.append(p)
    return kept


class BullPerspectiveAgent:
    """Concrete BULL perspective agent.

    Takes a ClaudeLLMPerspectiveAdapter adapter dependency. The adapter handles
    the Anthropic SDK call; this agent handles BULL-specific prompt injection and
    post-LLM validation.
    """

    def __init__(self, adapter: object) -> None:
        self._adapter = adapter

    async def analyze(
        self, ticker: Ticker, context: object, _role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        """Run BULL analysis. Returns PerspectiveAnalysis with validated key_points."""
        as_of_str = str(getattr(context, "as_of", ""))
        prompt = SYSTEM_PROMPT.replace("{TICKER}", ticker.symbol).replace(
            "{AS_OF}", as_of_str
        )
        call_llm = getattr(self._adapter, "call_llm")  # noqa: B009
        raw_json, cost_usd, model_id, prompt_hash = await call_llm(
            system_prompt=prompt,
            context=context,
            role=PerspectiveRole.BULL,
        )
        try:
            payload = json.loads(raw_json)
            raw_points: list[object] = payload.get("key_points", []) if isinstance(payload, dict) else []
        except (json.JSONDecodeError, AttributeError):
            raw_points = []

        points = _parse_grounded_points(raw_points)
        points = _filter_by_jaccard(points)
        overall = Conviction.WEAK
        if points:
            counts = {c: sum(1 for p in points if p.conviction == c) for c in Conviction}
            overall = max(counts, key=lambda c: counts[c])

        return PerspectiveAnalysis(
            role=PerspectiveRole.BULL,
            key_points=tuple(points),
            overall_conviction=overall,
            cost_usd=Decimal(str(cost_usd)),
            model_id=str(model_id),
            prompt_hash=str(prompt_hash),
        )
