"""BC-5 News Stream — Tier 2 Official Narrative.

Phase 2 thin slice (S36 Track D): NewsArticle + ExtractedClaim entities,
Sentiment 5-class StrEnum + ExtractorMetadata provenance bundle, NewsRepository
+ ClaimRepository Protocols, ClaimExtractionService orchestrator.

Aggregates deferred to Phase 3 per spec-T1-001 § B.2 + master-plan 005 § S36:
NewsCluster (cross-source story clustering), NewsSentimentScore (numeric
aggregation in application layer, never on entity per Rule 7),
broker-report-specific entity (Phase 3 once SSI/HSC/VCSC adapters land).

Cross-BC types (Ticker) live in packages/contracts/types/ per IMPL-S27-1.
This package only declares BC-5-private domain artifacts.
"""

from .models import (
    ExtractedClaim,
    ExtractedClaimInvariantError,
    NewsArticle,
    NewsArticleInvariantError,
)
from .repositories import ClaimRepository, NewsRepository
from .services import ClaimExtractionService, LlmExtractorProtocol
from .value_objects import (
    ExtractorMetadata,
    ExtractorMetadataInvariantError,
    Sentiment,
)

__all__ = [
    "ClaimExtractionService",
    "ClaimRepository",
    "ExtractedClaim",
    "ExtractedClaimInvariantError",
    "ExtractorMetadata",
    "ExtractorMetadataInvariantError",
    "LlmExtractorProtocol",
    "NewsArticle",
    "NewsArticleInvariantError",
    "NewsRepository",
    "Sentiment",
]
