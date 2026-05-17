"""BuffettPerspectiveAgent — Warren Buffett value/quality/moat perspective.

Wraps ClaudeLLMPerspectiveAdapter with the Buffett persona role-pack
(system_prompt_template loaded from RolePromptPack; no inline SYSTEM_PROMPT).

Post-LLM validation mirrors BearPerspectiveAgent D-054 retry-validator shape:
1. Parse JSON response → list of GroundedPoint candidates
2. Strip claims without source_url or source_excerpt (hallucination guard)
3. Jaccard overlap <40% between key_phrases of any two points
4. Category in role_pack.category_universe (persona-specific enforcement)
5. >=min_distinct_categories distinct categories across points

Per DD-3 (plan-035): NO shared base class (AP-23 first-instance HOLD).
Per DD-5: conviction_guidance is categorical (NO numeric rubric; Rule 16 mode 1).
Per DD-7: model_id_preference = 'claude-sonnet-4-6' (set in JSON role-pack).
Per DD-8: mirrors BearPerspectiveAgent at bear_agent.py:198-334 exactly.
Per DD-10: prompt content authored from Buffett principles (NOT verbatim copy
  of ai-hedge-fund warren_buffett.py ChatPromptTemplate/Pydantic structures).
Per I-S35: research-aid framing enforced; 'buy/sell' prose rejected in prompt.

Source: agent-workspace/session-plans/pending/035-S377-phase-f2-personas-buffett-graham-taleb.md
"""

from __future__ import annotations

import json
import logging
from decimal import Decimal

from packages.application.analysis.role_prompt_pack import RolePromptPack
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

__all__ = ["BuffettPerspectiveAgent"]

log = logging.getLogger(__name__)


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
        raw_dict = dict(raw)
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
            log.debug("Skipping invalid buffett point: %s", exc)
    return out


def _filter_by_jaccard(points: list[GroundedPoint]) -> list[GroundedPoint]:
    """Remove points with key_phrase Jaccard overlap >=40% vs earlier points."""
    kept: list[GroundedPoint] = []
    for p in points:
        p_phrases = set(p.key_phrases)
        if any(_jaccard(p_phrases, set(k.key_phrases)) >= 0.40 for k in kept):
            log.debug("Dropping buffett point (Jaccard overlap >=40%%): %s", p.text[:60])
            continue
        kept.append(p)
    return kept


