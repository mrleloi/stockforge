"""Tests for RateLimitedFetcher — shared base for BC-6 KOL adapters.

Covers: backoff schedule, ToS pre-flight rejects private, user-agent rotation,
httpx mocked via unittest.mock (respx not available in all envs; use mock instead).
≥6 tests per plan § S46 Deliverable 13.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.4.
Skill: .claude/skills/crawler-reliability/SKILL.md.
"""

from __future__ import annotations

import time
from datetime import UTC, datetime
from unittest.mock import MagicMock, patch

import pytest

from packages.application.influence.ports.kol_channel_adapter_port import (
    ToSBoundaryViolation,
)
from packages.infrastructure.influence.rate_limited_fetcher import (
    FetchResult,
    RateLimitedFetcher,
)

# --- Fixtures ---


def make_fetcher(rate_limit_seconds: float = 0.0) -> tuple[RateLimitedFetcher, list[float]]:
    """Create a fetcher with injectable sleeper and sub-second rate limit."""
    sleep_calls: list[float] = []
    fetcher = RateLimitedFetcher(
        platform="test",
        rate_limit_seconds=rate_limit_seconds,
        sleeper=lambda s: sleep_calls.append(s),
        clock=lambda: datetime.now(UTC),
    )
    return fetcher, sleep_calls


# --- Rate limiting tests ---


def test_rate_limit_enforced_on_rapid_successive_calls() -> None:
    """Sleeper is called when requests arrive within rate limit window."""
    sleep_calls: list[float] = []
    fetcher = RateLimitedFetcher(
        platform="test",
        rate_limit_seconds=1.0,
        sleeper=lambda s: sleep_calls.append(s),
        clock=lambda: datetime.now(UTC),
    )
    # Simulate that last fetch was just now
    fetcher._last_fetch_at = time.monotonic()

    fetcher._enforce_rate_limit()
    # Should have slept something < 1.0 seconds
    assert len(sleep_calls) == 1
    assert 0 < sleep_calls[0] <= 1.0


def test_rate_limit_not_triggered_after_sufficient_wait() -> None:
    """Sleeper NOT called when rate limit window has already elapsed."""
    sleep_calls: list[float] = []
    fetcher = RateLimitedFetcher(
        platform="test",
        rate_limit_seconds=0.1,
        sleeper=lambda s: sleep_calls.append(s),
        clock=lambda: datetime.now(UTC),
    )
    # Last fetch was 1 second ago
    fetcher._last_fetch_at = time.monotonic() - 1.0

    fetcher._enforce_rate_limit()
    assert len(sleep_calls) == 0


# --- User agent rotation tests ---


def test_user_agent_rotation_cycles() -> None:
    """UA rotation returns different agents across calls."""
    fetcher, _ = make_fetcher()
    ua_1 = fetcher._current_user_agent()
    ua_2 = fetcher._current_user_agent()
    ua_3 = fetcher._current_user_agent()
    ua_4 = fetcher._current_user_agent()
    # After 3 unique UAs, should cycle back
    assert ua_1 != ua_2 or ua_1 != ua_3  # at least some rotation
    assert ua_4 == ua_1  # cycles (3-UA pool)


def test_user_agent_contains_stockforge_identity() -> None:
    """UAs identify our bot with contact info (responsible crawling)."""
    fetcher, _ = make_fetcher()
    ua = fetcher._current_user_agent()
    assert "stockforge-research-bot" in ua


# --- ToS pre-flight (401/403 → ToSBoundaryViolation) ---


def test_tos_violation_on_401() -> None:
    """401 response raises ToSBoundaryViolation (private content gate BR-1)."""
    fetcher, _ = make_fetcher(rate_limit_seconds=0.0)

    mock_response = MagicMock()
    mock_response.status_code = 401
    mock_response.text = "Unauthorized"

    with patch("httpx.Client") as mock_client_cls:
        mock_client = MagicMock()
        mock_client.__enter__ = MagicMock(return_value=mock_client)
        mock_client.__exit__ = MagicMock(return_value=False)
        mock_client.get.return_value = mock_response
        mock_client_cls.return_value = mock_client

        with pytest.raises(ToSBoundaryViolation, match="401"):
            fetcher._fetch("https://private.example.com/secret")


def test_tos_violation_on_403() -> None:
    """403 response raises ToSBoundaryViolation (auth-required content BR-1)."""
    fetcher, _ = make_fetcher(rate_limit_seconds=0.0)

    mock_response = MagicMock()
    mock_response.status_code = 403
    mock_response.text = "Forbidden"

    with patch("httpx.Client") as mock_client_cls:
        mock_client = MagicMock()
        mock_client.__enter__ = MagicMock(return_value=mock_client)
        mock_client.__exit__ = MagicMock(return_value=False)
        mock_client.get.return_value = mock_response
        mock_client_cls.return_value = mock_client

        with pytest.raises(ToSBoundaryViolation, match="403"):
            fetcher._fetch("https://fb.com/private-group/posts")


# --- Successful fetch test ---


def test_successful_fetch_returns_fetch_result() -> None:
    """200 response returns FetchResult with content and latency."""
    fetcher, _ = make_fetcher(rate_limit_seconds=0.0)

    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.text = '{"data": []}'

    with patch("httpx.Client") as mock_client_cls:
        mock_client = MagicMock()
        mock_client.__enter__ = MagicMock(return_value=mock_client)
        mock_client.__exit__ = MagicMock(return_value=False)
        mock_client.get.return_value = mock_response
        mock_client_cls.return_value = mock_client

        result = fetcher._fetch("https://api.example.com/data")

    assert isinstance(result, FetchResult)
    assert result.status_code == 200
    assert result.content == '{"data": []}'
    assert result.latency_ms >= 0


# --- robots.txt check ---


def test_robots_txt_check_defaults_allow_on_error() -> None:
    """robots.txt check defaults to ALLOW when network fails (fail-open)."""
    fetcher, _ = make_fetcher()
    # No real network; urllib.robotparser will fail to read
    result = fetcher.check_robots_txt("https://nonexistent-domain-xyz.invalid")
    assert result is True  # fail-open per SKILL.md


def test_phase4_ip_rotation_stub_returns_none() -> None:
    """IP rotation hook returns None in Phase 3 (stub documented per R-P3-2)."""
    fetcher, _ = make_fetcher()
    proxies = fetcher._get_proxies()
    assert proxies is None  # Phase 4 placeholder
