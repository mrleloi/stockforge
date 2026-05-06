"""TelegramAdapter — BC-6 KOL channel adapter for Telegram public broadcast channels.

Fetches messages from public Telegram broadcast channels via the Bot API.
Only PUBLIC broadcast channels are supported (BR-1). Private groups, supergroups
requiring invite links, and direct messages are refused.

Rate limit: ~1 req/s via Bot API (per platform rate-limit matrix).
Cadence: every 1h per spec § B.7.

Channel ID formats (Q-S46-3 IMPL decision: support both; normalise to numeric):
- @channel_name format → API resolves to numeric
- -1001234567890 format → used directly

Bot API endpoint: GET /bot{TOKEN}/getUpdates or /bot{TOKEN}/getMessages
For public channels: use getChat to verify public status, then forwardMessages.

BR-1 enforcement: `is_public` calls getChat API to verify channel type.
Private supergroups return type="supergroup"; public channels return type="channel".

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

__all__ = ["TelegramAdapter"]

logger = logging.getLogger(__name__)

_TELEGRAM_API_BASE = "https://api.telegram.org"
_RATE_LIMIT_SECONDS = 1.0  # Bot API allows ~1 req/s per channel
_MAX_MESSAGES_PER_FETCH = 50  # Conservative; daily cadence expects few messages


@dataclass
class TelegramAdapter:
    """Telegram public broadcast channel adapter.

    Args:
        bot_token:  Telegram Bot API token. Required for API calls.
                    Tests inject None and provide a mock_api_caller.
        mock_api_caller: Callable(url) -> dict for test injection.
        clock:      Callable() -> datetime for deterministic test time.
        sleeper:    Callable(float) -> None for test injection.
    """

    bot_token: str | None = None
    mock_api_caller: Callable[[str, dict[str, object]], dict[str, object]] | None = None
    clock: Callable[[], datetime] = field(default_factory=lambda: lambda: datetime.now(UTC))
    sleeper: Callable[[float], None] = field(
        default_factory=lambda: __import__("time").sleep
    )
    _fetcher: RateLimitedFetcher = field(init=False, repr=False)

    def __post_init__(self) -> None:
        self._fetcher = RateLimitedFetcher(
            platform="telegram",
            rate_limit_seconds=_RATE_LIMIT_SECONDS,
            sleeper=self.sleeper,
            clock=self.clock,
        )

    def _api_url(self, method: str) -> str:
        return f"{_TELEGRAM_API_BASE}/bot{self.bot_token}/{method}"

    def _call_api(
        self, method: str, params: dict[str, object] | None = None
    ) -> dict[str, object]:
        """Call Telegram Bot API. Uses mock_api_caller in tests."""
        if self.mock_api_caller is not None:
            return self.mock_api_caller(method, params or {})
        if not self.bot_token:
            raise RuntimeError("TelegramAdapter requires bot_token for live calls")
        url = self._api_url(method)
        if params:
            import urllib.parse
            url = f"{url}?{urllib.parse.urlencode(params)}"
        result = self._fetcher._fetch(url)
        try:
            data: dict[str, object] = json.loads(result.content)
            return data
        except json.JSONDecodeError as exc:
            logger.warning("Telegram API JSON parse error for %s: %s", method, exc)
            return {}

    def is_public(self, channel_url: str) -> bool:
        """Return True if the Telegram channel is a public broadcast channel.

        Public channels have a @username and type="channel" in getChat response.
        Private supergroups, private groups, and DMs raise ToSBoundaryViolation.

        BR-1 fail-open hardening (M-S64-1): even without bot_token, refuse
        URLs matching private-invite patterns (`t.me/+...`, `t.me/joinchat/...`,
        `t.me/c/...`) to prevent autonomous-pipeline accidentally treating
        private-invite links as public per BR-1.
        """
        if not channel_url:
            return False

        # BR-1 hard refusals (apply BEFORE _extract_chat_id strips the path):
        # private invite patterns must never pass `is_public`, even when no
        # bot_token is wired — the BR-1 gatekeeper is the only line of defense.
        if (
            channel_url.startswith("https://t.me/+")
            or channel_url.startswith("https://t.me/joinchat/")
            or channel_url.startswith("https://t.me/c/")
        ):
            return False

        chat_id = self._extract_chat_id(channel_url)
        if not chat_id:
            return False

        # If we can't call API (no token + no mock), optimistically allow only
        # canonical public-channel patterns: t.me/<plain_slug> or @<plain_slug>.
        # Private-invite patterns already refused above; here we additionally
        # require the slug to look like a username (alphanumeric + underscore).
        if self.mock_api_caller is None and not self.bot_token:
            slug = chat_id.lstrip("@")
            if not slug or not slug.replace("_", "").isalnum():
                return False
            return channel_url.startswith("https://t.me/") or chat_id.startswith("@")

        response = self._call_api("getChat", {"chat_id": chat_id})
        result = response.get("result")
        result_dict: dict[str, object] = result if isinstance(result, dict) else {}
        chat_type = result_dict.get("type", "")
        if chat_type != "channel":
            raise ToSBoundaryViolation(
                f"Telegram chat {chat_id!r} has type={chat_type!r}; "
                "only public broadcast channels (type='channel') allowed per BR-1"
            )
        # Verify it has a username (truly public)
        username = result_dict.get("username")
        if not username:
            raise ToSBoundaryViolation(
                f"Telegram channel {chat_id!r} has no public @username — "
                "likely private channel; refusing per BR-1"
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
        """Fetch messages from a public Telegram channel published after `since`.

        Uses Bot API getUpdates or channel history endpoint.
        Returns ChannelContent with raw_text = message text.
        source_url = message link (t.me/channel/message_id format).

        Q-S46-3: supports both @channel_name and numeric chat ID formats.
        """
        chat_id = self._extract_chat_id(channel.url)
        if not chat_id:
            logger.warning(
                "Cannot extract chat_id from channel URL %s", channel.url
            )
            return []

        # Verify public access before fetching
        if not self.is_public(channel.url):
            raise ToSBoundaryViolation(
                f"Channel {channel.channel_id} is not a public Telegram broadcast channel"
            )

        response = self._call_api(
            "getUpdates",
            {
                "chat_id": chat_id,
                "limit": _MAX_MESSAGES_PER_FETCH,
                "allowed_updates": ["channel_post"],
            },
        )

        updates = response.get("result", [])
        if not isinstance(updates, list):
            updates = []

        results: list[ChannelContent] = []
        for update in updates:
            post = update.get("channel_post") or update.get("message")
            if not post:
                continue

            # Convert Unix timestamp to UTC datetime
            date_unix = post.get("date", 0)
            published_at = datetime.fromtimestamp(date_unix, tz=UTC)
            if published_at <= since:
                continue

            text = post.get("text") or post.get("caption") or ""
            message_id = post.get("message_id", "")
            chat_username = post.get("chat", {}).get("username", "")

            # Construct message link (source_url for provenance BR-1)
            if chat_username:
                source_url = f"https://t.me/{chat_username}/{message_id}"
            else:
                source_url = f"{channel.url}/{message_id}"

            content_id = self._make_content_id(source_url)
            content = ChannelContent(
                content_id=content_id,
                channel_id=channel.channel_id,
                source_url=source_url,
                published_at=published_at,
                raw_text=text,
                fetched_at=self.clock(),
            )
            results.append(content)
            logger.info(
                "telegram_adapter fetched message channel=%s url=%s text_len=%d",
                channel.channel_id,
                source_url,
                len(text),
            )

        return results

    @staticmethod
    def _extract_chat_id(channel_url: str) -> str:
        """Extract chat ID or @username from channel URL.

        Supports:
        - https://t.me/channel_name → @channel_name
        - @channel_name → @channel_name (passthrough)
        - -1001234567890 → -1001234567890 (numeric passthrough)
        """
        if not channel_url:
            return ""
        if channel_url.startswith("-") and channel_url[1:].isdigit():
            return channel_url  # numeric ID
        if channel_url.startswith("@"):
            return channel_url  # @username passthrough
        # Try to extract from t.me URL
        if "t.me/" in channel_url:
            parts = channel_url.split("t.me/")
            if len(parts) > 1:
                slug = parts[1].split("/")[0].strip()
                if slug:
                    return f"@{slug}"
        return channel_url

    @staticmethod
    def _make_content_id(source_url: str) -> str:
        """Deterministic content ID from source URL."""
        return hashlib.sha256(source_url.encode("utf-8")).hexdigest()[:16]
