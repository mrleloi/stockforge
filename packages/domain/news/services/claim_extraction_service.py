"""ClaimExtractionService — orchestrates LLM extraction across articles.

Pure-domain service: NO framework imports, NO direct LLM SDK calls. The
service depends only on the LlmExtractorPort Protocol (lives in the
application layer) and a ClaimRepository to persist results. Concrete
adapters (`ClaudeLlmExtractor`) are wired at the CLI / use-case layer.

The service is the single place that:
1. Filters articles by `mentioned_tickers` non-empty (skip noise — saves LLM cost).
2. Calls the port per article (one LLM call per article, batched at adapter level).
3. Builds the deterministic claim_id from article_id + ordinal.
4. Persists results via the repository.

Source: specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2;
agent-workspace/constitution/financial-data-protocol.md Rule 6.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass

from packages.domain.news.models import ExtractedClaim, NewsArticle
from packages.domain.news.repositories import ClaimRepository

__all__ = ["ClaimExtractionService", "LlmExtractorProtocol"]


from typing import Protocol


class LlmExtractorProtocol(Protocol):
    """Mirror of packages.application.news.ports.LlmExtractorPort, declared
    here so the domain service has zero dependency on the application layer.

    The application port and this Protocol are structurally identical; mypy
    accepts a concrete implementer of either in this slot.
    """

    def extract(self, article: NewsArticle) -> list[ExtractedClaim]:
        ...


@dataclass
class ClaimExtractionService:
    """Drive LLM-extraction over a stream of articles. Stateful across
    `process` calls only via the injected repository.
    """

    extractor: LlmExtractorProtocol
    claim_repo: ClaimRepository

    def process(self, articles: Iterable[NewsArticle]) -> int:
        """Extract claims from each article whose coarse scan tagged ≥1 ticker.

        Returns total claims persisted. Articles with empty
        `mentioned_tickers` are skipped (they would not produce
        Rule-6-compliant claims since the entity check requires entity
        grounding — saves LLM cost).
        """
        all_claims: list[ExtractedClaim] = []
        for article in articles:
            if not article.mentioned_tickers:
                continue
            claims = self.extractor.extract(article)
            all_claims.extend(claims)
        if not all_claims:
            return 0
        return self.claim_repo.save_many(all_claims)
