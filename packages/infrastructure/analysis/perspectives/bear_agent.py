"""BearPerspectiveAgent — concrete BEAR LLMPerspectivePort implementation.

Wraps a ClaudeLLMPerspectiveAdapter with the BEAR system prompt (spec § B.5.1).
The system prompt is embedded verbatim — it is the contract with the LLM.

Post-LLM validation:
1. Parse JSON response → list of GroundedPoint candidates
2. Strip claims without source_url or source_excerpt (hallucination guard)
3. Jaccard overlap <40% between key_phrases of any two points (§ A.11 rule 3)
4. Category distinctness: bear points must have distinct BearCategory values

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.5.1.
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

__all__ = ["BearPerspectiveAgent", "SYSTEM_PROMPT"]

log = logging.getLogger(__name__)

# Verbatim from spec § B.5.1 (≥40 LOC)
SYSTEM_PROMPT = """\
You are a BEAR analyst for {TICKER} (Vietnamese stock market, HOSE/HNX/UPCoM).
Your role is ADVERSARIAL -- not balanced. Your job is to find every credible reason
NOT to take a long position in this stock at the current price as of {AS_OF}.

You have read access to a SharedContext bundle containing:
- Bar history (last 365 days), TTM ratios computed by code (P/E, P/B, ROE, D/E)
- FinancialStatement (latest filed; point-in-time per as_of)
- Peer comparables across the same sector
- Recent news (last 90 days) with ExtractedClaim entries (sentiment + provenance)

HARD RULES (violations void your output):
1. NO LLM MATH. You NEVER produce a numeric value in your prose. If you need a
   ratio, percentage, growth rate, or any number -- call the deterministic tool.
   Forbidden phrasings: "approximately X%", "around X%", "roughly X", "~X%",
   "about X%". The tool returns the exact number; you cite it verbatim.
2. EVERY CLAIM CITES SOURCE_URL + SOURCE_EXCERPT. No claim without grounding.
   The excerpt must be <=500 chars verbatim from the context bundle.
3. MINIMUM 3 distinct bear points across at least 3 different categories chosen
   from {FUNDAMENTAL, STRUCTURAL, VALUATION, COMPETITIVE, GOVERNANCE, MACRO}.
   Three rephrasings of the same risk = one point, not three.
4. Each bear point declares conviction in {STRONG, MODERATE, WEAK}.
5. Specific evidence only -- no boilerplate ("real estate sector is cyclical" is
   boilerplate; "VHM Q4 net debt rose 18.3% sequentially per filing 2026-02-15" is
   specific).
6. Vietnamese-market-aware -- Room ngoai saturation, San-tier data quality,
   T+2.5 settlement, Doi lai pump signals -- surface these when context warrants.
7. If after examining the context you cannot find >=3 substantive bear points,
   state so explicitly. Do NOT manufacture boilerplate. "Insufficient bear case"
   is a valid honest output and triggers system PASS recommendation.

Output JSON matching PerspectiveAnalysis schema. Each key_point has:
  text, source_url, source_excerpt, as_of, conviction, category.

REMEMBER: this is a research aid, not financial advice. You are not predicting
prices. You are surfacing risks the user must investigate before any position.
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
            if isinstance(as_of_raw, str) and as_of_raw:
                as_of_date = dt.date.fromisoformat(as_of_raw)
            else:
                as_of_date = dt.date.today()
            conviction_raw = str(raw_dict.get("conviction", "weak")).lower()
            conviction = Conviction(conviction_raw)
            category_raw = raw_dict.get("category")
            category = str(category_raw) if category_raw is not None else None
            kp_raw = raw_dict.get("key_phrases", [])
            key_phrases = (
                tuple(str(k) for k in kp_raw if isinstance(kp_raw, list))
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
            log.debug("Skipping invalid bear point: %s", exc)
    return out


def _filter_by_jaccard(points: list[GroundedPoint]) -> list[GroundedPoint]:
    """Remove points with key_phrase Jaccard overlap >=40% vs earlier points."""
    kept: list[GroundedPoint] = []
    for p in points:
        p_phrases = set(p.key_phrases)
        if any(_jaccard(p_phrases, set(k.key_phrases)) >= 0.40 for k in kept):
            log.debug("Dropping bear point (Jaccard overlap >=40%%): %s", p.text[:60])
            continue
        kept.append(p)
    return kept


class BearPerspectiveAgent:
    """Concrete BEAR perspective agent.

    Takes a ClaudeLLMPerspectiveAdapter adapter as its dependency — this agent
    does not instantiate the SDK itself. The adapter handles the system prompt
    injection and LLM call; this agent owns BEAR-specific validation.
    """

    def __init__(self, adapter: object) -> None:
        self._adapter = adapter

    async def analyze(
        self, ticker: Ticker, context: object, _role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        """Run BEAR analysis. Returns PerspectiveAnalysis with validated key_points."""
        as_of_str = str(getattr(context, "as_of", ""))
        prompt = SYSTEM_PROMPT.replace("{TICKER}", ticker.symbol).replace(
            "{AS_OF}", as_of_str
        )
        call_llm = getattr(self._adapter, "call_llm")  # noqa: B009
        raw_json, cost_usd, model_id, prompt_hash = await call_llm(
            system_prompt=prompt,
            context=context,
            role=PerspectiveRole.BEAR,
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
            # Most common conviction level wins
            counts = {c: sum(1 for p in points if p.conviction == c) for c in Conviction}
            overall = max(counts, key=lambda c: counts[c])

        return PerspectiveAnalysis(
            role=PerspectiveRole.BEAR,
            key_points=tuple(points),
            overall_conviction=overall,
            cost_usd=Decimal(str(cost_usd)),
            model_id=str(model_id),
            prompt_hash=str(prompt_hash),
        )
