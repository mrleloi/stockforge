"""Crawl foundation primitives for BC-5 News Stream adapters.

Modules:
- rate_limiter: Per-domain rate limiting with exponential backoff + jitter.
- robots_manager: robots.txt cache + can_fetch check.
- selector_chain: Fallback-chain helper per crawler-reliability skill.
- raw_html_sink: Atomic raw-HTML preservation (D-062 + D-064 binding).

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md § Sub-track D2
"""

from .rate_limiter import DomainState, RateLimiter
from .raw_html_sink import RawHtmlSink
from .robots_manager import RobotsTxtManager
from .selector_chain import SelectorChain

__all__ = [
    "DomainState",
    "RateLimiter",
    "RawHtmlSink",
    "RobotsTxtManager",
    "SelectorChain",
]
