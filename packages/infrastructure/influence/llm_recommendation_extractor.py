"""LLMRecommendationExtractor — BC-6 LLM-perspective recommendation extractor.

Implements `LLMRecommendationExtractorPort` using the Claude API (via transport
callable) to extract Recommendation entities from Vietnamese KOL transcripts.

--- D-026 LLM SUBSTRATE BOUNDARY PATTERNS (verbatim citation, mandatory) ---

Architecture reference: `agent-workspace/constitution/architecture.md`
§ "LLM Substrate Boundary" (D-026, ratified S43e):

    "The boundary where deterministic Python code calls into a non-deterministic
    LLM is a **failure-prone seam** — Phase 2 (S43b) surfaced 3 distinct failure
    modes and shipped 3 mitigation patterns. Future LLM-perspective adapters
    MUST adopt these patterns:"

Pattern 1 — Per-role model override (BP-S43b-1):
    "Adapters expose `role_model_overrides` so cost/latency-sensitive roles
    (e.g., Bull perspective) can downgrade Opus → Haiku without touching call
    sites. Reference: `claude_llm_perspective_adapter.py`."
    Implementation: `role_model_overrides` dict param; defaults to Sonnet per
    S47 strategy picker. Callers may override per-extraction-type without
    touching this class.

Pattern 2 — Prose-tolerant JSON extractor (BP-S43b-2):
    "Never call naive `json.loads` on LLM output; use the 3-tier extractor
    (fenced block → first-`{` heuristic → best-effort recovery).
    Reference: `subagent_transport.py:55-118`."
    Implementation: `_unwrap_fence` + `_extract_first_json_object` reused
    directly from `packages/infrastructure/analysis/subagent_transport.py`.

Pattern 3 — Gatherer-wired deterministic compute (BP-S43b-3):
    "Numbers come from code (Charter Principle 9 / I-S1) — wire deterministic
    services through the gatherer that prepares LLM context, not through the
    LLM agent itself."
    Implementation: `KOLContentGatherer` (kol_content_gatherer.py) assembles
    all numeric/config values before this class is called. This extractor reads
    from `ExtractionContext.extraction_config` — no hard-coded thresholds here.

--- Q-S47-2: Raw response storage ---
    AUTO decision: Full raw LLM response written to `outputs/llm_responses/influence/`
    for first 30 days, then aggregated. Implemented via `_persist_raw_response()`.
    Directory is created on first use; non-critical path (exceptions logged, not raised).

--- Q-S47-3: Guest attribution ---
    AUTO decision: Default = host KOL (per spec § C.2 default).
    Phase 4 enhancement: attribute to guest speaker when speaker-diarisation is
    available (Whisper + pyannote). Noted here for Phase 4 planning.

Known failure modes catalogued (from architecture.md § "LLM Substrate Boundary"):
    KI-S43b-1: Sonnet pairing 300s subprocess timeout — mitigated via timeout param.
    KI-S43b-2: LLM JSON in prose preamble — mitigated by BP-S43b-2 prose-tolerant parser.
    KI-S43b-3: Windows cp1252 encoding crash — mitigated by encoding="utf-8" in subprocess.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.5 + § A.3 BR-6/7/10.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § d).
"""

from __future__ import annotations

import json
import logging
import re
import uuid
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path

from packages.domain.influence.models.channel_content import ChannelContent
from packages.domain.influence.models.recommendation import InvariantViolation, Recommendation
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.timeframe import Timeframe
from packages.infrastructure.influence.extraction_strategy_picker import (
    ExtractionStrategy,
    pick_extraction_strategy,
)
from packages.infrastructure.influence.kol_content_gatherer import ExtractionContext

__all__ = ["LLMExtractionError", "LLMRecommendationExtractor"]

log = logging.getLogger(__name__)

# BP-S43b-2: prose-tolerant JSON extraction (3-tier, reused from subagent_transport.py:55-118)
_INNER_FENCE_RE = re.compile(r"```(?:json)?\s*\n(.*?)\n```", re.DOTALL)

# Raw response storage path (Q-S47-2 AUTO decision)
_RAW_RESPONSE_DIR = Path("outputs") / "llm_responses" / "influence"

