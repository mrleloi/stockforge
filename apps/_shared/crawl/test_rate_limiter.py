"""Tests for RateLimiter (plan 020 DC-D2-3).

Covers (≥6 per spec):
1. Base case: wait after base_delay elapses.
2. Exponential backoff on 429.
3. Decay on success.
4. Circuit-open after max_retries.
5. Seeded jitter is deterministic.
6. Per-domain isolation.
"""

from __future__ import annotations

from random import Random

from apps._shared.crawl.rate_limiter import RateLimiter


def _no_sleep(seconds: float) -> None:
    """Test sleeper — records calls without actually sleeping."""
    pass


def _make_limiter(
    base_delay: float = 2.0,
    max_delay: float = 60.0,
    max_retries: int = 3,
    seed: int = 42,
) -> tuple[RateLimiter, list[float]]:
    """Return a RateLimiter with an injectable sleeper that records sleep calls."""
    slept: list[float] = []

    def record_sleep(s: float) -> None:
        slept.append(s)

    limiter = RateLimiter(
        base_delay=base_delay,
        max_delay=max_delay,
        max_retries=max_retries,
        rng=Random(seed),
        _sleeper=record_sleep,
    )
    return limiter, slept


def test_rate_limiter_no_sleep_on_first_call() -> None:
    """First call to a new domain should not sleep (never fetched before)."""
    limiter, slept = _make_limiter()
    limiter.wait_if_needed("cafef.vn")
    # last_fetched_at was 0.0, monotonic() is high → elapsed >> base_delay → no sleep
    assert len(slept) == 0


def test_rate_limiter_sleeps_within_base_delay() -> None:
    """After a simulated recent fetch, wait_if_needed should sleep."""
    limiter, slept = _make_limiter(base_delay=2.0)
    # Simulate a fetch that happened "just now" by setting last_fetched_at high
    import time
    domain = "cafef.vn"
    state = limiter._ensure_state(domain)
    state.last_fetched_at = time.monotonic()  # just now
    limiter.wait_if_needed(domain)
    # Should sleep approximately base_delay seconds
    assert len(slept) == 1
    assert slept[0] > 1.5  # at least most of base_delay (2.0)
    assert slept[0] <= 2.0 + 0.1  # not more than base_delay + tiny float drift


def test_rate_limiter_exponential_backoff_on_429() -> None:
    """Reporting 429 should double the current_delay (with jitter)."""
    limiter, _ = _make_limiter(base_delay=2.0, max_delay=60.0)
    domain = "cafef.vn"
    initial_delay = limiter._ensure_state(domain).current_delay
    ok = limiter.report_response(domain, 429)
    new_delay = limiter._ensure_state(domain).current_delay
    assert ok is True
    assert new_delay > initial_delay  # backoff increases delay


def test_rate_limiter_decay_on_success() -> None:
    """Reporting 200 after a 429 should decay current_delay toward base_delay."""
    limiter, _ = _make_limiter(base_delay=2.0, max_delay=60.0)
    domain = "cafef.vn"
    # Force a high delay
    limiter._ensure_state(domain).current_delay = 20.0
    ok = limiter.report_response(domain, 200)
    new_delay = limiter._ensure_state(domain).current_delay
    assert ok is True
    assert new_delay < 20.0  # decay happened
    assert new_delay >= 2.0  # never below base_delay


def test_rate_limiter_circuit_open_after_max_retries() -> None:
    """After max_retries+1 consecutive 429s, report_response returns False."""
    limiter, _ = _make_limiter(max_retries=3)
    domain = "cafef.vn"
    for _ in range(3):
        result = limiter.report_response(domain, 429)
        assert result is True
    # 4th 429 exceeds max_retries=3 → circuit open
    result = limiter.report_response(domain, 429)
    assert result is False


def test_rate_limiter_seeded_jitter_is_deterministic() -> None:
    """With same seed, exponential backoff produces same jitter sequence."""
    limiter1, _ = _make_limiter(seed=99)
    limiter2, _ = _make_limiter(seed=99)
    domain = "test.vn"
    limiter1.report_response(domain, 429)
    limiter2.report_response(domain, 429)
    d1 = limiter1._ensure_state(domain).current_delay
    d2 = limiter2._ensure_state(domain).current_delay
    assert d1 == d2  # deterministic with same seed


def test_rate_limiter_per_domain_isolation() -> None:
    """Each domain has independent state; 429 on one does not affect another."""
    limiter, _ = _make_limiter(base_delay=2.0)
    limiter.report_response("cafef.vn", 429)
    limiter.report_response("ndh.vn", 200)
    cafef_delay = limiter._ensure_state("cafef.vn").current_delay
    ndh_delay = limiter._ensure_state("ndh.vn").current_delay
    assert cafef_delay > 2.0  # increased after 429
    assert ndh_delay == 2.0  # untouched (decayed but hits base_delay floor)


def test_rate_limiter_accepts_full_url_as_domain() -> None:
    """wait_if_needed and report_response accept full URLs, extracting netloc."""
    limiter, _ = _make_limiter()
    limiter.report_response("https://cafef.vn/article.chn", 429)
    state = limiter.states.get("cafef.vn")
    assert state is not None
    assert state.retries_so_far == 1
