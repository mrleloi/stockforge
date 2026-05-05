"""ExtractedClaim — LLM-extracted structured claim per spec-T1-001 § B.2.

One NewsArticle can yield 0..N ExtractedClaims. Every claim carries the full
provenance bundle required by financial-data-protocol Rule 6: the source URL
the article was scraped from, the verbatim text excerpt grounding the claim,
and the ExtractorMetadata bundle (model + version + prompt hash + timestamp +
confidence + verified flag).

Sentiment is categorical (Rule 7); numeric aggregation is the application
layer's job and is never persisted on the claim itself.

Invariants enforced in __post_init__:
- Rule 6: source_url, source_text_excerpt, claim_text non-empty.
- Rule 6 + I-S1: source_text_excerpt ≤ 500 chars (`source_text_excerpt — exact
  text quoted (≤500 chars)` per protocol verbatim).
- Rule 6: at least one of mentioned_tickers / mentioned_sectors non-empty —
  a claim with zero entities is noise and should not be persisted.

Source: specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2;
agent-workspace/constitution/financial-data-protocol.md Rule 6 + Rule 7.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from packages.contracts import Ticker
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment

__all__ = ["ExtractedClaim", "ExtractedClaimInvariantError"]


_MAX_EXCERPT_CHARS = 500


class ExtractedClaimInvariantError(ValueError):
    """Raised when an ExtractedClaim violates Rule 6 / Rule 7 invariants."""


@dataclass(frozen=True, slots=True)
class ExtractedClaim:
    """Immutable LLM-extracted claim.

    `claim_text` is the LLM's paraphrase / structured form. `source_text_excerpt`
    is the verbatim quoted text from the article that grounds the claim — this
    is what an auditor checks against months later (Rule 6).
    """

    claim_id: str
    article_id: str
    source_url: str
    source_text_excerpt: str
    claim_text: str
    sentiment: Sentiment
    extractor: ExtractorMetadata
    mentioned_tickers: tuple[Ticker, ...] = field(default_factory=tuple)
    mentioned_sectors: tuple[str, ...] = field(default_factory=tuple)
    key_phrases: tuple[str, ...] = field(default_factory=tuple)
    tone_indicators: tuple[str, ...] = field(default_factory=tuple)

    def __post_init__(self) -> None:
        if not self.claim_id.strip():
            raise ExtractedClaimInvariantError("claim_id is required")
        if not self.article_id.strip():
            raise ExtractedClaimInvariantError("article_id is required (Rule 6)")
        if not self.source_url.strip():
            raise ExtractedClaimInvariantError("source_url is required (Rule 6 / I-1)")
        if not self.claim_text.strip():
            raise ExtractedClaimInvariantError("claim_text is required (Rule 6)")
        if not self.source_text_excerpt.strip():
            raise ExtractedClaimInvariantError(
                "source_text_excerpt is required (Rule 6 — grounding quote)"
            )
        if len(self.source_text_excerpt) > _MAX_EXCERPT_CHARS:
            raise ExtractedClaimInvariantError(
                f"source_text_excerpt {len(self.source_text_excerpt)} chars > "
                f"{_MAX_EXCERPT_CHARS} (Rule 6 cap)"
            )
        if not self.mentioned_tickers and not self.mentioned_sectors:
            raise ExtractedClaimInvariantError(
                "claim must mention at least one ticker or sector (Rule 6 — entity grounding)"
            )
