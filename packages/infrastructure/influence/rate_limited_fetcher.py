"""RateLimitedFetcher — shared base class for all BC-6 KOL channel adapters.

Implements:
- Per-platform rate limiting with token-bucket semantics (time.sleep based).
- 3-UA pool rotation per crawler-reliability skill.
- robots.txt pre-flight check via urllib.robotparser (ToS gate BR-1).
- Exponential backoff via tenacity for transient HTTP failures.
- IP rotation hook: STUB only (Phase 4 proxy integration; not implemented).
- Per-fetch audit log: (platform, channel_id, status, latency_ms).

Adapters subclass this and call `_fetch(url)` to get rate-limited + retried HTML/JSON.

IMPORTANT: This class uses `httpx` (infrastructure layer only).
Domain layer has ZERO dependency on this class.

Source: .claude/skills/crawler-reliability/SKILL.md.
Source: specs/tier2-feature/002-influence-network-tracking.md § B.4 + § A.3 BR-1.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § b).
"""

from __future__ import annotations

import logging
import time
import urllib.robotparser
from dataclasses import dataclass, field
from datetime import UTC, datetime

import httpx
from tenacity import (
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from packages.application.influence.ports.kol_channel_adapter_port import (
    ToSBoundaryViolation,
)

__all__ = ["FetchResult", "RateLimitedFetcher"]

logger = logging.getLogger(__name__)

# 3-UA pool minimum per crawler-reliability/SKILL.md
_USER_AGENTS: tuple[str, ...] = (
    "stockforge-research-bot/0.1 (+contact: nathanleewindy@gmail.com) (platform: youtube)",
    "stockforge-research-bot/0.1 (+contact: nathanleewindy@gmail.com) (platform: telegram)",
    "stockforge-research-bot/0.1 (+contact: nathanleewindy@gmail.com) (platform: facebook)",
)

_DEFAULT_TIMEOUT_SECONDS = 30.0
_MAX_RETRY_ATTEMPTS = 5
_BACKOFF_MULTIPLIER = 1
_BACKOFF_MIN = 1
_BACKOFF_MAX = 30


@dataclass(frozen=True)
class FetchResult:
    """Result of a single fetch attempt."""

    url: str
    status_code: int
    content: str
    fetched_at: datetime
    latency_ms: float


@dataclass
class RateLimitedFetcher:
    """Shared base for all BC-6 KOL channel adapters.

    Args:
        platform:          Platform name for audit logging (e.g. "youtube").
        rate_limit_seconds: Minimum seconds between requests to same domain.
        user_agent_index:  Which UA from _USER_AGENTS pool to use (0-2).
        timeout_seconds:   Per-request timeout.
        clock:             Callable returning current datetime (injectable for tests).
        sleeper:           Callable accepting float seconds (injectable for tests).

    IP rotation hook (Phase 4 stub):
        Override `_get_proxies()` to return proxy dict per request.
        Currently returns None (direct connection).
        Phase 4: inject proxy pool from environment config.
    """

    platform: str
    rate_limit_seconds: float = 1.0
    user_agent_index: int = 0
    timeout_seconds: float = _DEFAULT_TIMEOUT_SECONDS
    clock: object = field(default_factory=lambda: lambda: datetime.now(UTC))
    sleeper: object = field(default_factory=lambda: time.sleep)
    _last_fetch_at: float = field(default=0.0, init=False, repr=False)
    _ua_cycle: int = field(default=0, init=False, repr=False)

    def _current_user_agent(self) -> str:
        """Rotate through UA pool per request."""
        ua = _USER_AGENTS[self._ua_cycle % len(_USER_AGENTS)]
        self._ua_cycle += 1
        return ua

    def _get_proxies(self) -> dict[str, str] | None:
        """IP rotation hook — Phase 4 proxy integration stub.

        Phase 3: returns None (direct connection).
        Phase 4: override to return proxy config from environment:
            {"http://": "http://proxy:port", "https://": "http://proxy:port"}
        This stub is intentionally documented here per R-P3-2 mitigation checklist.
        """
        return None  # Phase 4: replace with proxy pool

    def _enforce_rate_limit(self) -> None:
        """Block until per-platform rate limit window has elapsed."""
        elapsed = time.monotonic() - self._last_fetch_at
        if elapsed < self.rate_limit_seconds:
            sleep_secs = self.rate_limit_seconds - elapsed
            assert callable(self.sleeper)
            self.sleeper(sleep_secs)

    def check_robots_txt(self, base_url: str, path: str = "/") -> bool:
        """Check robots.txt before fetching. Returns True if fetch is allowed.

        Uses stdlib urllib.robotparser. On network error, defaults to ALLOW
        (fail-open: don't block ingestion on robots.txt unavailability, but log).
        """
        rp = urllib.robotparser.RobotFileParser()
        robots_url = f"{base_url.rstrip('/')}/robots.txt"
        try:
            rp.set_url(robots_url)
            rp.read()
            return rp.can_fetch(self._current_user_agent(), f"{base_url.rstrip('/')}{path}")
        except Exception as exc:  # noqa: BLE001
            logger.warning(
                "robots.txt check failed for %s: %s — defaulting to ALLOW", base_url, exc
            )
            return True

    def _fetch(self, url: str) -> FetchResult:
        """Rate-limited, retried HTTP GET. Core method used by all adapters.

        Raises:
            ToSBoundaryViolation: if response is a login redirect (status 401/403).
            RetryError: after exhausting backoff attempts on transient errors.
        """
        self._enforce_rate_limit()
        try:
            result = self._do_fetch_with_retry(url)
        finally:
            self._last_fetch_at = time.monotonic()
        return result

    def _do_fetch_with_retry(self, url: str) -> FetchResult:
        """Inner fetch with tenacity retry. Separated for testability."""

        @retry(
            stop=stop_after_attempt(_MAX_RETRY_ATTEMPTS),
            wait=wait_exponential(
                multiplier=_BACKOFF_MULTIPLIER,
                min=_BACKOFF_MIN,
                max=_BACKOFF_MAX,
            ),
            retry=retry_if_exception_type((httpx.HTTPError, httpx.TimeoutException)),
            reraise=True,
        )
        def _attempt() -> FetchResult:
            start = time.monotonic()
            proxies = self._get_proxies()
            transport = (
                httpx.HTTPTransport(proxy=proxies["https://"] if proxies else None)
                if proxies
                else None
            )
            with httpx.Client(
                timeout=self.timeout_seconds,
                follow_redirects=True,
                transport=transport,
            ) as client:
                response = client.get(
                    url,
                    headers={"User-Agent": self._current_user_agent()},
                )
            latency_ms = (time.monotonic() - start) * 1000
            assert callable(self.clock)
            now = self.clock()

            # ToS gate: 401/403 signals private/auth-required content (BR-1)
            if response.status_code in (401, 403):
                raise ToSBoundaryViolation(
                    f"URL {url!r} returned {response.status_code} — "
                    "content requires authentication; refusing per BR-1 public-only rule"
                )

            self._log_fetch(url, response.status_code, latency_ms)
            return FetchResult(
                url=url,
                status_code=response.status_code,
                content=response.text,
                fetched_at=now,
                latency_ms=latency_ms,
            )

        return _attempt()

    def _log_fetch(self, url: str, status_code: int, latency_ms: float) -> None:
        """Audit log per R-P3-2 mitigation: platform, url, status, latency_ms."""
        logger.info(
            "kol_fetch platform=%s url=%s status=%d latency_ms=%.1f",
            self.platform,
            url,
            status_code,
            latency_ms,
        )

    def respect_rate_limit(self) -> None:
        """Public hook for KOLChannelAdapter Protocol compliance."""
        self._enforce_rate_limit()
