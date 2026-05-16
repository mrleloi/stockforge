# Portions adapted from Scrapling (https://github.com/D4Vinci/Scrapling),
# BSD-3-Clause by Karim Shoair; see NOTICE at repo root for full text.
# Source: scrapling/spiders/robotstxt.py:10-60 (RobotsTxtManager)
"""Per-domain robots.txt cache + can_fetch check (synchronous).

Sync port of Scrapling's async RobotsTxtManager (scrapling/spiders/robotstxt.py:10-60).
The source is async (anyio + async fetch_fn); this port is sync because the BC-5
pipeline is sync (plan 020 DD-2 — async deferred to Phase 3).

Key adaptations from upstream:
- ``fetch_fn`` is ``Callable[[str], str | None]`` (sync, returns robots.txt body or None).
  The upstream uses an async session-based fetch_fn with a ``sid`` parameter.
- Cache is an in-memory dict ``{domain: Protego}``. Per A-12 § 3 C5 caveat:
  swap to SQLite for long-running daemons (Phase 3+).
- ``can_fetch`` and ``get_crawl_delay`` are sync methods.
- Uses ``protego`` library for robots.txt parsing (same as upstream).

D-059 compliance:
- R1 (datetime-no-tz): no datetime usage in this module.
- R2 (unseeded RNG): no RNG usage in this module.
- R4 (time.time-in-domain): no time.time in domain layer.

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md § Sub-track D2
        scrapling/spiders/robotstxt.py:10-60 (RobotsTxtManager)
        .claude/skills/crawler-reliability/SKILL.md § Rate Limiting
"""

from __future__ import annotations

import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from urllib.parse import urlparse

__all__ = ["RobotsTxtManager"]

_log = logging.getLogger(__name__)


def _load_protego() -> type:  # type: ignore[type-arg]
    """Lazy-import protego; raises ImportError with install hint if absent."""
    try:
        from protego import Protego  # type: ignore[import-untyped]
        return Protego  # type: ignore[return-value]
    except ImportError as exc:
        raise ImportError(
            "RobotsTxtManager requires the 'protego' package. "
            "Install it with: pip install protego"
        ) from exc


@dataclass
class RobotsTxtManager:
    """Per-domain robots.txt cache + can_fetch check (synchronous).

    Adapted from Scrapling's async RobotsTxtManager (scrapling/spiders/robotstxt.py:10-60).
    Sync is intentional — see plan 020 DD-2 (async deferred to Phase 3).

    Usage::

        def fetcher(url: str) -> str | None:
            try:
                return httpx.get(url, timeout=10.0).text
            except Exception:
                return None

        robots = RobotsTxtManager(fetcher=fetcher)
        if robots.can_fetch("https://cafef.vn/article.chn"):
            html = fetcher("https://cafef.vn/article.chn")

    Cache is in-memory (rebuilt on process start). Phase 3 may add SQLite for
    long-running daemons per A-12 § 3 C5 caveat.
    """

    fetcher: Callable[[str], str | None]
    """Returns robots.txt body (str) or None on 404/network-error."""

    user_agent: str = "stockforge-research-bot/0.0.1"
    """User-agent string used for robots.txt can_fetch checks."""

    _cache: dict[str, object] = field(default_factory=dict, repr=False)
    """In-memory cache of {domain: Protego} parsers."""

    def _get_parser(self, url: str) -> object:
        """Fetch (or return cached) robots.txt Protego parser for the URL's domain."""
        Protego = _load_protego()
        parsed = urlparse(url)
        domain = parsed.netloc
        if not domain:
            _log.warning("robots_manager: could not extract domain from url=%r", url)
            return Protego.parse("")  # type: ignore[return-value]

        if domain in self._cache:
            return self._cache[domain]

        scheme = parsed.scheme or "https"
        robots_url = f"{scheme}://{domain}/robots.txt"
        content = ""
        try:
            result = self.fetcher(robots_url)
            if result is not None:
                content = result
        except Exception as exc:
            _log.warning(
                "robots_manager: failed to fetch robots.txt for %s: %s", domain, exc
            )

        try:
            parser = Protego.parse(content)  # type: ignore[attr-defined]
        except Exception as exc:
            _log.warning(
                "robots_manager: failed to parse robots.txt for %s: %s", domain, exc
            )
            parser = Protego.parse("")  # type: ignore[attr-defined]

        self._cache[domain] = parser
        return parser

    def can_fetch(self, url: str) -> bool:
        """Check if url can be fetched per the domain's robots.txt.

        Returns True when robots.txt is absent (404 → permissive), because the
        standard interpretation of "no robots.txt" is "allow all" (per Scrapling
        upstream comment + RFC tradition).

        Args:
            url: Full URL to check.

        Returns:
            True if the user_agent is allowed to fetch url; False if disallowed.

        Adapted from scrapling/spiders/robotstxt.py:43-50 (can_fetch).
        """
        parser = self._get_parser(url)
        result: bool = parser.can_fetch(url, self.user_agent)  # type: ignore[attr-defined]
        return result

    def get_crawl_delay(self, url: str) -> float | None:
        """Return the Crawl-delay directive for user_agent, or None if not specified.

        Args:
            url: Any URL on the domain to check.

        Returns:
            Crawl-delay in seconds (float) or None if not specified in robots.txt.

        Adapted from scrapling/spiders/robotstxt.py:52-64 (get_delay_directives).
        """
        parser = self._get_parser(url)
        delay = parser.crawl_delay(self.user_agent)  # type: ignore[attr-defined]
        return float(delay) if delay is not None else None
