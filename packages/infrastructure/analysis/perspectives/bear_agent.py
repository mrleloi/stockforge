"""BearPerspectiveAgent — concrete BEAR LLMPerspectivePort implementation.

Wraps a ClaudeLLMPerspectiveAdapter with the BEAR system prompt (spec § B.5.1).
The system prompt is embedded verbatim — it is the contract with the LLM.

Post-LLM validation:
1. Parse JSON response → list of GroundedPoint candidates
2. Strip claims without source_url or source_excerpt (hallucination guard)
3. Jaccard overlap <40% between key_phrases of any two points (§ A.11 rule 3)
4. Category distinctness: bear points must have distinct BearCategory values

Post-LLM validation: A2-mirror retry-validator (ADR D-054). Max 3 attempts;
re-prompt with error on retry; cumulative cost; explicit bear_failure_mode=
"validation-exhausted" WARNING on triple-fail. Mirrors bull_agent.py (D-053).

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


# ---------------------------------------------------------------------------
# Validation helpers (production default, ADR D-054 — mirrors bull_agent D-053)
# ---------------------------------------------------------------------------

def _validate_bear_output(raw: str) -> tuple[bool, str | None]:
    """Validate raw LLM output for structural compliance (I-S10 gate).

    Checks:
      (a) valid JSON parse
      (b) top-level dict with 'key_points' list
      (c) each point has 'category' + 'text' (or 'evidence'/'claim') + 'as_of' fields
      (d) >=3 distinct categories across points (I-S10 strict gate — fail-fast for retry)

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

    # I-S10 gate: >=3 distinct categories required for bear case validity
    distinct_cats = {
        pt["category"]
        for pt in points
        if isinstance(pt, dict) and pt.get("category")
    }
    if len(distinct_cats) < 3:
        return False, (
            f"I-S10: bear case requires >=3 distinct categories; "
            f"got {len(distinct_cats)}: {sorted(distinct_cats)}"
        )

    return True, None


class BearPerspectiveAgent:
    """Concrete BEAR perspective agent.

    Takes a ClaudeLLMPerspectiveAdapter adapter as its dependency — this agent
    does not instantiate the SDK itself. The adapter handles the system prompt
    injection and LLM call; this agent owns BEAR-specific validation.

    A2-mirror retry-validator (ADR D-054): max 3 attempts, re-prompt with error
    on retry, cumulative cost, explicit bear_failure_mode="validation-exhausted"
    WARNING on triple-fail. Mirrors BullPerspectiveAgent (ADR D-053).
    """

    def __init__(self, adapter: object) -> None:
        self._adapter = adapter

    async def analyze(
        self, ticker: Ticker, context: object, _role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        """Run BEAR analysis. Returns PerspectiveAnalysis with validated key_points.

        Production default (A2-mirror via ADR D-054): retry-validator with
        max-2 retries (3 total attempts). Each retry includes the validation error
        in re-prompt. After 3 total failures → log explicit WARNING + emit
        bear_failure_mode="validation-exhausted"; does NOT silently empty.
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
        """Retry-validator loop (production default, ADR D-054 — mirrors D-053).

        Attempt 1: normal call.
        Attempt 2: re-prompt with validation error (if attempt 1 fails).
        Attempt 3: re-prompt with validation error (if attempt 2 fails).
        After 3 total failures: log explicit WARNING; emit bear_failure_mode=
        'validation-exhausted'; return empty bear (NOT silent).
        """
        call_llm = getattr(self._adapter, "call_llm")  # noqa: B009
        cumulative_cost = Decimal("0")
        last_model_id = "unknown"
        last_prompt_hash = ""
        validation_error: str | None = None

        for attempt in range(1, 4):  # 1, 2, 3
            if attempt > 1 and validation_error:
                retry_prompt = (
                    prompt
                    + f"\n\nATTEMPT {attempt} RETRY: Previous response failed validation: "
                    f"{validation_error}. "
                    "Output ONLY valid JSON with key_points list. "
                    "Each point MUST have: category (string), as_of (YYYY-MM-DD), "
                    "text (string), source_url (string), source_excerpt (string). "
                    "MUST include at least 3 points with 3 DISTINCT categories from "
                    "{FUNDAMENTAL, STRUCTURAL, VALUATION, COMPETITIVE, GOVERNANCE, MACRO}."
                )
            else:
                retry_prompt = prompt

            try:
                raw_json, cost_usd, model_id, prompt_hash = await call_llm(
                    system_prompt=retry_prompt,
                    context=context,
                    role=PerspectiveRole.BEAR,
                )
            except Exception as exc:  # noqa: BLE001
                log.warning(
                    "bear_agent attempt %d/%d LLM call error for %s: %s",
                    attempt, 3, ticker.symbol, exc,
                )
                validation_error = f"LLM call error: {exc}"
                continue

            cumulative_cost += Decimal(str(cost_usd))
            last_model_id = str(model_id)
            last_prompt_hash = str(prompt_hash)

            valid, reason = _validate_bear_output(raw_json)
            if valid:
                try:
                    payload = json.loads(raw_json)
                    raw_points: list[object] = (
                        payload.get("key_points", []) if isinstance(payload, dict) else []
                    )
                except (json.JSONDecodeError, AttributeError):
                    raw_points = []
                points = _parse_grounded_points(raw_points)
                points = _filter_by_jaccard(points)
                overall = Conviction.WEAK
                if points:
                    counts = {c: sum(1 for p in points if p.conviction == c) for c in Conviction}
                    overall = max(counts, key=lambda c: counts[c])
                log.info(
                    "bear_agent validated OK on attempt %d/%d for %s: %d points",
                    attempt, 3, ticker.symbol, len(points),
                )
                return PerspectiveAnalysis(
                    role=PerspectiveRole.BEAR,
                    key_points=tuple(points),
                    overall_conviction=overall,
                    cost_usd=cumulative_cost,
                    model_id=last_model_id,
                    prompt_hash=last_prompt_hash,
                )
            else:
                validation_error = reason
                log.warning(
                    "bear_agent validation fail on attempt %d/%d for %s: %s",
                    attempt, 3, ticker.symbol, reason,
                )

        # All 3 attempts exhausted — explicit warning (NOT silent)
        log.warning(
            "bear_agent VALIDATION-EXHAUSTED for %s after 3 attempts. "
            "bear_failure_mode=validation-exhausted. "
            "Last error: %s",
            ticker.symbol, validation_error,
        )
        return PerspectiveAnalysis(
            role=PerspectiveRole.BEAR,
            key_points=(),
            overall_conviction=Conviction.WEAK,
            cost_usd=cumulative_cost,
            model_id=last_model_id,
            prompt_hash=last_prompt_hash,
        )
