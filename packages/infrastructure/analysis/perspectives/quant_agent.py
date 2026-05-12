"""QuantPerspectiveAgent — concrete QUANT LLMPerspectivePort implementation.

Wraps a ClaudeLLMPerspectiveAdapter with the QUANT system prompt (spec § B.5.3).
QUANT interprets deterministic ratios computed by RatioService — it NEVER computes
or estimates numbers. Its role is interpretive framing only.

Uses claude-opus-4-7 by default per spec § B.10 reliability premium for numeric
interpretation. The SCOPE-tier user-gate (Q-S41-1) allows downgrade to Sonnet;
that changes the model_id in the adapter config, not this agent.

Post-LLM validation: A2-mirror abbreviated retry (ADR D-054). Max 2 attempts
(vs bear/bull 3) with per-role timeout 180s (vs default 300s). Quant is
interpretive-not-generative; less likely to need 3 retries. Quant timeout does
NOT trip I-S10 (which governs only bear). Explicit quant_failure_mode=
"validation-exhausted" WARNING on double-fail.

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


# ---------------------------------------------------------------------------
# Validation helpers (production default, ADR D-054 — abbreviated mirror of bull D-053)
# ---------------------------------------------------------------------------

def _validate_quant_output(raw: str) -> tuple[bool, str | None]:
    """Validate raw LLM output for structural compliance.

    Checks:
      (a) valid JSON parse
      (b) top-level dict with 'key_points' list
      (c) each point has 'category' + 'text' (or 'evidence'/'claim') + 'as_of' fields

    NOTE: NO >=3-distinct-cats gate — quant has no I-S* invariant governing category
    count. Quant failure → quant_failure_mode field; does NOT trip I-S10 (bear only).

    Returns:
      (True, None)               — valid; ready for _parse_grounded_points
      (False, reason_string)     — invalid; reason describes the first failure
    """
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as exc:
        return False, f"JSON parse error: {exc}"

    if not isinstance(payload, dict):
        return False, f"Expected top-level dict, got {type(payload).__name__}"

    points = payload.get("key_points")
    if not isinstance(points, list):
        return False, "Missing or non-list 'key_points' field"

    if len(points) == 0:
        return False, "key_points list is empty"

    for i, pt in enumerate(points):
        if not isinstance(pt, dict):
            return False, f"key_points[{i}] is not a dict"
        missing = [f for f in ("category", "as_of") if not pt.get(f)]
        # Accept either 'text' or 'evidence' or 'claim' as the claim body field
        if not pt.get("text") and not pt.get("evidence") and not pt.get("claim"):
            missing.append("text/evidence/claim")
        if missing:
            return False, f"key_points[{i}] missing required fields: {missing}"

    return True, None


class QuantPerspectiveAgent:
    """Concrete QUANT perspective agent using Opus (reliability premium).

    Adapter dependency is ClaudeLLMPerspectiveAdapter configured with
    model=claude-opus-4-7 for Quant (per spec § B.10; see D-014 § A.6.3).

    A2-mirror abbreviated retry (ADR D-054): max 2 attempts (vs bear/bull 3),
    per-role timeout 180s (via subagent_transport _ROLE_TIMEOUT_OVERRIDES).
    """

    def __init__(self, adapter: object) -> None:
        self._adapter = adapter

    async def analyze(
        self, ticker: Ticker, context: object, _role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        """Run QUANT analysis. Returns PerspectiveAnalysis with ratio interpretation.

        Production default (A2-mirror abbreviated via ADR D-054): retry-validator
        with max-1 retry (2 total attempts). Each retry includes the validation
        error in re-prompt. After 2 total failures → log explicit WARNING + emit
        quant_failure_mode="validation-exhausted"; does NOT silently empty.
        """
        as_of_str = str(getattr(context, "as_of", ""))
        prompt = SYSTEM_PROMPT.replace("{TICKER}", ticker.symbol).replace(
            "{AS_OF}", as_of_str
        )
        return await self._analyze_with_retry(
            prompt=prompt,
            context=context,
            ticker=ticker,
        )

    async def _analyze_with_retry(
        self,
        prompt: str,
        context: object,
        ticker: Ticker,
    ) -> PerspectiveAnalysis:
        """Abbreviated retry-validator loop (production default, ADR D-054).

        Attempt 1: normal call.
        Attempt 2: re-prompt with validation error (if attempt 1 fails).
        After 2 total failures: log explicit WARNING; emit quant_failure_mode=
        'validation-exhausted'; return empty quant (NOT silent).

        Max attempts = 2 (vs bear/bull 3) because:
        - Quant is interpretive-not-generative; validation failure less likely
        - Per-role timeout 180s (vs 300s) reduces worst-case wall-clock latency
        - Quant failure does NOT trip I-S10 (bear-only invariant)
        """
        call_llm = getattr(self._adapter, "call_llm")  # noqa: B009
        cumulative_cost = Decimal("0")
        last_model_id = "unknown"
        last_prompt_hash = ""
        validation_error: str | None = None
        max_attempts = 2

        for attempt in range(1, max_attempts + 1):  # 1, 2
            if attempt > 1 and validation_error:
                retry_prompt = (
                    prompt
                    + f"\n\nATTEMPT {attempt} RETRY: Previous response failed validation: "
                    f"{validation_error}. "
                    "Output ONLY valid JSON with key_points list. "
                    "Each point MUST have: category (string), as_of (YYYY-MM-DD), "
                    "text (string), source_url (string), source_excerpt (string)."
                )
            else:
                retry_prompt = prompt

            try:
                raw_json, cost_usd, model_id, prompt_hash = await call_llm(
                    system_prompt=retry_prompt,
                    context=context,
                    role=PerspectiveRole.QUANT,
                )
            except Exception as exc:  # noqa: BLE001
                log.warning(
                    "quant_agent attempt %d/%d LLM call error for %s: %s",
                    attempt, max_attempts, ticker.symbol, exc,
                )
                validation_error = f"LLM call error: {exc}"
                continue

            cumulative_cost += Decimal(str(cost_usd))
            last_model_id = str(model_id)
            last_prompt_hash = str(prompt_hash)

            valid, reason = _validate_quant_output(raw_json)
            if valid:
                try:
                    payload = json.loads(raw_json)
                    raw_points: list[object] = (
                        payload.get("key_points", []) if isinstance(payload, dict) else []
                    )
                except (json.JSONDecodeError, AttributeError):
                    raw_points = []
                points = _parse_grounded_points(raw_points)
                overall = Conviction.WEAK
                if points:
                    counts = {c: sum(1 for p in points if p.conviction == c) for c in Conviction}
                    overall = max(counts, key=lambda c: counts[c])
                log.info(
                    "quant_agent validated OK on attempt %d/%d for %s: %d points",
                    attempt, max_attempts, ticker.symbol, len(points),
                )
                return PerspectiveAnalysis(
                    role=PerspectiveRole.QUANT,
                    key_points=tuple(points),
                    overall_conviction=overall,
                    cost_usd=cumulative_cost,
                    model_id=last_model_id,
                    prompt_hash=last_prompt_hash,
                )
            else:
                validation_error = reason
                log.warning(
                    "quant_agent validation fail on attempt %d/%d for %s: %s",
                    attempt, max_attempts, ticker.symbol, reason,
                )

        # All attempts exhausted — explicit warning (NOT silent)
        log.warning(
            "quant_agent VALIDATION-EXHAUSTED for %s after %d attempts. "
            "quant_failure_mode=validation-exhausted. "
            "Last error: %s",
            ticker.symbol, max_attempts, validation_error,
        )
        return PerspectiveAnalysis(
            role=PerspectiveRole.QUANT,
            key_points=(),
            overall_conviction=Conviction.WEAK,
            cost_usd=cumulative_cost,
            model_id=last_model_id,
            prompt_hash=last_prompt_hash,
        )
