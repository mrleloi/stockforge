"""Tests for BC-6 Influence Network value objects.

Covers: KolId, ChannelId, RecommendationId, KolStyle, KolStatus, Intent, Timeframe.
≥8 tests per plan § S46 Deliverable 11.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1.
"""

from __future__ import annotations

import pytest

from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.kol_status import KolStatus
from packages.domain.influence.value_objects.kol_style import KolStyle
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.timeframe import Timeframe

# --- KolId ---


def test_kol_id_valid() -> None:
    kol = KolId("abc-123")
    assert kol.value == "abc-123"
    assert str(kol) == "abc-123"


def test_kol_id_frozen() -> None:
    kol = KolId("abc-123")
    with pytest.raises(AttributeError):
        kol.value = "other"  # type: ignore[misc]


def test_kol_id_empty_raises() -> None:
    with pytest.raises(ValueError, match="non-empty"):
        KolId("")


def test_kol_id_whitespace_raises() -> None:
    with pytest.raises(ValueError, match="non-empty"):
        KolId("   ")


# --- ChannelId ---


def test_channel_id_valid() -> None:
    chan = ChannelId("UCtest123")
    assert chan.value == "UCtest123"
    assert str(chan) == "UCtest123"


def test_channel_id_empty_raises() -> None:
    with pytest.raises(ValueError, match="non-empty"):
        ChannelId("")


# --- RecommendationId ---


def test_recommendation_id_valid() -> None:
    rec_id = RecommendationId("rec-uuid-001")
    assert rec_id.value == "rec-uuid-001"
    assert str(rec_id) == "rec-uuid-001"


def test_recommendation_id_empty_raises() -> None:
    with pytest.raises(ValueError, match="non-empty"):
        RecommendationId("")


# --- KolStyle StrEnum ---


def test_kol_style_members() -> None:
    expected = {"fundamental", "technical", "narrative", "pumper", "mixed", "unknown"}
    actual = {s.value for s in KolStyle}
    assert actual == expected


def test_kol_style_is_str() -> None:
    assert KolStyle.FUNDAMENTAL.value == "fundamental"
    assert isinstance(KolStyle.TECHNICAL, str)


# --- KolStatus StrEnum ---


def test_kol_status_members() -> None:
    expected = {"provisional", "active", "paused", "retired", "blacklisted"}
    actual = {s.value for s in KolStatus}
    assert actual == expected


def test_kol_status_is_str() -> None:
    assert KolStatus.PROVISIONAL.value == "provisional"
    assert isinstance(KolStatus.ACTIVE, str)


# --- Intent StrEnum ---


def test_intent_members_count() -> None:
    # 6 values per spec § B.1
    assert len(list(Intent)) == 6


def test_intent_buy_sell_values() -> None:
    assert Intent.STRONG_BUY.value == "strong_buy"
    assert Intent.STRONG_AVOID.value == "strong_avoid"
    assert Intent.WATCH.value == "watch"
    assert Intent.NEUTRAL.value == "neutral"


# --- Timeframe StrEnum ---


def test_timeframe_members() -> None:
    expected = {"intraday", "days", "weeks", "months", "long_term"}
    actual = {t.value for t in Timeframe}
    assert actual == expected


def test_timeframe_is_str() -> None:
    assert Timeframe.DAYS.value == "days"
    assert isinstance(Timeframe.MONTHS, str)


# --- Value object equality and hash ---


def test_kol_id_equality() -> None:
    a = KolId("same-id")
    b = KolId("same-id")
    c = KolId("other-id")
    assert a == b
    assert a != c
    assert hash(a) == hash(b)


def test_channel_id_in_set() -> None:
    ids = {ChannelId("chan-1"), ChannelId("chan-2"), ChannelId("chan-1")}
    assert len(ids) == 2