# Spec § B.5 extraction prompt — verbatim from spec
_EXTRACTION_SYSTEM_PROMPT = """\
You extract investment recommendations from Vietnamese financial content. Extract ONLY
explicit recommendations about specific stocks. Do NOT extract general market commentary,
past recommendations, hypothetical examples, or educational content.

For each recommendation:
- ticker: VN stock symbol (e.g., HPG, VIC, FPT)
- intent: STRONG_BUY | BUY | WATCH | NEUTRAL | AVOID | STRONG_AVOID
- conditions: list of conditions, may be empty (e.g., ["if breaks 30k", "after VN-Index 1300"])
- timeframe: INTRADAY | DAYS | WEEKS | MONTHS | LONG_TERM
- timestamp_in_source: for video, mm:ss-mm:ss range
- transcript_excerpt: exact quote ≤500 chars
- extraction_confidence: 0-1, your confidence in this extraction (not in the recommendation itself)

Rules:
- If confidence < 0.5, DO NOT extract
- If speaker says "I'm not giving advice, just sharing view", still extract but mark timeframe LONG_TERM
- If speaker references own past recommendation ("as I said last week"), don't double-extract
- Vietnamese nuances: "cẩn thận" = AVOID, "theo dõi" = WATCH, "mạnh tay mua" = STRONG_BUY

Return JSON array. Empty array if no extractable recommendations.\
"""

# Per-role model override dict (BP-S43b-1)
# Keys are role labels; values are model IDs. Callers may inject a custom override dict.
_DEFAULT_ROLE_MODEL_OVERRIDES: dict[str, str] = {
    "extraction": pick_extraction_strategy().primary_model,  # S3 Sonnet (extract) by default
    "prefilter": pick_extraction_strategy().prefilter_model or "claude-haiku-4-5",
    # S47 probe winner: S3 Haiku-4-5 prefilter + Sonnet-4-6 extract
    # Probe matrix: data/track-H-probe/probe-matrix.json
}

# Valid intent and timeframe strings accepted from LLM output
_VALID_INTENTS = {e.value for e in Intent}
_VALID_TIMEFRAMES = {e.value for e in Timeframe}

# Also accept uppercase versions from LLM output
_INTENT_MAP: dict[str, str] = {v.upper(): v for v in _VALID_INTENTS}
_INTENT_MAP.update({v: v for v in _VALID_INTENTS})
_TIMEFRAME_MAP: dict[str, str] = {v.upper(): v for v in _VALID_TIMEFRAMES}
_TIMEFRAME_MAP.update({v: v for v in _VALID_TIMEFRAMES})


class LLMExtractionError(RuntimeError):
    """Raised when the LLM substrate call fails or JSON cannot be parsed."""


# ---- Prose-tolerant JSON extractor (BP-S43b-2) ---- reused from subagent_transport.py:55-118


def _unwrap_fence(text: str) -> str:
    """Extract JSON content from LLM response (BP-S43b-2, 3-tier).

    Tier 1: fenced block ```json...``` — return LAST match.
    Tier 2: first balanced top-level {...} block.
    Tier 3: return as-is (downstream parse will fail with diagnostic).
    """
    inner_matches = _INNER_FENCE_RE.findall(text)
    if inner_matches:
        last_match = inner_matches[-1]
        return str(last_match)

    brace_match = _extract_first_json_object_or_array(text)
    if brace_match is not None:
        return brace_match

    return text


def _extract_first_json_object_or_array(text: str) -> str | None:
    """Scan for first balanced [...] or {...} block.

    Extended from subagent_transport.py to also handle top-level arrays
    (the extraction prompt returns a JSON array, not an object).
    """
    for opener, closer in (("[", "]"), ("{", "}")):
        depth = 0
        start = -1
        in_string = False
        escape = False
        for i, ch in enumerate(text):
            if in_string:
                if escape:
                    escape = False
                elif ch == "\\":
                    escape = True
                elif ch == '"':
                    in_string = False
                continue
            if ch == '"':
                in_string = True
                continue
            if ch == opener:
                if depth == 0:
                    start = i
                depth += 1
            elif ch == closer:
                depth -= 1
                if depth == 0 and start >= 0:
                    return text[start : i + 1]
    return None