def _validate_buffett_output(
    raw: str, role_pack: RolePromptPack
) -> tuple[bool, str | None]:
    """Validate raw LLM output for Buffett persona structural compliance.

    Checks:
      (a) valid JSON parse
      (b) top-level dict with 'key_points' list
      (c) each point has 'category' + 'text' (or 'evidence'/'claim') + 'as_of' fields
      (d) each point's category is in role_pack.category_universe
      (e) >=role_pack.min_distinct_categories distinct categories (persona gate)

    Returns:
      (True, None)            — valid; ready for _parse_grounded_points
      (False, reason_string)  — invalid; reason describes the first failure
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
        if not pt.get("text") and not pt.get("evidence") and not pt.get("claim"):
            missing.append("text/evidence/claim")
        if missing:
            return False, f"key_points[{i}] missing required fields: {missing}"
        # Per-persona category_universe enforcement (DD-8 TC-<persona>-8)
        cat = pt.get("category")
        if cat not in role_pack.category_universe:
            return False, (
                f"key_points[{i}] category {cat!r} not in Buffett "
                f"category_universe {list(role_pack.category_universe)}"
            )

    distinct_cats = {
        pt["category"]
        for pt in points
        if isinstance(pt, dict) and pt.get("category")
    }
    min_cats = role_pack.min_distinct_categories
    if len(distinct_cats) < min_cats:
        return False, (
            f"Buffett persona requires >={min_cats} distinct categories; "
            f"got {len(distinct_cats)}: {sorted(distinct_cats)}"
        )

    return True, None


class BuffettPerspectiveAgent:
    """Concrete BUFFETT perspective agent (Warren Buffett value/quality/moat).

    Mirrors BearPerspectiveAgent D-054 retry-validator pattern (bear_agent.py:198-334).
    RolePromptPack passed at construction — system_prompt_template + category_universe
    + min_points + min_distinct_categories all read from the pack instance.

    Research-aid framing (I-S35): output framed as 'thesis exploration', NOT buy/sell.
    Conviction is categorical STRONG/MODERATE/WEAK (Rule 16 mode 1 — no numeric rubric).
    """

    def __init__(self, adapter: object, role_pack: RolePromptPack) -> None:
        self._adapter = adapter
        self._role_pack = role_pack

    async def analyze(
        self, ticker: Ticker, context: object, _role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        """Run BUFFETT analysis. Returns PerspectiveAnalysis with validated key_points.

        A2-mirror via D-054: retry-validator with max-2 retries (3 total attempts).
        Each retry includes the validation error in re-prompt. After 3 total failures
        → log explicit WARNING + emit buffett_failure_mode='validation-exhausted';
        does NOT silently empty.
        """
        as_of_str = str(getattr(context, "as_of", ""))
        prompt = self._role_pack.system_prompt_template.replace(
            "{TICKER}", ticker.symbol
        ).replace("{AS_OF}", as_of_str)
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
        """Retry-validator loop (mirrors D-054 BearPerspectiveAgent shape).

        Attempt 1: normal call.
        Attempt 2: re-prompt with validation error (if attempt 1 fails).
        Attempt 3: re-prompt with validation error (if attempt 2 fails).
        After 3 total failures: log explicit WARNING; emit buffett_failure_mode=
        'validation-exhausted'; return empty PerspectiveAnalysis (NOT silent).
        """
        call_llm = getattr(self._adapter, "call_llm")  # noqa: B009
        cumulative_cost = Decimal("0")
        last_model_id = "unknown"
        last_prompt_hash = ""
        validation_error: str | None = None
        cats_str = str(list(self._role_pack.category_universe))
        min_cats = self._role_pack.min_distinct_categories

        for attempt in range(1, 4):
            if attempt > 1 and validation_error:
                retry_prompt = (
                    prompt
                    + f"\n\nATTEMPT {attempt} RETRY: Previous response failed validation: "
                    f"{validation_error}. "
                    "Output ONLY valid JSON with key_points list. "
                    "Each point MUST have: category (string), as_of (YYYY-MM-DD), "
                    "text (string), source_url (string), source_excerpt (string). "
                    f"MUST include at least {min_cats} points with {min_cats} DISTINCT "
                    f"categories from {cats_str}."
                )
            else:
                retry_prompt = prompt

            try:
                raw_json, cost_usd, model_id, prompt_hash = await call_llm(
                    system_prompt=retry_prompt,
                    context=context,
                    role=PerspectiveRole.BUFFETT,
                )
            except Exception as exc:  # noqa: BLE001
                log.warning(
                    "buffett_agent attempt %d/%d LLM call error for %s: %s",
                    attempt, 3, ticker.symbol, exc,
                )
                validation_error = f"LLM call error: {exc}"
                continue

            cumulative_cost += Decimal(str(cost_usd))
            last_model_id = str(model_id)
            last_prompt_hash = str(prompt_hash)

            valid, reason = _validate_buffett_output(raw_json, self._role_pack)
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
                    "buffett_agent validated OK on attempt %d/%d for %s: %d points",
                    attempt, 3, ticker.symbol, len(points),
                )
                return PerspectiveAnalysis(
                    role=PerspectiveRole.BUFFETT,
                    key_points=tuple(points),
                    overall_conviction=overall,
                    cost_usd=cumulative_cost,
                    model_id=last_model_id,
                    prompt_hash=last_prompt_hash,
                )
            else:
                validation_error = reason
                log.warning(
                    "buffett_agent validation fail on attempt %d/%d for %s: %s",
                    attempt, 3, ticker.symbol, reason,
                )

        log.warning(
            "buffett_agent VALIDATION-EXHAUSTED for %s after 3 attempts. "
            "buffett_failure_mode=validation-exhausted. "
            "Last error: %s",
            ticker.symbol, validation_error,
        )
        return PerspectiveAnalysis(
            role=PerspectiveRole.BUFFETT,
            key_points=(),
            overall_conviction=Conviction.WEAK,
            cost_usd=cumulative_cost,
            model_id=last_model_id,
            prompt_hash=last_prompt_hash,
        )
