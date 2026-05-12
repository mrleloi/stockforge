"""ClaudeLLMPerspectiveAdapter — Anthropic SDK wrapper for perspective agents.

Pattern reused from packages/infrastructure/news/claude_llm_extractor.py (S36).

Key features:
- temperature=0.0 pinned for reproducibility (AC-5)
- prompt_hash: sha256[:16] of system prompt (reproducibility audit)
- cost_usd: computed from input + output token counts (Decimal; never float)
- Lazy Anthropic SDK import: tests inject transport callable → no network in CI
- context_to_str: converts SharedContext to a user message string

LLM call signature:
  call_llm(system_prompt, context, role) -> (raw_json_str, cost_usd, model_id, prompt_hash)

Model routing per spec § B.10:
- Bear/Bull: claude-sonnet-4-6 ($3/MTok in + $15/MTok out)
- Quant/Synthesizer: claude-opus-4-7 ($15/MTok in + $75/MTok out)

CostBudgetExceeded is not raised here — cost tracking is the use case's job via
CostTrackerPort. This adapter only COMPUTES cost_usd per call.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.10 + § B.11.
"""

from __future__ import annotations

import hashlib
import json
import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from decimal import Decimal

from packages.domain.analysis.models.perspective_analysis import PerspectiveRole

__all__ = ["ClaudeLLMPerspectiveAdapter"]

log = logging.getLogger(__name__)

# Model IDs per spec § B.10 (+ Haiku for per-role override per S43b-BULL DEFER-S43b-3 fix)
_SONNET_MODEL = "claude-sonnet-4-6"
_OPUS_MODEL = "claude-opus-4-7"
_HAIKU_MODEL = "claude-haiku-4-5"

# Cost per million tokens (USD) — spec § B.10 / A.10 data provenance.
# Haiku rate: Anthropic public pricing (Haiku 4.5 = $1.00 in / $5.00 out per MTok).
# In subagent transport path, CLI-reported total_cost_usd is the source of truth
# (logged at log.info); these rates are used when SDK transport returns raw token counts.
_COST_PER_MTOK: dict[str, dict[str, Decimal]] = {
    _SONNET_MODEL: {
        "input": Decimal("3.00"),
        "output": Decimal("15.00"),
    },
    _OPUS_MODEL: {
        "input": Decimal("15.00"),
        "output": Decimal("75.00"),
    },
    _HAIKU_MODEL: {
        "input": Decimal("1.00"),
        "output": Decimal("5.00"),
    },
}

# Role → model routing per spec § B.10
_ROLE_TO_MODEL: dict[PerspectiveRole, str] = {
    PerspectiveRole.BEAR: _SONNET_MODEL,
    PerspectiveRole.BULL: _SONNET_MODEL,
    PerspectiveRole.QUANT: _OPUS_MODEL,
}
_DEFAULT_MODEL = _OPUS_MODEL  # synthesizer and fallback


def _default_transport(
    model: str, system_prompt: str, user_message: str, temperature: float
) -> tuple[str, int, int]:
    """Default Anthropic SDK call. Lazily imported — not needed in tests.

    Returns (response_text, input_tokens, output_tokens).
    """
    import anthropic  # type: ignore[import-not-found]

    client = anthropic.Anthropic()
    response = client.messages.create(
        model=model,
        max_tokens=4096,
        temperature=temperature,
        system=system_prompt,
        messages=[{"role": "user", "content": user_message}],
    )
    text_parts: list[str] = []
    for block in response.content:
        text = getattr(block, "text", None)
        if isinstance(text, str):
            text_parts.append(text)
    usage = getattr(response, "usage", None)
    input_tokens = getattr(usage, "input_tokens", 0) if usage else 0
    output_tokens = getattr(usage, "output_tokens", 0) if usage else 0
    return "".join(text_parts), input_tokens, output_tokens


def _compute_cost(model: str, input_tokens: int, output_tokens: int) -> Decimal:
    """Deterministic cost computation from token counts. No LLM math — pure arithmetic."""
    rates = _COST_PER_MTOK.get(model, _COST_PER_MTOK[_DEFAULT_MODEL])
    cost = (
        rates["input"] * Decimal(input_tokens) / Decimal("1_000_000")
        + rates["output"] * Decimal(output_tokens) / Decimal("1_000_000")
    )
    return cost


