"""FacebookAdapter — BC-6 KOL channel adapter for Facebook public fanpages.

Fetches posts from Facebook public fanpages via the Graph API v18+.
ONLY public fanpage posts are supported (BR-1 + Q-P3-2 user explicit accept).

Gray-zone acknowledged (Q-P3-2 user-accept 2026-05-05):
Facebook Graph API terms restrict automated scraping. This adapter:
- Uses ONLY public fanpage endpoints (Page Public Content Access permission).
- NEVER accesses private groups, personal profiles, or authenticated feeds.
- Refuses on 401/403 (ToSBoundaryViolation).
- Raises ToSBoundaryViolation if detected as non-fanpage (personal profile/group).
- Falls back to manual-link-list mode on API auth shifts (R1 risk).

Rate limit: ~2 req/s per platform rate-limit matrix (Graph API is more lenient).
Cadence: every 4h during 08:00-22:00 per spec § B.7.
IMPL decision Q-S46-2: YES restrict to v18+ public-page-posts only.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.4 + § B.7.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § b).
Skill: .claude/skills/crawler-reliability/SKILL.md.
"""

from __future__ import annotations

import hashlib
import json
import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.application.influence.ports.kol_channel_adapter_port import (
    ToSBoundaryViolation,
)
from packages.domain.influence.models.channel import Channel
from packages.domain.influence.models.channel_content import ChannelContent
from packages.infrastructure.influence.rate_limited_fetcher import RateLimitedFetcher

__all__ = ["FacebookAdapter"]

logger = logging.getLogger(__name__)

_GRAPH_API_BASE = "https://graph.facebook.com/v18.0"
_RATE_LIMIT_SECONDS = 0.5  # ~2 req/s per platform matrix
_MAX_POSTS_PER_FETCH = 25  # Conservative; 4h cadence expects ~5-10 new posts
_REQUIRED_PAGE_FIELDS = "id,name,fan_count,posts.limit(25){message,created_time,permalink_url}"

# URL patterns that indicate non-fanpage content (refuse per BR-1)
_REFUSE_URL_PATTERNS = (
    "groups/",
    "/profile.php",
    "/people/",
)


