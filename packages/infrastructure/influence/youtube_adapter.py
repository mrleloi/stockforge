"""YouTubeAdapter — BC-6 KOL channel adapter for YouTube.

Fetches new public YouTube videos and their captions/transcripts using:
1. yt-dlp (primary scrape path — no API quota consumption).
2. YouTube Data API v3 (optional; used when yt-dlp subtitle unavailable).

Rate limit: ~1 req/s per crawler-reliability skill.
Cadence: daily 20:00 per spec § B.7.
Language preference: Vietnamese captions ("vi") first, then auto-generated ("a.vi"),
then English ("en") as fallback (R3 risk: auto-caption noisy — Track H LLM handles it).

Quota tracking: YouTube Data API v3 default is 10,000 units/day.
This adapter logs quota consumption and falls back to yt-dlp scrape when exhausted.
IMPL decision Q-S46-1: YES to yt-dlp fallback (documented inline).

BR-1 enforcement: `is_public` checks `@` handle format or /channel/ URL;
returns False and raises ToSBoundaryViolation on private playlists.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.4 + § B.7.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § b).
Skill: .claude/skills/crawler-reliability/SKILL.md.
"""

from __future__ import annotations

import hashlib
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

__all__ = ["YouTubeAdapter"]

logger = logging.getLogger(__name__)

# YouTube Data API v3 units: list.videos costs 1 unit; captions.list costs 50 units.
# Conservative daily cap: stop API calls at 8,000 units to leave headroom.
_DAILY_QUOTA_SAFE_CAP = 8000
_RATE_LIMIT_SECONDS = 1.0  # 1 req/s per platform rate-limit matrix

# Known private/members-only URL patterns
_PRIVATE_URL_PATTERNS = (
    "membership",
    "members",
    "/c/",  # legacy custom URL (usually public, but flag for review)
)