@dataclass
class LLMRecommendationExtractor:
    """LLM-based recommendation extractor for Vietnamese KOL transcripts.

    Implements LLMRecommendationExtractorPort (duck-typed; no explicit inheritance
    needed for Protocol conformance with runtime_checkable).

    Args:
        transport:              Callable(model, system_prompt, user_message,
                                temperature) -> (text, input_tokens, output_tokens).
                                Defaults to None (must be injected; use
                                `claude_cli_transport` for production).
        role_model_overrides:   Per-role model override dict (BP-S43b-1).
                                Defaults to `_DEFAULT_ROLE_MODEL_OVERRIDES`.
        strategy_override:      Force a specific extraction strategy; None = auto.
        persist_raw_responses:  If True, write raw LLM responses to disk (Q-S47-2).
        kol_id:                 KolId to stamp on each extracted Recommendation.
                                Must be provided at construction time.
        clock:                  Callable returning current datetime (test injection).
    """

    transport: Callable[[str, str, str, float], tuple[str, int, int]] | None = None
    role_model_overrides: dict[str, str] = field(
        default_factory=lambda: dict(_DEFAULT_ROLE_MODEL_OVERRIDES)
    )
    strategy_override: ExtractionStrategy | None = None
    persist_raw_responses: bool = True
    kol_id: KolId | None = None
    clock: Callable[[], datetime] = field(default_factory=lambda: lambda: datetime.now(UTC))

    def __post_init__(self) -> None:
        self._strategy_config = pick_extraction_strategy(self.strategy_override)
        # Per-role override merges into the role_model_overrides dict (BP-S43b-1)
        self.role_model_overrides.setdefault("extraction", self._strategy_config.primary_model)

    # --- Public interface (LLMRecommendationExtractorPort) ---

    def extract(
        self,
        transcript: str,
        source_metadata: ChannelContent,
    ) -> list[Recommendation]:
        """Extract Recommendation entities from transcript text.

        Args:
            transcript:      Full plain-text content to analyse.
            source_metadata: ChannelContent carrying provenance fields.

        Returns:
            List of Recommendation aggregates (may be empty).

        Raises:
            LLMExtractionError: if substrate call or JSON parse fails.
        """
        if not transcript or not transcript.strip():
            return []

        model = self.role_model_overrides.get("extraction", self._strategy_config.primary_model)
        user_message = self._build_user_message(transcript, source_metadata)

        raw_text, input_tokens, output_tokens = self._call_transport(
            model=model,
            system_prompt=_EXTRACTION_SYSTEM_PROMPT,
            user_message=user_message,
        )

        log.info(
            "llm_recommendation_extractor model=%s tokens_in=%d tokens_out=%d",
            model,
            input_tokens,
            output_tokens,
        )

        if self.persist_raw_responses:
            self._persist_raw_response(raw_text, source_metadata.source_url)

        return self._parse_response(raw_text, source_metadata)

    def extract_from_context(
        self,
        ctx: ExtractionContext,
    ) -> list[Recommendation]:
        """Extract using a pre-built ExtractionContext (gatherer-wired path, BP-S43b-3).

        Uses extraction_config from the context for model selection,
        allowing the gatherer to control all deterministic parameters.
        """
        # Gatherer may override model via extraction_config (BP-S43b-1 + BP-S43b-3 combined)
        model_override = ctx.extraction_config.get("extraction_model")
        if isinstance(model_override, str):
            self.role_model_overrides["extraction"] = model_override

        return self.extract(
            transcript=ctx.transcript,
            source_metadata=ctx.source_metadata,
        )

    # --- Private helpers ---

    def _build_user_message(
        self,
        transcript: str,
        source_metadata: ChannelContent,
    ) -> str:
        """Assemble the user message with provenance context."""
        return (
            f"Source URL: {source_metadata.source_url}\n"
            f"Published at: {source_metadata.published_at.isoformat()}\n"
            f"Platform channel: {source_metadata.channel_id}\n\n"
            f"Transcript:\n{transcript}"
        )

    def _call_transport(
        self,
        model: str,
        system_prompt: str,
        user_message: str,
    ) -> tuple[str, int, int]:
        """Invoke transport callable or raise LLMExtractionError."""
        if self.transport is None:
            raise LLMExtractionError(
                "LLMRecommendationExtractor requires a `transport` callable; "
                "inject `claude_cli_transport` for production use."
            )
        try:
            return self.transport(model, system_prompt, user_message, 0.0)
        except Exception as exc:
            raise LLMExtractionError(f"Transport call failed: {exc}") from exc

    def _parse_response(
        self,
        raw_text: str,
        source_metadata: ChannelContent,
    ) -> list[Recommendation]:
        """Parse LLM output into Recommendation entities (BP-S43b-2 tolerant parse).

        Uses 3-tier extractor to handle prose preamble before JSON.
        Invalid items are logged and skipped rather than raising.
        """
        unwrapped = _unwrap_fence(raw_text)
        try:
            data = json.loads(unwrapped)
        except json.JSONDecodeError:
            log.warning(
                "llm_recommendation_extractor: JSON parse failed on raw_text=%r",
                raw_text[:200],
            )
            return []

        if not isinstance(data, list):
            log.warning(
                "llm_recommendation_extractor: expected JSON array, got %s",
                type(data).__name__,
            )
            return []

        results: list[Recommendation] = []
        extracted_at = self.clock()

        for item in data:
            if not isinstance(item, dict):
                continue
            rec = self._hydrate_recommendation(item, source_metadata, extracted_at)
            if rec is not None:
                results.append(rec)

        return results

    def _hydrate_recommendation(
        self,
        item: dict[str, object],
        source_metadata: ChannelContent,
        extracted_at: datetime,
    ) -> Recommendation | None:
        """Convert a raw LLM JSON item into a Recommendation aggregate.

        Returns None if item is missing required fields or fails invariants.
        Confidence < 0.7 → requires_manual_review=True (BR-6).
        """
        ticker = str(item.get("ticker", "")).strip().upper()
        if not ticker:
            log.debug("llm_extractor: item missing ticker, skipping")
            return None

        raw_intent = str(item.get("intent", "")).strip().lower()
        intent_value = _INTENT_MAP.get(raw_intent.upper()) or _INTENT_MAP.get(raw_intent)
        if intent_value is None:
            log.debug("llm_extractor: unrecognised intent %r for ticker %s, skipping", raw_intent, ticker)
            return None

        raw_timeframe = str(item.get("timeframe", "")).strip().lower()
        timeframe_value = _TIMEFRAME_MAP.get(raw_timeframe.upper()) or _TIMEFRAME_MAP.get(raw_timeframe)
        if timeframe_value is None:
            log.debug("llm_extractor: unrecognised timeframe %r for ticker %s, defaulting LONG_TERM", raw_timeframe, ticker)
            timeframe_value = Timeframe.LONG_TERM.value

        raw_confidence = item.get("extraction_confidence", 0.0)
        try:
            confidence = float(raw_confidence)  # type: ignore[arg-type]
        except (TypeError, ValueError):
            confidence = 0.0
        confidence = max(0.0, min(1.0, confidence))

        # Skip if confidence < 0.5 (spec § B.5 rule: "If confidence < 0.5, DO NOT extract")
        if confidence < 0.5:
            log.debug("llm_extractor: confidence %.2f < 0.5 for ticker %s, skipping", confidence, ticker)
            return None

        requires_manual_review = confidence < 0.7  # BR-6

        raw_excerpt = str(item.get("transcript_excerpt", "")).strip()
        if not raw_excerpt:
            # Fallback: use first 200 chars of the transcript as a minimal excerpt
            raw_excerpt = "(excerpt not provided by extractor)"

        # Enforce ≤500 char BR-10 limit
        excerpt = raw_excerpt[:500]

        conditions_raw = item.get("conditions", [])
        conditions: list[str] = []
        if isinstance(conditions_raw, list):
            conditions = [str(c) for c in conditions_raw if c]

        timestamp_in_source = str(item.get("timestamp_in_source", "")).strip()

        try:
            rec = Recommendation(
                recommendation_id=RecommendationId(str(uuid.uuid4())),
                kol_id=self.kol_id or KolId("unknown"),
                channel_id=source_metadata.channel_id,
                ticker=ticker,
                intent=Intent(intent_value),
                timeframe=Timeframe(timeframe_value),
                source_url=source_metadata.source_url,
                transcript_excerpt=excerpt,
                extraction_confidence=confidence,
                extractor_model=self.role_model_overrides.get(
                    "extraction", self._strategy_config.primary_model
                ),
                extractor_version=self._strategy_config.strategy.value,
                extracted_at=extracted_at,
                published_at=source_metadata.published_at,
                timestamp_in_source=timestamp_in_source,
                conditions=conditions,
                requires_manual_review=requires_manual_review,
            )
        except (InvariantViolation, ValueError) as exc:
            log.warning("llm_extractor: Recommendation construction failed: %s", exc)
            return None

        return rec

    def _persist_raw_response(self, raw_text: str, source_url: str) -> None:
        """Write raw LLM response to disk for audit (Q-S47-2 AUTO decision).

        Path: outputs/llm_responses/influence/YYYY-MM-DD-<hash>.json
        Non-critical: exceptions are logged and swallowed.
        """
        try:
            _RAW_RESPONSE_DIR.mkdir(parents=True, exist_ok=True)
            ts = self.clock().strftime("%Y-%m-%dT%H-%M-%S")
            url_hash = str(abs(hash(source_url)))[:8]
            fname = _RAW_RESPONSE_DIR / f"{ts}-{url_hash}.json"
            payload = json.dumps(
                {
                    "source_url": source_url,
                    "captured_at": self.clock().isoformat(),
                    "raw_text": raw_text,
                },
                ensure_ascii=False,
            )
            fname.write_text(payload, encoding="utf-8")
        except Exception as exc:  # noqa: BLE001
            log.warning("llm_extractor: failed to persist raw response: %s", exc)
