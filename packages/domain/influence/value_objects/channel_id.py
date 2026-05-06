"""ChannelId — stable identity value object for a Channel entity.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1.
"""

from __future__ import annotations

from dataclasses import dataclass

__all__ = ["ChannelId"]


@dataclass(frozen=True, slots=True)
class ChannelId:
    """Stable, opaque identifier for a KOL channel.

    For YouTube: typically the channel URL slug or Data API channel ID.
    For Telegram: numeric channel ID (normalised from @username).
    For Facebook: page ID or page slug.
    """

    value: str

    def __post_init__(self) -> None:
        if not self.value or not self.value.strip():
            raise ValueError("ChannelId.value must be a non-empty string")

    def __str__(self) -> str:
        return self.value