def _context_to_str(context: object) -> str:
    """Convert SharedContext to a user message string for the LLM.

    Only includes data that LLM should interpret — never produces numbers itself.
    Numbers from ratios_ttm are passed verbatim (already code-computed).
    """
    parts: list[str] = []

    ticker_symbol = str(getattr(getattr(context, "ticker", None), "symbol", "UNKNOWN"))
    as_of = str(getattr(context, "as_of", ""))
    parts.append(f"=== SharedContext for {ticker_symbol} as_of={as_of} ===\n")

    quotes = getattr(context, "quotes", [])
    if quotes:
        parts.append(f"[Bar History] {len(quotes)} bars loaded.\n")
        # Include last bar details safely
        last_bar = quotes[-1]
        last_close = getattr(last_bar, "close", None)
        last_date = getattr(last_bar, "period_end", None)
        if last_close is not None:
            parts.append(f"  Latest close: {last_close} as of {last_date}\n")

    statements = getattr(context, "statements", None)
    if statements is not None:
        filing_date = getattr(statements, "filing_date", None)
        parts.append(f"[Fundamentals] Filing date: {filing_date}\n")

    ratios = getattr(context, "ratios_ttm", {})
    if ratios:
        parts.append("[TTM Ratios — computed by code; interpret only]\n")
        for name, ratio in ratios.items():
            val = getattr(ratio, "value", ratio)
            audit = getattr(ratio, "formula_audit", "")
            parts.append(f"  {name}: {val}  -- formula: {audit}\n")

    ta_features = getattr(context, "ta_features", {})
    ta_audit = getattr(context, "ta_audit", {})
    if ta_features:
        parts.append("[TA Features — computed by code; interpret only]\n")
        for name, value in ta_features.items():
            audit_key = "sma_N" if str(name).startswith("sma_") else str(name)
            audit = ta_audit.get(audit_key, "") if isinstance(ta_audit, dict) else ""
            parts.append(f"  {name}: {value}  -- formula: {audit}\n")

    news = getattr(context, "recent_news", [])
    claims = getattr(context, "recent_claims", [])
    parts.append(f"[News] {len(news)} articles / {len(claims)} claims in last 90 days.\n")
    for claim in claims[:10]:  # top 10 claims
        text = getattr(claim, "claim_text", "")
        url = getattr(claim, "source_url", "")
        excerpt = getattr(claim, "source_text_excerpt", "")
        sentiment = str(getattr(claim, "sentiment", ""))
        parts.append(f"  CLAIM [{sentiment}]: {text[:200]}\n  SOURCE: {url}\n  EXCERPT: {excerpt[:200]}\n")
    # When claims are absent (extraction not yet run), surface news articles
    # directly so the LLM has grounded source_url + body_excerpt to cite.
    if not claims:
        for art in news[:10]:
            title = getattr(art, "title", "")
            url = getattr(art, "source_url", "")
            excerpt = getattr(art, "body_excerpt", "")
            published = getattr(art, "published_at", "")
            parts.append(
                f"  NEWS: {title[:160]}\n  SOURCE: {url}\n  PUBLISHED: {published}\n  EXCERPT: {excerpt[:300]}\n"
            )

    gaps = getattr(context, "gaps", [])
    if gaps:
        parts.append(f"[Data Gaps] {gaps}\n")

    return "".join(parts)


@dataclass
class ClaudeLLMPerspectiveAdapter:
    """Anthropic SDK wrapper for perspective agent LLM calls.

    `transport`: pluggable (model, system_prompt, user_message, temperature) -> (text, in_tok, out_tok).
    Default uses anthropic.Anthropic lazily. Tests inject a closure.
    `model_override`: global override for all calls (e.g. forcing one model in tests).
    `role_model_overrides`: per-role override applied when `model_override` is None.
        Used by S43b-BULL fix (DEFER-S43b-3): map BULL → haiku to side-step the
        300s sonnet timeout that empirically reproduces 2/2 dogfood runs.
        Resolution order (first wins): model_override → role_model_overrides[role]
        → _ROLE_TO_MODEL[role] → _DEFAULT_MODEL.
    """

    transport: Callable[[str, str, str, float], tuple[str, int, int]] = field(
        default=_default_transport
    )
    model_override: str | None = None
    role_model_overrides: dict[PerspectiveRole, str] | None = None
    temperature: float = 0.0  # AC-5 reproducibility

    async def call_llm(
        self,
        system_prompt: str,
        context: object,
        role: PerspectiveRole,
    ) -> tuple[str, Decimal, str, str]:
        """Call the LLM with role-appropriate model and return structured output.

        Returns (raw_json_str, cost_usd, model_id, prompt_hash).
        raw_json_str is expected to be a JSON string matching PerspectiveAnalysis schema.
        """
        model = (
            self.model_override
            or (self.role_model_overrides or {}).get(role)
            or _ROLE_TO_MODEL.get(role, _DEFAULT_MODEL)
        )
        user_message = _context_to_str(context)
        prompt_hash = hashlib.sha256(system_prompt.encode("utf-8")).hexdigest()[:16]

        try:
            # Pass role string for per-role timeout lookup (ADR D-054 B5).
            # Try the extended signature first; fall back to legacy 4-arg signature
            # so that test stubs using the old signature continue to work.
            try:
                raw_text, input_tokens, output_tokens = self.transport(  # type: ignore[call-arg]
                    model, system_prompt, user_message, self.temperature, role=str(role)
                )
            except TypeError:
                raw_text, input_tokens, output_tokens = self.transport(
                    model, system_prompt, user_message, self.temperature
                )
        except Exception as exc:
            log.error("LLM call failed for role=%s model=%s: %s", role, model, exc)
            # Return empty key_points JSON — caller handles insufficient case
            return (
                json.dumps({"key_points": []}),
                Decimal("0"),
                model,
                prompt_hash,
            )

        cost_usd = _compute_cost(model, input_tokens, output_tokens)

        # Validate response is parseable JSON
        try:
            parsed = json.loads(raw_text)
            if not isinstance(parsed, dict):
                log.warning(
                    "LLM response not a dict for role=%s; wrapping. Snippet: %s",
                    role, raw_text[:300],
                )
                raw_text = json.dumps({"key_points": []})
        except json.JSONDecodeError as exc:
            log.warning(
                "LLM response not valid JSON for role=%s (%s); defaulting empty. "
                "Snippet (first 600 chars): %s",
                role, exc, raw_text[:600],
            )
            raw_text = json.dumps({"key_points": []})

        return raw_text, cost_usd, model, prompt_hash
