"""Tests for BC-6 KOL platform adapters: YouTube, Telegram, Facebook.

Covers: public-only enforcement (BR-1) + cadence respect per platform.
≥6 tests (2 per platform) per plan § S46 Deliverable 14.
All network calls mocked — no live API calls in CI.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.4 + § A.3 BR-1.
"""

from __future__ import annotations

from collections.abc import Callable
from datetime import UTC, datetime, timedelta

import pytest

from packages.application.influence.ports.kol_channel_adapter_port import (
    KOLChannelAdapter,
    ToSBoundaryViolation,
)
from packages.domain.influence.models.channel import Channel, Platform
from packages.domain.influence.models.channel_content import ChannelContent
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.kol_id import KolId
from packages.infrastructure.influence.facebook_adapter import FacebookAdapter
from packages.infrastructure.influence.telegram_adapter import TelegramAdapter
from packages.infrastructure.influence.youtube_adapter import YouTubeAdapter

# --- Fixtures ---


def _frozen_clock(dt: datetime | None = None) -> Callable[[], datetime]:
    fixed = dt or datetime(2026, 5, 5, 12, 0, 0, tzinfo=UTC)
    return lambda: fixed


def make_youtube_channel(url: str = "https://www.youtube.com/@testkol") -> Channel:
    return Channel(
        channel_id=ChannelId("chan-yt-001"),
        platform=Platform.YOUTUBE,
        url=url,
        kol_id=KolId("kol-001"),
    )


def make_telegram_channel(url: str = "https://t.me/stocktest") -> Channel:
    return Channel(
        channel_id=ChannelId("chan-tg-001"),
        platform=Platform.TELEGRAM,
        url=url,
        kol_id=KolId("kol-002"),
    )


def make_facebook_channel(url: str = "https://www.facebook.com/stocktest") -> Channel:
    return Channel(
        channel_id=ChannelId("chan-fb-001"),
        platform=Platform.FACEBOOK,
        url=url,
        kol_id=KolId("kol-003"),
    )


# ========================================================
# YouTube Adapter Tests
# ========================================================


