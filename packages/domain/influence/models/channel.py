"""Channel — BC-6 channel aggregate.

Represents a KOL's publication channel on a specific platform.
Platform is embedded as a StrEnum (per plan § Deliverable 3).

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § B.4.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.kol_id import KolId

__all__ = ["Channel", "Platform"]


class Platform(StrEnum):
    """Supported content platforms.

    BR-1: PUBLIC channels only — no private groups, no paid leaks.
    """

    YOUTUBE = "youtube"
    TELEGRAM = "telegram"
    FACEBOOK = "facebook"
    PODCAST = "podcast"
    BLOG = "blog"


@dataclass
class Channel:
    """Channel aggregate: a KOL's publication venue on one platform.

    `url` is the canonical public URL (enforced non-empty per BR-1 provenance).
    `subscriber_count` is optional metadata refreshed periodically.
    `last_scraped_at` is updated by the infrastructure adapter on each run.
    """

    channel_id: ChannelId
    platform: Platform
    url: str
    kol_id: KolId
    subscriber_count: int | None = None
    last_scraped_at: datetime | None = None

    def __post_init__(self) -> None:
        if not self.url or not self.url.strip():
            raise ValueError("Channel.url must be a non-empty string (BR-1 provenance)")
