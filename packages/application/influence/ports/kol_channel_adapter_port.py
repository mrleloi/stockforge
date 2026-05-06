"""KOLChannelAdapter — Protocol for KOL channel ingestion adapters.

Defines the port that all 3 platform adapters (YouTube, Telegram, Facebook)
must implement. Per D-027(b): Shared Protocol + 3 concrete implementations.

`fetch_new_content` returns ChannelContent objects for content published after
`since`. Adapters MUST NOT return private or authenticated content (BR-1).

`is_public` performs a lightweight pre-flight check before fetch. Adapters
MUST raise ToSBoundaryViolation if the URL requires authentication.

`respect_rate_limit` is a synchronous pause hook; called by the shared
RateLimitedFetcher base class before each network request.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.4.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § b).
"""

from __future__ import annotations

from datetime import datetime
from typing import Protocol, runtime_checkable

from packages.domain.influence.models.channel import Channel
from packages.domain.influence.models.channel_content import ChannelContent

__all__ = ["KOLChannelAdapter", "ToSBoundaryViolation"]


class ToSBoundaryViolation(RuntimeError):
    """Raised when an adapter detects an attempt to access non-public content.

    Per BR-1: adapters MUST refuse private/authenticated URLs and raise this
    exception so callers can fall back to manual-link-list mode.
    """


@runtime_checkable
class KOLChannelAdapter(Protocol):
    """Protocol that all platform adapters must implement.

    Implementations live in `packages/infrastructure/influence/`:
    - `youtube_adapter.YouTubeAdapter`
    - `telegram_adapter.TelegramAdapter`
    - `facebook_adapter.FacebookAdapter`
    """

    def fetch_new_content(
        self,
        channel: Channel,
        since: datetime,
    ) -> list[ChannelContent]:
        """Fetch new public content published after `since`.

        Raises ToSBoundaryViolation if channel URL is private/authenticated.
        Returns empty list when no new content is available.
        """
        ...

    def is_public(self, channel_url: str) -> bool:
        """Return True if the URL points to publicly accessible content.

        Adapters MUST return False for:
        - URLs requiring login (Facebook groups, private Telegram groups).
        - URLs with access tokens in query params.
        - Paid/subscription content behind paywall.
        """
        ...

    def respect_rate_limit(self) -> None:
        """Block until the per-platform rate limit window has elapsed.

        Called by RateLimitedFetcher base class before each request.
        Implementations typically delegate to the base class timer.
        """
        ...
