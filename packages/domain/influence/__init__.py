"""BC-6 Influence Network — domain layer public API.

Track G (S46): value objects + Kol/Channel/ChannelContent models.
Track H (S47): Recommendation model (LLM extraction scope).
Track I (S49): CredibilityScore + OutcomeReview + domain services.

Source: specs/tier2-feature/002-influence-network-tracking.md.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md.
"""

from .models.channel import Channel, Platform
from .models.channel_content import ChannelContent
from .models.kol import InvariantViolation, Kol
from .value_objects.channel_id import ChannelId
from .value_objects.intent import Intent
from .value_objects.kol_id import KolId
from .value_objects.kol_status import KolStatus
from .value_objects.kol_style import KolStyle
from .value_objects.recommendation_id import RecommendationId
from .value_objects.timeframe import Timeframe

__all__ = [
    "Channel",
    "ChannelContent",
    "ChannelId",
    "Intent",
    "InvariantViolation",
    "Kol",
    "KolId",
    "KolStatus",
    "KolStyle",
    "Platform",
    "RecommendationId",
    "Timeframe",
]
