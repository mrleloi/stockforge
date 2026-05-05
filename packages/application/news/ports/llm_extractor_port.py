"""LlmExtractorPort — abstracts the Claude API behind a Protocol.

Per architecture.md § Ports & Adapters: BC-5's domain is allowed to depend
on Protocols only; concrete LLM SDKs (anthropic, openai, etc.) live in the
infrastructure layer (`ClaudeLlmExtractor`). Test fixtures implement this
Protocol with recorded responses so CI never makes a live API call (Phase 0
discipline carried into Phase 2 per master-plan 005 § S36).

The port returns ExtractedClaim domain objects directly — the adapter is
responsible for translating provider JSON into Rule-6-compliant entities
(provenance fields populated, source_text_excerpt grounded, sentiment
categorical per Rule 7).

Source: agent-workspace/constitution/architecture.md § Ports & Adapters;
financial-data-protocol.md Rule 6 + Rule 7;
specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2.
"""

from __future__ import annotations

from typing import Protocol

from packages.domain.news.models import ExtractedClaim, NewsArticle

__all__ = ["LlmExtractorPort"]


class LlmExtractorPort(Protocol):
    """Extract structured claims from a single article.

    Implementations MUST:
    - Populate every Rule 6 provenance field on each returned ExtractedClaim
      (extractor_model, extractor_version, extractor_prompt_hash,
      extracted_at, confidence_extracted).
    - Set sentiment to a Sentiment enum (categorical per Rule 7); never a
      number, never a free-form string.
    - Quote source_text_excerpt verbatim from the article body (≤500 chars
      per Rule 6).
    - Return [] if no Rule-6-compliant claims can be extracted (e.g. article
      mentions no UL ticker / sector). Never raise on empty extraction.

    Implementations MAY:
    - Cap article body at provider context-window before calling.
    - Fail-fast on transport / auth errors (the CLI catches and continues).
    """

    def extract(self, article: NewsArticle) -> list[ExtractedClaim]:
        """Return zero or more claims extracted from `article`."""
        ...
