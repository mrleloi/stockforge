"""RateLimitedFetcher — BC-7 crowd adapter base class.

IMPL-S66-2 decision: import-from-influence rather than duplicate.
The BC-6 RateLimitedFetcher shape is compatible with BC-7 PostAggregator base needs.
Attribution per D-032 § (b) reuse-or-duplicate clause:

    Duplicated concept from packages/infrastructure/influence/rate_limited_fetcher.py
    (BC-6 S46; verified at S64 sandwich-verifier close).
    Sync maintained via vendor-api-probe.sh weekly check.

This module re-exports the BC-6 class with crowd-specific USER_AGENTS override
and crowd-context documentation. Actual implementation lives in influence/.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4.
ADR: D-032 § (b) adapter pattern — reuse-or-duplicate decision.
"""

from __future__ import annotations

from packages.infrastructure.influence.rate_limited_fetcher import (
    FetchResult,
    RateLimitedFetcher,
)

__all__ = ["CrowdRateLimitedFetcher", "FetchResult", "RateLimitedFetcher"]

# Crowd-specific user-agent pool (distinct from BC-6 KOL pool per platform clarity)
CROWD_USER_AGENTS: tuple[str, ...] = (
    "stockforge-crowd-research/0.1 (+contact: nathanleewindy@gmail.com) (platform: f319)",
    "stockforge-crowd-research/0.1 (+contact: nathanleewindy@gmail.com) (platform: fb_group)",
    "stockforge-crowd-research/0.1 (+contact: nathanleewindy@gmail.com) (platform: comments)",
)


class CrowdRateLimitedFetcher(RateLimitedFetcher):
    """RateLimitedFetcher subclass for BC-7 crowd aggregators.

    Inherits all rate-limiting, robots.txt pre-flight, UA rotation, and
    exponential backoff from BC-6 base class. Overrides nothing — subclass
    provided for semantic distinction and crowd-specific documentation.

    IP rotation hook (Phase 4 stub): override _get_proxies() in Phase 4.
    Per R-P3-2 mitigation: documented here; NOT implemented Phase 3.
    """