@dataclass
class FacebookAdapter:
    """Facebook public fanpage adapter.

    Args:
        access_token:   Facebook App access token (Page Public Content Access).
                        None = tests use mock_api_caller only.
        page_id:        Facebook page ID or slug. If None, extracted from channel URL.
        mock_api_caller: Callable(endpoint, params) -> dict for test injection.
        clock:          Callable() -> datetime for deterministic test time.
        sleeper:        Callable(float) -> None for test injection.

    ToS gray-zone note: Per Q-P3-2 user-accept (2026-05-05), this adapter
    operates in acknowledged gray zone. If Graph API auth requirements shift
    mid-Phase-3, the adapter raises ToSBoundaryViolation immediately and the
    caller falls back to manual-link-list mode. This is R1 (HIGH) risk —
    monitored per session.
    """

    access_token: str | None = None
    page_id: str | None = None
    mock_api_caller: Callable[[str, dict[str, object]], dict[str, object]] | None = None
    clock: Callable[[], datetime] = field(default_factory=lambda: lambda: datetime.now(UTC))
    sleeper: Callable[[float], None] = field(
        default_factory=lambda: __import__("time").sleep
    )
    _fetcher: RateLimitedFetcher = field(init=False, repr=False)

    def __post_init__(self) -> None:
        self._fetcher = RateLimitedFetcher(
            platform="facebook",
            rate_limit_seconds=_RATE_LIMIT_SECONDS,
            sleeper=self.sleeper,
            clock=self.clock,
        )

    def _call_graph_api(
        self, endpoint: str, params: dict[str, object] | None = None
    ) -> dict[str, object]:
        """Call Facebook Graph API. Uses mock_api_caller in tests."""
        if self.mock_api_caller is not None:
            data: dict[str, object] = self.mock_api_caller(endpoint, params or {})
            # Error checking applies even on mock path (tests the auth-error branch)
            if "error" in data:
                err = data["error"]
                if isinstance(err, dict) and err.get("code") in (190, 200, 102, 10):
                    raise ToSBoundaryViolation(
                        f"Facebook Graph API auth error for {endpoint!r}: "
                        f"code={err.get('code')} message={err.get('message')} — "
                        "ToS shift detected; falling back to manual-link-list mode"
                    )
            return data
        if not self.access_token:
            raise RuntimeError("FacebookAdapter requires access_token for live calls")

        import urllib.parse

        all_params: dict[str, object] = dict(params or {})
        all_params["access_token"] = self.access_token
        url = f"{_GRAPH_API_BASE}/{endpoint.lstrip('/')}?{urllib.parse.urlencode(all_params)}"
        result = self._fetcher._fetch(url)
        try:
            raw: dict[str, object] = json.loads(result.content)
        except json.JSONDecodeError as exc:
            logger.warning("Graph API JSON parse error for %s: %s", endpoint, exc)
            return {}

        # Detect auth errors — signal ToS shift per R1 mitigation
        if "error" in raw:
            err = raw["error"]
            if isinstance(err, dict) and err.get("code") in (190, 200, 102, 10):
                raise ToSBoundaryViolation(
                    f"Facebook Graph API auth error for {endpoint!r}: "
                    f"code={err.get('code')} message={err.get('message')} — "
                    "ToS shift detected; falling back to manual-link-list mode"
                )
        return raw

    def is_public(self, channel_url: str) -> bool:
        """Return True if the Facebook URL is a public fanpage.

        Refuses:
        - Group URLs (groups/) — BR-1 violation.
        - Personal profile URLs (profile.php, /people/) — BR-1 violation.
        - Empty or non-Facebook URLs.
        """
        if not channel_url or "facebook.com" not in channel_url:
            return False

        lower = channel_url.lower()
        for pattern in _REFUSE_URL_PATTERNS:
            if pattern in lower:
                raise ToSBoundaryViolation(
                    f"Facebook URL {channel_url!r} matches non-fanpage pattern "
                    f"{pattern!r}; refusing per BR-1 public-only rule. "
                    "Only public fanpages are supported (IMPL decision Q-S46-2)."
                )
        return True

    def respect_rate_limit(self) -> None:
        """Delegate to shared fetcher rate limiter."""
        self._fetcher.respect_rate_limit()

    def fetch_new_content(
        self,
        channel: Channel,
        since: datetime,
    ) -> list[ChannelContent]:
        """Fetch posts from a Facebook public fanpage published after `since`.

        Uses Graph API v18+ /page-id/posts endpoint with message + created_time.
        Returns ChannelContent with raw_text = post message text.
        source_url = permalink_url for provenance (BR-1 + I-S2).

        Cadence awareness: caller should only invoke during 08:00-22:00 (spec § B.7).
        This adapter does NOT enforce cadence internally — the scheduler controls timing.
        """
        if not self.is_public(channel.url):
            raise ToSBoundaryViolation(
                f"Channel {channel.channel_id} URL {channel.url!r} is not a public fanpage"
            )

        page_id = self.page_id or self._extract_page_id(channel.url)
        if not page_id:
            logger.warning("Cannot extract page_id from %s", channel.url)
            return []

        since_ts = int(since.timestamp())
        response = self._call_graph_api(
            f"{page_id}/posts",
            {
                "fields": "message,created_time,permalink_url",
                "limit": _MAX_POSTS_PER_FETCH,
                "since": since_ts,
            },
        )

        raw_data = response.get("data", [])
        if not isinstance(raw_data, list):
            raw_data = []

        results: list[ChannelContent] = []
        for post in raw_data:
            message = post.get("message") or post.get("story") or ""
            permalink = post.get("permalink_url") or ""
            created_time_str = post.get("created_time", "")

            if not permalink:
                continue  # No provenance source_url — skip per BR-1

            try:
                published_at = datetime.fromisoformat(
                    created_time_str.replace("+0000", "+00:00")
                )
            except (ValueError, AttributeError):
                published_at = self.clock()

            if published_at <= since:
                continue

            content_id = self._make_content_id(permalink)
            content = ChannelContent(
                content_id=content_id,
                channel_id=channel.channel_id,
                source_url=permalink,
                published_at=published_at,
                raw_text=message,
                fetched_at=self.clock(),
            )
            results.append(content)
            logger.info(
                "facebook_adapter fetched post channel=%s url=%s text_len=%d",
                channel.channel_id,
                permalink,
                len(message),
            )

        return results

    @staticmethod
    def _extract_page_id(channel_url: str) -> str:
        """Extract Facebook page ID or slug from URL.

        Examples:
        - https://www.facebook.com/cafef → cafef
        - https://www.facebook.com/pages/Name/123456789 → 123456789
        - https://fb.com/stockkol → stockkol
        """
        if not channel_url:
            return ""
        # Strip trailing slashes and query params
        url = channel_url.rstrip("/").split("?")[0]
        for prefix in ("https://www.facebook.com/", "https://fb.com/", "http://facebook.com/"):
            if url.startswith(prefix):
                remainder = url[len(prefix):]
                # /pages/Name/123 → take last numeric part
                if remainder.startswith("pages/"):
                    parts = remainder.split("/")
                    if len(parts) >= 3 and parts[-1].isdigit() or len(parts) >= 2:
                        return parts[-1]
                return remainder.split("/")[0]
        # Last resort: split on facebook.com/
        if "facebook.com/" in url:
            return url.split("facebook.com/")[1].split("/")[0]
        return ""

    @staticmethod
    def _make_content_id(source_url: str) -> str:
        """Deterministic content ID from source URL."""
        return hashlib.sha256(source_url.encode("utf-8")).hexdigest()[:16]