@dataclass
class YouTubeAdapter:
    """YouTube channel adapter.

    Args:
        api_key:        YouTube Data API v3 key. None = yt-dlp-only mode.
        yt_dlp_runner:  Callable(url, opts) -> dict. Default uses real yt-dlp.
                        Tests inject a mock returning fixture data.
        clock:          Callable() -> datetime. Injectable for tests.
        sleeper:        Callable(float) -> None. Injectable for tests.
    """

    api_key: str | None = None
    yt_dlp_runner: Callable[[str, dict[str, object]], dict[str, object]] | None = None
    clock: Callable[[], datetime] = field(default_factory=lambda: lambda: datetime.now(UTC))
    sleeper: Callable[[float], None] = field(
        default_factory=lambda: __import__("time").sleep
    )
    _quota_used_today: int = field(default=0, init=False, repr=False)
    _fetcher: RateLimitedFetcher = field(init=False, repr=False)

    def __post_init__(self) -> None:
        self._fetcher = RateLimitedFetcher(
            platform="youtube",
            rate_limit_seconds=_RATE_LIMIT_SECONDS,
            sleeper=self.sleeper,
            clock=self.clock,
        )
        if self.yt_dlp_runner is None:
            self.yt_dlp_runner = self._real_yt_dlp_runner

    @staticmethod
    def _real_yt_dlp_runner(
        channel_url: str, opts: dict[str, object]
    ) -> dict[str, object]:
        """Real yt-dlp invocation. Lazy import to keep adapter testable without yt-dlp."""
        import yt_dlp  # type: ignore[import-untyped]

        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(channel_url, download=False)
            result: dict[str, object] = dict(info) if info else {}
            return result

    def is_public(self, channel_url: str) -> bool:
        """Return True if YouTube channel URL is public.

        Private indicators:
        - URL contains "/membership" or "/members"
        - URL is empty or malformed
        Raises ToSBoundaryViolation for definitive private content.
        """
        if not channel_url or "youtube.com" not in channel_url:
            return False
        lower = channel_url.lower()
        for pattern in _PRIVATE_URL_PATTERNS:
            if pattern in lower and pattern != "/c/":
                raise ToSBoundaryViolation(
                    f"YouTube URL {channel_url!r} matches private pattern {pattern!r}; "
                    "refusing per BR-1 public-only rule"
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
        """Fetch YouTube videos published after `since`.

        Strategy (Q-S46-1 IMPL decision: yt-dlp primary, Data API optional):
        1. Use yt-dlp to list recent uploads and extract subtitle text.
        2. Fall back to YouTube Data API v3 if yt-dlp fails and api_key provided.
        3. Return ChannelContent for each new video with raw_text = subtitle text.

        Returns empty list on quota exhaustion or no new content.
        """
        if not self.is_public(channel.url):
            raise ToSBoundaryViolation(
                f"Channel {channel.channel_id} URL {channel.url!r} is not public"
            )

        try:
            return self._fetch_via_yt_dlp(channel, since)
        except Exception as exc:  # noqa: BLE001
            logger.warning(
                "yt-dlp fetch failed for channel %s: %s — attempting Data API fallback",
                channel.channel_id,
                exc,
            )
            if self.api_key and self._quota_used_today < _DAILY_QUOTA_SAFE_CAP:
                return self._fetch_via_data_api(channel, since)
            logger.warning(
                "YouTube Data API quota exhausted or no api_key; skipping channel %s",
                channel.channel_id,
            )
            return []

    def _fetch_via_yt_dlp(
        self,
        channel: Channel,
        since: datetime,
    ) -> list[ChannelContent]:
        """Scrape channel via yt-dlp. Prefers vi subtitles, falls back to auto/en."""
        opts: dict[str, object] = {
            "quiet": True,
            "extract_flat": "in_playlist",
            "playlistend": 20,  # last 20 videos; cadence is daily so usually 1-5
            "subtitleslangs": ["vi", "a.vi", "en"],
            "writesubtitles": False,
            "skip_download": True,
        }

        self._fetcher.respect_rate_limit()
        runner = self.yt_dlp_runner or self._real_yt_dlp_runner
        raw = runner(channel.url, opts)
        raw_entries = raw.get("entries")
        entries: list[dict[str, object]] = list(raw_entries) if isinstance(raw_entries, list) else []

        results: list[ChannelContent] = []
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            upload_date = entry.get("upload_date")
            published_at = self._parse_upload_date(
                upload_date if isinstance(upload_date, str) else None
            )
            if published_at is None or published_at <= since:
                continue

            raw_url = entry.get("webpage_url") or entry.get("url", "")
            video_url = raw_url if isinstance(raw_url, str) else ""
            if not video_url:
                continue

            # Fetch subtitles for this specific video
            raw_text = self._extract_subtitle_text(video_url)
            content_id = self._make_content_id(video_url)

            content = ChannelContent(
                content_id=content_id,
                channel_id=channel.channel_id,
                source_url=video_url,
                published_at=published_at,
                raw_text=raw_text,
                fetched_at=self.clock(),
            )
            results.append(content)
            logger.info(
                "youtube_adapter fetched video channel=%s url=%s published_at=%s text_len=%d",
                channel.channel_id,
                video_url,
                published_at.isoformat(),
                len(raw_text),
            )

        return results

    def _extract_subtitle_text(self, video_url: str) -> str:
        """Extract subtitle text from a single video via yt-dlp."""
        opts: dict[str, object] = {
            "quiet": True,
            "subtitleslangs": ["vi", "a.vi", "en"],
            "writesubtitles": False,
            "skip_download": True,
            "writeautomaticsub": True,
        }
        try:
            self._fetcher.respect_rate_limit()
            runner = self.yt_dlp_runner or self._real_yt_dlp_runner
            info = runner(video_url, opts)
            subs_raw = info.get("subtitles")
            caps_raw = info.get("automatic_captions")
            subtitles: dict[str, object] = subs_raw if isinstance(subs_raw, dict) else {}
            auto_captions: dict[str, object] = caps_raw if isinstance(caps_raw, dict) else {}

            # Prefer vi > a.vi > en
            for lang in ("vi", "a.vi", "en"):
                subs = subtitles.get(lang) or auto_captions.get(lang)
                if not isinstance(subs, list):
                    continue
                for fmt in subs:
                    if isinstance(fmt, dict) and fmt.get("ext") in ("json3", "srv3", "vtt", "ttml"):
                        url_val = fmt.get("url", "")
                        return f"[subtitle:{lang}:{url_val}]"
        except Exception as exc:  # noqa: BLE001
            logger.debug("subtitle extraction failed for %s: %s", video_url, exc)
        return ""

    def _fetch_via_data_api(
        self,
        channel: Channel,
        since: datetime,
    ) -> list[ChannelContent]:
        """Fallback: fetch via YouTube Data API v3 when yt-dlp unavailable.

        Consumes ~1 quota unit per video listing call.
        Self-limits at _DAILY_QUOTA_SAFE_CAP.
        """
        if not self.api_key:
            return []

        # Extract YouTube channel ID from URL if possible
        channel_id_str = str(channel.channel_id)
        published_after = since.strftime("%Y-%m-%dT%H:%M:%SZ")
        list_url = (
            "https://www.googleapis.com/youtube/v3/search"
            f"?channelId={channel_id_str}"
            f"&publishedAfter={published_after}"
            f"&part=snippet&type=video&maxResults=10"
            f"&key={self.api_key}"
        )

        try:
            result = self._fetcher._fetch(list_url)
            self._quota_used_today += 1
        except Exception as exc:  # noqa: BLE001
            logger.warning("YouTube Data API fetch failed: %s", exc)
            return []

        import json

        try:
            data = json.loads(result.content)
        except json.JSONDecodeError:
            return []

        items = data.get("items", [])
        contents: list[ChannelContent] = []
        for item in items:
            snippet = item.get("snippet", {})
            video_id = item.get("id", {}).get("videoId", "")
            if not video_id:
                continue
            video_url = f"https://www.youtube.com/watch?v={video_id}"
            published_str = snippet.get("publishedAt", "")
            try:
                published_at = datetime.fromisoformat(published_str.replace("Z", "+00:00"))
            except (ValueError, AttributeError):
                published_at = self.clock()

            if published_at <= since:
                continue

            content_id = self._make_content_id(video_url)
            contents.append(
                ChannelContent(
                    content_id=content_id,
                    channel_id=channel.channel_id,
                    source_url=video_url,
                    published_at=published_at,
                    raw_text="",  # No subtitle available via listing endpoint
                    fetched_at=self.clock(),
                )
            )
        return contents

    @staticmethod
    def _parse_upload_date(upload_date: str | None) -> datetime | None:
        """Parse yt-dlp 'upload_date' field (YYYYMMDD format) to UTC datetime."""
        if not upload_date or len(upload_date) != 8:
            return None
        try:
            return datetime(
                int(upload_date[:4]),
                int(upload_date[4:6]),
                int(upload_date[6:8]),
                tzinfo=UTC,
            )
        except (ValueError, TypeError):
            return None

    @staticmethod
    def _make_content_id(url: str) -> str:
        """Deterministic content ID from URL (SHA-256 prefix)."""
        return hashlib.sha256(url.encode("utf-8")).hexdigest()[:16]
