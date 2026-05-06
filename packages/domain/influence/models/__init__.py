"""BC-6 Influence Network — domain model barrel export.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027).
"""

from .channel import Channel, Platform
from .channel_content import ChannelContent
from .credibility_score import CredibilityScore
from .credibility_score import InvariantViolation as CredibilityScoreInvariantViolation
from .kol import InvariantViolation, Kol
from .outcome_review import (
    InvariantViolation as OutcomeReviewInvariantViolation,
)
from .outcome_review import (
    OutcomeReview,
    OutcomeStatus,
    ReviewWindow,
    window_offset,
)
from .recommendation import InvariantViolation as RecommendationInvariantViolation
from .recommendation import Recommendation

__all__ = [
    "Channel",
    "ChannelContent",
    "CredibilityScore",
    "CredibilityScoreInvariantViolation",
    "InvariantViolation",
    "Kol",
    "OutcomeReview",
    "OutcomeReviewInvariantViolation",
    "OutcomeStatus",
    "Platform",
    "Recommendation",
    "RecommendationInvariantViolation",
    "ReviewWindow",
    "window_offset",
]
