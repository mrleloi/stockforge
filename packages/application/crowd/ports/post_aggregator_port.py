"""PostAggregatorPort — Protocol for crowd source aggregators (BC-7).

Per D-032 § (b): shared Protocol + 3 concrete impls (F319 + FacebookPublicGroup +
ArticleComments). Concrete impls live in packages/infrastructure/crowd/aggregators/.

BR-1 public-only enforcement contract:
- is_public() MUST return False for known-private URLs.
- fetch_recent() MUST raise ToSBoundaryViolation before accessing any private content.
  Mirror BC-6 telegram_adapter S64 hardening: 3 hard-refusal guards BEFORE content fetch.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-1 + B.4.
ADR: D-032 § (b).
"""

from __future__ import annotations

from datetime import datetime
from typing import Protocol, runtime_checkable

from packages.domain.crowd.raw_post import RawPost

__all__ = ["PostAggregatorPort", "ToSBoundaryViolation"]


class ToSBoundaryViolation(RuntimeError):
    """Raised when an aggregator detects an attempt to access non-public content.

    Per BR-1: aggregators MUST refuse private URLs and raise this exception before
    any content is fetched. Callers fall back to manual link-list mode per D-032 § R1.
    """


@runtime_checkable
class PostAggregatorPort(Protocol):
    """Protocol that all 3 crowd-source aggregators must implement.

    Implementations live in packages/infrastructure/crowd/aggregators/:
    - f319_forum_aggregator.F319ForumAggregator
    - facebook_public_group_aggregator.FacebookPublicGroupAggregator
    - article_comments_aggregator.ArticleCommentsAggregator
    """

    def fetch_recent(
        self,
        ticker: str,
        since: datetime,
    ) -> list[RawPost]:
        """Fetch public posts mentioning `ticker` published after `since`.

        Raises ToSBoundaryViolation if any fetched URL is private/auth-required.
        Returns empty list when no new content is available.

        Rate-limit: implementations call respect_rate_limit() before each request.
        Cadence (spec § B.7): F319 30min; FB 2h; CafeF/Vietstock 2h.
        """
        ...

    def is_public(self, source_url: str) -> bool:
        """Return True if the URL points to publicly accessible content.

        MUST return False for:
        - Facebook groups requiring login or group membership.
        - Any URL with auth tokens in query params.
        - Restricted sections (F319 login-required subforums).

        BR-1 hard refusal: check URL patterns BEFORE making any HTTP request.
        Mirror telegram_adapter S64 pattern: 3 guards before chat_id extraction.
        """
        ...

    def respect_rate_limit(self) -> None:
        """Block until the per-platform rate limit window has elapsed.

        Rate matrix (spec § B.7 + R-P3-2 mitigation):
        - F319: 2 req/s (A1 strategy)
        - Facebook Graph API: 2 req/s (A3 strategy)
        - CafeF/Vietstock: 1 req/s (A1 strategy)
        """
        ...
