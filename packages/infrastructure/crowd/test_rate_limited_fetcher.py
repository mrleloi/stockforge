"""Tests for crowd RateLimitedFetcher (imports from influence + crowd wrapper).

BC-7 crowd aggregators reuse BC-6 RateLimitedFetcher via CrowdRateLimitedFetcher.
These tests verify the crowd-specific wrapper and the base class behavior
relevant to crowd use case.

Markers: unit
"""

from __future__ import annotations

import httpx
import pytest
import respx

from packages.application.influence.ports.kol_channel_adapter_port import (
    ToSBoundaryViolation,  # Base class exception from BC-6 RateLimitedFetcher
)
from packages.infrastructure.crowd.rate_limited_fetcher import CrowdRateLimitedFetcher


@pytest.mark.unit
class TestCrowdRateLimitedFetcherInit:
    def test_platform_set(self) -> None:
        fetcher = CrowdRateLimitedFetcher(platform="f319")
        assert fetcher.platform == "f319"

    def test_rate_limit_default(self) -> None:
        fetcher = CrowdRateLimitedFetcher(platform="f319")
        assert fetcher.rate_limit_seconds == 1.0

    def test_custom_rate_limit(self) -> None:
        fetcher = CrowdRateLimitedFetcher(platform="fb_group", rate_limit_seconds=0.5)
        assert fetcher.rate_limit_seconds == 0.5


@pytest.mark.unit
class TestRateLimitEnforcement:
    def test_respect_rate_limit_calls_sleeper_when_too_fast(self) -> None:
        sleeps: list[float] = []
        fetcher = CrowdRateLimitedFetcher(
            platform="test",
            rate_limit_seconds=1.0,
            sleeper=sleeps.append,
        )
        # Simulate a recent fetch (set _last_fetch_at to just now)
        import time
        fetcher._last_fetch_at = time.monotonic()  # just fetched
        fetcher._enforce_rate_limit()
        # Should have slept (close to 1.0s)
        assert len(sleeps) == 1
        assert sleeps[0] > 0.0


@pytest.mark.unit
class TestUserAgentRotation:
    def test_ua_cycles_on_successive_calls(self) -> None:
        fetcher = CrowdRateLimitedFetcher(platform="test")
        ua1 = fetcher._current_user_agent()
        fetcher._current_user_agent()  # ua2
        fetcher._current_user_agent()  # ua3
        # After 3 rotations should cycle back
        ua4 = fetcher._current_user_agent()
        assert ua1 == ua4  # cycle length = 3 UAs in pool


@pytest.mark.unit
class TestTosBoundaryViolation:
    @respx.mock
    def test_401_response_raises_tos_violation(self) -> None:
        fetcher = CrowdRateLimitedFetcher(
            platform="test",
            rate_limit_seconds=0.0,
            sleeper=lambda _: None,
        )
        respx.get("https://example.com/private").mock(
            return_value=httpx.Response(401)
        )
        with pytest.raises(ToSBoundaryViolation):
            fetcher._fetch("https://example.com/private")

    @respx.mock
    def test_403_response_raises_tos_violation(self) -> None:
        fetcher = CrowdRateLimitedFetcher(
            platform="test",
            rate_limit_seconds=0.0,
            sleeper=lambda _: None,
        )
        respx.get("https://example.com/restricted").mock(
            return_value=httpx.Response(403)
        )
        with pytest.raises(ToSBoundaryViolation):
            fetcher._fetch("https://example.com/restricted")


@pytest.mark.unit
class TestRobotsPreFlight:
    def test_robots_txt_fail_open_on_network_error(self) -> None:
        """BR-1 fail-open: if robots.txt unavailable, default to ALLOW."""
        fetcher = CrowdRateLimitedFetcher(platform="test")
        # Unavailable domain — should default to True (fail-open)
        result = fetcher.check_robots_txt("https://nonexistent.invalid", "/")
        assert result is True