class TestYouTubeAdapterPublicEnforcement:
    """BR-1 public-only enforcement for YouTube."""

    def test_is_public_valid_youtube_channel(self) -> None:
        adapter = YouTubeAdapter(
            yt_dlp_runner=lambda _url, _opts: {},
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        assert adapter.is_public("https://www.youtube.com/@stockkol") is True

    def test_is_public_membership_url_raises_tos_violation(self) -> None:
        adapter = YouTubeAdapter(
            yt_dlp_runner=lambda _url, _opts: {},
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        with pytest.raises(ToSBoundaryViolation, match="private pattern"):
            adapter.is_public("https://www.youtube.com/channel/UCxxx/membership")

    def test_is_public_non_youtube_url_returns_false(self) -> None:
        adapter = YouTubeAdapter(
            yt_dlp_runner=lambda _url, _opts: {},
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        assert adapter.is_public("https://www.facebook.com/page") is False


class TestYouTubeAdapterFetch:
    """Fetch + cadence tests with mocked yt-dlp."""

    def test_fetch_new_content_returns_channel_content(self) -> None:
        """Mock yt-dlp returns one recent video; adapter wraps in ChannelContent."""
        now = datetime(2026, 5, 5, 20, 0, 0, tzinfo=UTC)
        yesterday = datetime(2026, 5, 4, 10, 0, 0, tzinfo=UTC)

        def mock_yt_dlp(
            _url: str, _opts: dict[str, object]
        ) -> dict[str, object]:
            return {
                "entries": [
                    {
                        "webpage_url": "https://www.youtube.com/watch?v=HPGanalysis",
                        "upload_date": "20260505",
                        "title": "HPG analysis",
                    }
                ]
            }

        adapter = YouTubeAdapter(
            yt_dlp_runner=mock_yt_dlp,
            clock=lambda: now,
            sleeper=lambda _s: None,
        )
        channel = make_youtube_channel()
        results = adapter.fetch_new_content(channel, since=yesterday)

        assert len(results) == 1
        assert isinstance(results[0], ChannelContent)
        assert "youtube.com" in results[0].source_url
        assert results[0].channel_id == ChannelId("chan-yt-001")

    def test_fetch_filters_old_content(self) -> None:
        """Videos before `since` are excluded from results."""
        now = datetime(2026, 5, 5, 20, 0, 0, tzinfo=UTC)
        since = datetime(2026, 5, 5, 0, 0, 0, tzinfo=UTC)

        # yt-dlp returns a video from 2026-05-04 (before since)
        def mock_yt_dlp_old(_url: str, _opts: dict[str, object]) -> dict[str, object]:
            return {
                "entries": [
                    {
                        "webpage_url": "https://www.youtube.com/watch?v=old",
                        "upload_date": "20260504",
                    }
                ]
            }

        adapter = YouTubeAdapter(
            yt_dlp_runner=mock_yt_dlp_old,
            clock=lambda: now,
            sleeper=lambda _s: None,
        )
        channel = make_youtube_channel()
        results = adapter.fetch_new_content(channel, since=since)
        assert results == []


# ========================================================
# Telegram Adapter Tests
# ========================================================


class TestTelegramAdapterPublicEnforcement:
    """BR-1 public-only enforcement for Telegram."""

    def test_is_public_with_valid_public_channel_mock(self) -> None:
        """Mocked getChat returns type=channel with username — is_public True."""

        def mock_api(method: str, _params: dict[str, object]) -> dict[str, object]:
            if method == "getChat":
                return {"result": {"type": "channel", "username": "stocktest"}}
            return {}

        adapter = TelegramAdapter(
            mock_api_caller=mock_api,
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        assert adapter.is_public("https://t.me/stocktest") is True

    def test_is_public_private_supergroup_raises_tos_violation(self) -> None:
        """Mocked getChat returns type=supergroup — raises ToSBoundaryViolation."""

        def mock_api(method: str, _params: dict[str, object]) -> dict[str, object]:
            if method == "getChat":
                return {"result": {"type": "supergroup"}}
            return {}

        adapter = TelegramAdapter(
            mock_api_caller=mock_api,
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        with pytest.raises(ToSBoundaryViolation, match="supergroup"):
            adapter.is_public("https://t.me/private_group")

    def test_is_public_no_token_no_mock_refuses_private_invite_patterns(self) -> None:
        """BR-1 fail-open hardening (M-S64-1): even without bot_token + mock,
        adapter must refuse t.me/+invite, t.me/joinchat/, t.me/c/ patterns
        and accept only canonical public @username/t.me/<slug> URLs.
        """
        adapter = TelegramAdapter(
            bot_token=None,
            mock_api_caller=None,
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        # Refuse: private invite patterns
        assert adapter.is_public("https://t.me/+private_invite_link") is False
        assert adapter.is_public("https://t.me/joinchat/abc123") is False
        assert adapter.is_public("https://t.me/c/1234567890") is False
        # Refuse: empty / non-alphanumeric slug
        assert adapter.is_public("") is False
        assert adapter.is_public("https://t.me/") is False
        assert adapter.is_public("https://t.me/!@#$%") is False
        # Accept: canonical public channel patterns
        assert adapter.is_public("https://t.me/stocktest") is True
        assert adapter.is_public("@stocktest") is True
        assert adapter.is_public("https://t.me/vn_stock_news") is True  # underscore allowed


class TestTelegramAdapterFetch:
    """Fetch + channel ID normalisation tests."""

    def test_fetch_new_content_with_mock_update(self) -> None:
        """Mocked getUpdates returns one channel post; adapter wraps in ChannelContent."""
        now = datetime.now(UTC)
        since = now - timedelta(hours=2)
        post_ts = int((now - timedelta(hours=1)).timestamp())

        def mock_api(method: str, _params: dict[str, object]) -> dict[str, object]:
            if method == "getChat":
                return {"result": {"type": "channel", "username": "stocktest"}}
            if method == "getUpdates":
                return {
                    "result": [
                        {
                            "channel_post": {
                                "message_id": 42,
                                "date": post_ts,
                                "text": "HPG: theo dõi kỹ lưỡng hôm nay",
                                "chat": {"username": "stocktest"},
                            }
                        }
                    ]
                }
            return {}

        adapter = TelegramAdapter(
            mock_api_caller=mock_api,
            clock=lambda: now,
            sleeper=lambda _s: None,
        )
        channel = make_telegram_channel()
        results = adapter.fetch_new_content(channel, since=since)

        assert len(results) == 1
        assert "t.me/stocktest/42" in results[0].source_url
        assert "HPG" in results[0].raw_text

    def test_channel_id_extraction_from_at_username(self) -> None:
        """@username format passes through unchanged."""
        result = TelegramAdapter._extract_chat_id("@stocktest")
        assert result == "@stocktest"

    def test_channel_id_extraction_from_tme_url(self) -> None:
        """t.me URL → @username."""
        result = TelegramAdapter._extract_chat_id("https://t.me/stocktest")
        assert result == "@stocktest"

    def test_channel_id_numeric_passthrough(self) -> None:
        """Numeric chat ID passes through unchanged."""
        result = TelegramAdapter._extract_chat_id("-1001234567890")
        assert result == "-1001234567890"


# ========================================================
# Facebook Adapter Tests
# ========================================================


class TestFacebookAdapterPublicEnforcement:
    """BR-1 public-only enforcement for Facebook."""

    def test_is_public_valid_fanpage_url(self) -> None:
        adapter = FacebookAdapter(
            mock_api_caller=lambda _ep, _params: {},
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        assert adapter.is_public("https://www.facebook.com/stockkol") is True

    def test_is_public_group_url_raises_tos_violation(self) -> None:
        adapter = FacebookAdapter(
            mock_api_caller=lambda _ep, _params: {},
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        with pytest.raises(ToSBoundaryViolation, match="groups/"):
            adapter.is_public("https://www.facebook.com/groups/stockgroup")

    def test_is_public_profile_url_raises_tos_violation(self) -> None:
        adapter = FacebookAdapter(
            mock_api_caller=lambda _ep, _params: {},
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        with pytest.raises(ToSBoundaryViolation, match="/profile.php"):
            adapter.is_public("https://www.facebook.com/profile.php?id=123")


class TestFacebookAdapterFetch:
    """Fetch + page ID extraction tests."""

    def test_fetch_new_content_with_mock_posts(self) -> None:
        """Mocked Graph API returns posts; adapter wraps in ChannelContent."""
        now = datetime.now(UTC)
        since = now - timedelta(hours=4)
        post_time = now - timedelta(hours=2)
        post_time_str = post_time.strftime("%Y-%m-%dT%H:%M:%S+0000")

        def mock_api(_endpoint: str, _params: dict[str, object]) -> dict[str, object]:
            return {
                "data": [
                    {
                        "message": "VIC: cẩn thận vùng giá 45k",
                        "created_time": post_time_str,
                        "permalink_url": "https://www.facebook.com/stocktest/posts/001",
                    }
                ]
            }

        adapter = FacebookAdapter(
            mock_api_caller=mock_api,
            page_id="stocktest",
            clock=lambda: now,
            sleeper=lambda _s: None,
        )
        channel = make_facebook_channel()
        results = adapter.fetch_new_content(channel, since=since)

        assert len(results) == 1
        assert "VIC" in results[0].raw_text
        assert "facebook.com" in results[0].source_url

    def test_fetch_skips_posts_without_permalink(self) -> None:
        """Posts without permalink_url are skipped (no provenance = BR-1 fail)."""
        now = datetime(2026, 5, 5, 12, 0, 0, tzinfo=UTC)
        since = datetime(2026, 5, 5, 8, 0, 0, tzinfo=UTC)

        def mock_api(_endpoint: str, _params: dict[str, object]) -> dict[str, object]:
            return {
                "data": [
                    {
                        "message": "some post",
                        "created_time": "2026-05-05T10:00:00+0000",
                        # No permalink_url
                    }
                ]
            }

        adapter = FacebookAdapter(
            mock_api_caller=mock_api,
            page_id="stocktest",
            clock=lambda: now,
            sleeper=lambda _s: None,
        )
        channel = make_facebook_channel()
        results = adapter.fetch_new_content(channel, since=since)
        assert results == []

    def test_page_id_extraction_from_url(self) -> None:
        """Fanpage URL → page slug extraction."""
        assert FacebookAdapter._extract_page_id("https://www.facebook.com/cafef") == "cafef"
        assert FacebookAdapter._extract_page_id("https://fb.com/stockkol") == "stockkol"

    def test_graph_api_auth_error_raises_tos_violation(self) -> None:
        """Graph API auth error (code 190) raises ToSBoundaryViolation per R1."""

        def mock_api(_endpoint: str, _params: dict[str, object]) -> dict[str, object]:
            return {
                "error": {
                    "code": 190,
                    "message": "Invalid OAuth access token.",
                }
            }

        adapter = FacebookAdapter(
            mock_api_caller=mock_api,
            page_id="stocktest",
            clock=_frozen_clock(),
            sleeper=lambda _s: None,
        )
        channel = make_facebook_channel()
        since = datetime(2026, 5, 4, 0, 0, 0, tzinfo=UTC)
        with pytest.raises(ToSBoundaryViolation, match="auth error"):
            adapter.fetch_new_content(channel, since=since)


# ========================================================
# Protocol compliance tests
# ========================================================


def test_youtube_adapter_is_protocol_compliant() -> None:
    """YouTubeAdapter satisfies KOLChannelAdapter Protocol (runtime check)."""
    adapter = YouTubeAdapter(
        yt_dlp_runner=lambda _url, _opts: {},
        clock=_frozen_clock(),
        sleeper=lambda _s: None,
    )
    assert isinstance(adapter, KOLChannelAdapter)


def test_telegram_adapter_is_protocol_compliant() -> None:
    adapter = TelegramAdapter(
        mock_api_caller=lambda _m, _p: {},
        clock=_frozen_clock(),
        sleeper=lambda _s: None,
    )
    assert isinstance(adapter, KOLChannelAdapter)


def test_facebook_adapter_is_protocol_compliant() -> None:
    adapter = FacebookAdapter(
        mock_api_caller=lambda _ep, _p: {},
        clock=_frozen_clock(),
        sleeper=lambda _s: None,
    )
    assert isinstance(adapter, KOLChannelAdapter)
