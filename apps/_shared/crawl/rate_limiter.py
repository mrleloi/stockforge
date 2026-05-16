# Portions adapted from Crawl4AI (https://github.com/unclecode/crawl4ai),
# Apache-2.0 + Attribution Requirement; see NOTICE at repo root for full text.
# Source: crawl4ai/async_dispatcher.py:28-85 (RateLimiter + DomainState)
"""Per-domain rate limiter with exponential backoff + jitter.

Sync port of crawl4ai async_dispatcher.RateLimiter (async_dispatcher.py:28-85).
Sync is intentional — see plan 020 DD-2 (async deferred to Phase 3): the existing
CafeFScraper is sync and the entire BC-5 pipeline downstream is sync.

D-059 compliance:
- R1 (datetime-no-tz): uses time.monotonic() not datetime.now().
- R2 (unseeded RNG): ``rng`` field defaults to ``Random(0)`` (seeded); tests pass
  a predictable seed; production passes Random(0) for deterministic defaults.
- R4 (time.time-in-domain): N/A — this is infrastructure, not domain.

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md § Sub-track D2
        crawl4ai/async_dispatcher.py:28-85 (RateLimiter)
        .claude/skills/crawler-reliability/SKILL.md § Rate Limiting
"""

from __future__ import annotations

import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from random import Random
from time import monotonic, sleep
from urllib.parse import urlparse

__all__ = ["DomainState", "RateLimiter"]

_log = logging.getLogger(__name__)


@dataclass
class DomainState:
    """Mutable per-domain rate-limit state.

    Adapted from crawl4ai async_dispatcher.py:28-40 (DomainState in models.py).
    Fields:
    - base_delay: minimum gap between requests to this domain (seconds).
    - current_delay: current enforced gap (doubles on 429/503, decays on success).
    - max_delay: ceiling for current_delay after exponential growth.
    - retries_so_far: consecutive 429/503 count; resets on success.
    - last_fetched_at: monotonic timestamp of the last request start.

    Note: current_delay is an internal timing float — NOT an LLM-emitted numeric field.
    Rule 16 scope per plan 020 § Schema discipline: internal infra state is out-of-scope.
    """

    base_delay: float
    current_delay: float
    max_delay: float
    retries_so_far: int = 0
    last_fetched_at: float = 0.0  # monotonic seconds; 0.0 = never fetched


@dataclass
class RateLimiter:
    """Per-domain rate limiter with exponential backoff + jitter.

    Sync port of crawl4ai async_dispatcher.RateLimiter (async_dispatcher.py:28-85).
    Sync is intentional — see plan 020 DD-2 (async deferred to Phase 3).

    Usage::

        limiter = RateLimiter(base_delay=2.0, max_delay=60.0, max_retries=5)
        limiter.wait_if_needed("cafef.vn")   # sleeps if needed
        response = fetcher(url)
        ok = limiter.report_response("cafef.vn", response.status_code)
        if not ok:
            raise RuntimeError("Circuit open — too many retries")

    ``rng`` is seedable for D-059 R2 compliance (deterministic tests).
    Default ``Random(0)`` provides deterministic jitter in production
    (consistent delay profile without true randomness).
    """

    base_delay: float = 2.0
    max_delay: float = 60.0
    max_retries: int = 5
    states: dict[str, DomainState] = field(default_factory=dict)
    rng: Random = field(default_factory=lambda: Random(0))  # seeded; D-059 R2
    _sleeper: Callable[[float], None] = field(default=sleep, repr=False)  # injectable for tests

    def _get_domain(self, domain_or_url: str) -> str:
        """Extract netloc if a full URL is passed; otherwise use as-is."""
        if domain_or_url.startswith("http://") or domain_or_url.startswith("https://"):
            return urlparse(domain_or_url).netloc
        return domain_or_url

    def _ensure_state(self, domain: str) -> DomainState:
        if domain not in self.states:
            self.states[domain] = DomainState(
                base_delay=self.base_delay,
                current_delay=self.base_delay,
                max_delay=self.max_delay,
            )
        return self.states[domain]

    def wait_if_needed(self, domain: str) -> None:
        """Sleep enough to honor base_delay since last fetch on this domain.

        If the domain has never been fetched, no sleep is needed.

        Args:
            domain: The domain key (e.g. ``"cafef.vn"``) or a full URL.

        Side effects:
            Updates ``state.last_fetched_at`` to ``monotonic()`` after sleeping.
        """
        domain = self._get_domain(domain)
        state = self._ensure_state(domain)
        elapsed = monotonic() - state.last_fetched_at
        wait_needed = state.current_delay - elapsed
        if wait_needed > 0:
            _log.debug("rate_limiter: domain=%s sleeping=%.2fs", domain, wait_needed)
            sleeper = self._sleeper
            if callable(sleeper):
                sleeper(wait_needed)
        state.last_fetched_at = monotonic()

    def report_response(self, domain: str, status_code: int) -> bool:
        """Update delay state based on response status code.

        On 429 or 503: exponential backoff with jitter (doubles current_delay ×
        random factor in [0.75, 1.25], capped at max_delay). Increments retries_so_far.
        On success (any other code): decay current_delay 25% toward base_delay.

        Args:
            domain: The domain key or full URL.
            status_code: HTTP status code of the response.

        Returns:
            True — continue fetching.
            False — circuit-open: max_retries exceeded; caller should stop fetching
                    this domain.

        Adapted from crawl4ai async_dispatcher.py:65-85 (RateLimiter.update_delay).
        """
        domain = self._get_domain(domain)
        state = self._ensure_state(domain)

        if status_code in (429, 503):
            state.retries_so_far += 1
            if state.retries_so_far > self.max_retries:
                _log.warning(
                    "rate_limiter: circuit-open domain=%s retries=%d > max=%d",
                    domain, state.retries_so_far, self.max_retries,
                )
                return False
            jitter = self.rng.uniform(0.75, 1.25)
            state.current_delay = min(
                state.current_delay * 2 * jitter,
                state.max_delay,
            )
            _log.debug(
                "rate_limiter: 429/503 domain=%s new_delay=%.2fs",
                domain, state.current_delay,
            )
        else:
            # Gradual decay toward base_delay on success (×0.75 per crawl4ai recipe)
            state.current_delay = max(
                state.base_delay,
                state.current_delay * 0.75,
            )
            state.retries_so_far = 0

        return True
