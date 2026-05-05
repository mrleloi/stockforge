"""ClaudeLlmExtractor — Anthropic SDK adapter implementing LlmExtractorPort.

Phase 2 thin slice: Sonnet (not Opus) per master-plan 005 § S36 cost cap
(≤$0.10/article); production calls use prompt caching on the system prompt
to amortise cost across an ingestion batch (skill: claude-api).

The adapter is fixture-friendly: tests inject a `transport` callable
(prompt: str, body: str) -> str (raw LLM JSON response) so CI never touches
the network. The default transport calls `anthropic.Anthropic().messages.create`
lazily — anthropic SDK is imported only when an adapter without an injected
transport actually runs.

Returned JSON contract (system prompt enforces; adapter validates):
```
{
  "claims": [
    {
      "claim_text": str,
      "source_text_excerpt": str (≤500 chars verbatim quote),
      "sentiment": "strongly_bullish" | "bullish" | "neutral"
                  | "bearish" | "strongly_bearish",
      "mentioned_tickers": [str, ...],
      "mentioned_sectors": [str, ...],
      "key_phrases": [str, ...],
      "tone_indicators": [str, ...],
      "confidence": float [0, 1]
    }
  ]
}
```

Source: financial-data-protocol.md Rule 6 + Rule 7;
specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2;
.claude/skills/claude-api/SKILL.md.
"""

from __future__ import annotations

import hashlib
import json
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.contracts import Ticker
from packages.domain.news.models import ExtractedClaim, NewsArticle
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment

__all__ = ["ClaudeLlmExtractor"]


_DEFAULT_MODEL = "claude-sonnet-4-6"
_DEFAULT_VERSION = "stockforge-news-extractor-0.1"

_SYSTEM_PROMPT = """You are a Vietnamese stock-market news claim extractor.

Your job is to read one Vietnamese financial-news article and emit a JSON
object describing the structured claims it contains. You MUST follow these
rules absolutely:

RULE 1 — NO LLM MATH. Do not produce numeric scores, do not estimate price
impact, do not aggregate. Sentiment is one of five categorical labels:
strongly_bullish | bullish | neutral | bearish | strongly_bearish.

RULE 2 — GROUNDING. Every claim must include a `source_text_excerpt`: a
verbatim quote from the article body (≤500 characters) that supports the
claim. If you cannot quote the article verbatim, do NOT emit the claim.

RULE 3 — ENTITY GROUNDING. Every claim must mention at least one ticker
(uppercase 3-letter VN symbol) or sector. Claims with no entities are noise
and must be omitted.

RULE 4 — OUTPUT. Return ONLY a JSON object of the form
`{"claims": [...]}`. No prose, no markdown fences, no preamble.
"""

_PROMPT_HASH = hashlib.sha256(_SYSTEM_PROMPT.encode("utf-8")).hexdigest()[:16]


def _default_transport(system_prompt: str, body: str) -> str:
    """Default Anthropic SDK call. Imported lazily so anthropic is not a
    test-time requirement when a transport stub is injected.
    """
    import anthropic  # type: ignore[import-not-found]

    client = anthropic.Anthropic()
    response = client.messages.create(
        model=_DEFAULT_MODEL,
        max_tokens=2048,
        system=system_prompt,
        messages=[{"role": "user", "content": body}],
    )
    blocks = response.content
    text_parts: list[str] = []
    for block in blocks:
        text = getattr(block, "text", None)
        if isinstance(text, str):
            text_parts.append(text)
    return "".join(text_parts)


@dataclass
class ClaudeLlmExtractor:
    """LlmExtractorPort adapter backed by the Anthropic SDK.

    `transport`: pluggable string-in / string-out call (system prompt + body
    → raw response text). The default uses anthropic.Anthropic; tests
    inject a closure over recorded responses.
    `clock`: time source for ExtractorMetadata.extracted_at.
    """

    transport: Callable[[str, str], str] = _default_transport
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    model: str = _DEFAULT_MODEL
    version: str = _DEFAULT_VERSION
    system_prompt: str = _SYSTEM_PROMPT

    def extract(self, article: NewsArticle) -> list[ExtractedClaim]:
        body = self._build_user_message(article)
        try:
            raw = self.transport(self.system_prompt, body)
        except Exception:
            return []
        try:
            payload = json.loads(raw)
        except json.JSONDecodeError:
            return []
        if not isinstance(payload, dict):
            return []
        raw_claims = payload.get("claims")
        if not isinstance(raw_claims, list):
            return []
        prompt_hash = hashlib.sha256(
            self.system_prompt.encode("utf-8")
        ).hexdigest()[:16]
        extracted_at = self.clock()
        out: list[ExtractedClaim] = []
        for ordinal, raw_claim in enumerate(raw_claims):
            claim = self._build_claim(
                raw_claim,
                article=article,
                ordinal=ordinal,
                extracted_at=extracted_at,
                prompt_hash=prompt_hash,
            )
            if claim is not None:
                out.append(claim)
        return out

    def _build_user_message(self, article: NewsArticle) -> str:
        return (
            f"URL: {article.source_url}\n"
            f"TITLE: {article.title}\n\n"
            f"BODY:\n{article.body_excerpt}"
        )

    def _build_claim(
        self,
        raw: object,
        *,
        article: NewsArticle,
        ordinal: int,
        extracted_at: datetime,
        prompt_hash: str,
    ) -> ExtractedClaim | None:
        if not isinstance(raw, dict):
            return None
        try:
            claim_text = str(raw["claim_text"])
            excerpt = str(raw["source_text_excerpt"])
            sentiment = Sentiment(str(raw["sentiment"]))
            confidence = float(raw.get("confidence", 0.5))
        except (KeyError, ValueError):
            return None
        tickers = tuple(
            Ticker(str(t)) for t in raw.get("mentioned_tickers", [])
            if isinstance(t, str) and t.isupper() and 2 <= len(t) <= 4
        )
        sectors = tuple(
            str(s) for s in raw.get("mentioned_sectors", [])
            if isinstance(s, str)
        )
        if not tickers and not sectors:
            return None
        key_phrases = tuple(
            str(p) for p in raw.get("key_phrases", [])
            if isinstance(p, str)
        )
        tone_indicators = tuple(
            str(t) for t in raw.get("tone_indicators", [])
            if isinstance(t, str)
        )
        meta = ExtractorMetadata(
            extractor_model=self.model,
            extractor_version=self.version,
            extractor_prompt_hash=prompt_hash,
            extracted_at=extracted_at,
            confidence_extracted=max(0.0, min(1.0, confidence)),
            verified_by_human=False,
        )
        try:
            return ExtractedClaim(
                claim_id=f"{article.article_id}:{ordinal}",
                article_id=article.article_id,
                source_url=article.source_url,
                source_text_excerpt=excerpt[:500],
                claim_text=claim_text,
                sentiment=sentiment,
                extractor=meta,
                mentioned_tickers=tickers,
                mentioned_sectors=sectors,
                key_phrases=key_phrases,
                tone_indicators=tone_indicators,
            )
        except ValueError:
            return None

    @property
    def prompt_hash(self) -> str:
        """Exposed for callers that want to log the prompt hash without
        triggering an extraction (e.g. CLI startup banner).
        """
        return _PROMPT_HASH
