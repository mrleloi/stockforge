"""QuantPerspectiveAgent — concrete QUANT LLMPerspectivePort implementation.

Wraps a ClaudeLLMPerspectiveAdapter with the QUANT system prompt (spec § B.5.3).
QUANT interprets deterministic ratios computed by RatioService — it NEVER computes
or estimates numbers. Its role is interpretive framing only.

Uses claude-opus-4-7 by default per spec § B.10 reliability premium for numeric
interpretation. The SCOPE-tier user-gate (Q-S41-1) allows downgrade to Sonnet;
that changes the model_id in the adapter config, not this agent.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.5.3.
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

__all__ = ["QuantPerspectiveAgent", "SYSTEM_PROMPT"]

log = logging.getLogger(__name__)

# Verbatim from spec § B.5.3 (≥40 LOC)
SYSTEM_PROMPT = """\
You are a QUANT analyst for {TICKER} (Vietnamese stock market). Your role is
NUMERICAL INTERPRETATION -- read the deterministic ratios computed by code and
explain what they mean in context. You are NOT a calculator and NOT a forecaster.

You have read access to:
- Bar history TTM (last 365 days)
- TTM ratios pre-computed by RatioService (P/E, P/B, ROE, D/E, ROA, EBIT margin,
  net margin, current ratio, quick ratio, debt-to-equity, asset turnover)
- 5-year historical percentiles for each ratio (own history)
- Sector / peer averages for each ratio
- Margin of Safety vs DCF / Graham / peer-multiple fair value bands

HARD RULES (violations void your output):
1. ABSOLUTE NO LLM MATH. You receive the numbers. You DO NOT compute. You DO NOT
   estimate. You DO NOT round in prose. Forbidden phrasings: "approximately",
   "around", "roughly", "~ X%", "about", "circa". If you need a number not in
   the context, call the tool. The tool returns exact; you cite verbatim.
2. EVERY CLAIM CITES SOURCE_URL + SOURCE_EXCERPT (or "-- query: SQL" audit
   comment when the source is a deterministic database query).
3. Output structured: for each ratio in {P/E, P/B, ROE, D/E, Margin of Safety},
   produce a GroundedPoint with: current_value, sector_avg, 5yr_own_percentile,
   verdict in {STRONG, NEUTRAL, WEAK}, interpretation (<=200 chars).
4. NEVER predict price. NEVER produce price targets. The Charter forbids price
   targets -- system "predicts narrative phase", not price.
5. Surface the Margin of Safety verbatim from code. If MoS computation fails (e.g.,
   negative earnings -> P/E undefined), state INSUFFICIENT_DATA explicitly.
6. Vietnamese-market-aware -- VN P/E bands differ from developed markets;
   sector-specific norms (banking ROE typically 18-22%, BDS varies wildly with
   land-bank cycle). Cite peer-comparable when available.
7. NEVER use "buy", "sell", "recommend". Frame: "ratio X at percentile Y suggests
   investigation into Z", "valuation appears stretched relative to 5-year own
   percentile" -- interpretive, not directive.

Output JSON matching PerspectiveAnalysis schema with role=QUANT. Each key_point
covers one ratio family.

REMEMBER: research aid, not financial advice. Numbers come from code; you
interpret. If you ever feel tempted to compute or estimate -- STOP. Call the
tool. The audit trail demands code-traceable numbers.
"""


def _parse_grounded_points(raw_points: list[object]) -> list[GroundedPoint]:
    """Parse and validate QUANT key_points from LLM JSON output."""
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
            log.debug("Skipping invalid quant point: %s", exc)
    return out


class QuantPerspectiveAgent:
    """Concrete QUANT perspective agent using Opus (reliability premium).

    Adapter dependency is ClaudeLLMPerspectiveAdapter configured with
    model=claude-opus-4-7 for Quant (per spec § B.10; see D-014 § A.6.3).
    """

    def __init__(self, adapter: object) -> None:
        self._adapter = adapter

    async def analyze(
        self, ticker: Ticker, context: object, _role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        """Run QUANT analysis. Returns PerspectiveAnalysis with ratio interpretation."""
        as_of_str = str(getattr(context, "as_of", ""))
        prompt = SYSTEM_PROMPT.replace("{TICKER}", ticker.symbol).replace(
            "{AS_OF}", as_of_str
        )
        call_llm = getattr(self._adapter, "call_llm")  # noqa: B009
        raw_json, cost_usd, model_id, prompt_hash = await call_llm(
            system_prompt=prompt,
            context=context,
            role=PerspectiveRole.QUANT,
        )
        try:
            payload = json.loads(raw_json)
            raw_points: list[object] = payload.get("key_points", []) if isinstance(payload, dict) else []
        except (json.JSONDecodeError, AttributeError):
            raw_points = []

        points = _parse_grounded_points(raw_points)
        overall = Conviction.WEAK
        if points:
            counts = {c: sum(1 for p in points if p.conviction == c) for c in Conviction}
            overall = max(counts, key=lambda c: counts[c])

        return PerspectiveAnalysis(
            role=PerspectiveRole.QUANT,
            key_points=tuple(points),
            overall_conviction=overall,
            cost_usd=Decimal(str(cost_usd)),
            model_id=str(model_id),
            prompt_hash=str(prompt_hash),
        )
