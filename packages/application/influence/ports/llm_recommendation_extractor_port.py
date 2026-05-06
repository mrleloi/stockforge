"""LLMRecommendationExtractorPort — application port for LLM-based extractor.

Protocol that the infrastructure `LLMRecommendationExtractor` implements.
Follows the application-layer port pattern: pure Protocol with no framework
dependencies. Infrastructure implementations inject via DI at the use-case level.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-1 + § B.4.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § d).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from packages.domain.influence.models.channel_content import ChannelContent
from packages.domain.influence.models.recommendation import Recommendation

__all__ = ["LLMRecommendationExtractorPort"]


@runtime_checkable
class LLMRecommendationExtractorPort(Protocol):
    """Port for extracting Recommendation entities from KOL transcript text.

    Implementation lives at:
    `packages/infrastructure/influence/llm_recommendation_extractor.py`

    The port purposely keeps the signature narrow:
    - `transcript` is the full plain-text transcript (post-Whisper or text post).
    - `source_metadata` carries provenance fields (source_url, channel_id,
      published_at) needed to hydrate each Recommendation aggregate.

    Callers (UC-1 `IngestChannelContentUseCase`) are responsible for routing:
    - extraction_confidence >= 0.7  → recommendation_repo.save()
    - extraction_confidence < 0.7   → manual_review_queue.enqueue()
    This split is enforced in use-case code, not in the port.
    """

    def extract(
        self,
        transcript: str,
        source_metadata: ChannelContent,
    ) -> list[Recommendation]:
        """Extract Recommendation entities from `transcript`.

        Args:
            transcript:      Full plain-text content to analyse. For video
                             sources this is the Whisper-transcribed text;
                             for text posts this is the raw post body.
            source_metadata: ChannelContent value object carrying provenance
                             fields (source_url, channel_id, published_at).

        Returns:
            List of Recommendation aggregates. Returns an empty list when no
            extractable recommendations are detected. Each Recommendation has
            its `requires_manual_review` flag set based on extraction_confidence.

        Raises:
            LLMExtractionError: if the substrate call fails or the response
                                cannot be parsed after all 3 fallback tiers.
        """
        ...
