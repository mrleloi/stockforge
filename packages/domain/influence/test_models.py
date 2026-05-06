"""Tests for BC-6 Influence Network domain models.

Covers: Kol (PROVISIONAL→ACTIVE transition), Channel (platform invariant),
ChannelContent (published_at not-future, source_url required).
≥10 tests per plan § S46 Deliverable 12.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § A.3 BR-2.
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest

from packages.domain.influence.models.channel import Channel, Platform
from packages.domain.influence.models.channel_content import ChannelContent
from packages.domain.influence.models.kol import InvariantViolation, Kol
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.kol_status import KolStatus
from packages.domain.influence.value_objects.kol_style import KolStyle

# --- Fixtures ---


def make_kol(
    status: KolStatus = KolStatus.PROVISIONAL,
    name: str = "Test KOL",
) -> Kol:
    return Kol(
        kol_id=KolId("kol-001"),
        name=name,
        primary_channel_id=ChannelId("chan-yt-001"),
        style=KolStyle.FUNDAMENTAL,
        status=status,
    )


def make_channel(
    platform: Platform = Platform.YOUTUBE,
    url: str = "https://www.youtube.com/@testkol",
) -> Channel:
    return Channel(
        channel_id=ChannelId("chan-001"),
        platform=platform,
        url=url,
        kol_id=KolId("kol-001"),
    )


# --- Kol aggregate tests ---


def test_kol_created_provisional() -> None:
    kol = make_kol(status=KolStatus.PROVISIONAL)
    assert kol.status == KolStatus.PROVISIONAL
    assert kol.is_provisional
    assert not kol.is_active


def test_kol_transition_to_active_at_threshold() -> None:
    kol = make_kol(status=KolStatus.PROVISIONAL)
    kol.transition_to_active(n_evaluated=10)
    assert kol.status == KolStatus.ACTIVE
    assert kol.is_active
    assert not kol.is_provisional


def test_kol_transition_to_active_above_threshold() -> None:
    kol = make_kol(status=KolStatus.PROVISIONAL)
    kol.transition_to_active(n_evaluated=15)
    assert kol.status == KolStatus.ACTIVE


def test_kol_transition_to_active_below_threshold_raises() -> None:
    kol = make_kol(status=KolStatus.PROVISIONAL)
    with pytest.raises(InvariantViolation, match="BR-2"):
        kol.transition_to_active(n_evaluated=9)


def test_kol_transition_to_active_non_provisional_raises() -> None:
    kol = make_kol(status=KolStatus.ACTIVE)
    with pytest.raises(InvariantViolation, match="PROVISIONAL status"):
        kol.transition_to_active(n_evaluated=15)


def test_kol_transition_to_active_blacklisted_raises() -> None:
    kol = make_kol(status=KolStatus.BLACKLISTED)
    with pytest.raises(InvariantViolation, match="PROVISIONAL status"):
        kol.transition_to_active(n_evaluated=20)


def test_kol_empty_name_raises() -> None:
    with pytest.raises(InvariantViolation, match="non-empty"):
        Kol(
            kol_id=KolId("kol-x"),
            name="",
            primary_channel_id=ChannelId("chan-x"),
            style=KolStyle.MIXED,
            status=KolStatus.PROVISIONAL,
        )


def test_kol_sectors_covered_default_empty() -> None:
    kol = make_kol()
    assert kol.sectors_covered == []


def test_kol_secondary_channels_default_empty() -> None:
    kol = make_kol()
    assert kol.secondary_channel_ids == []


# --- Channel aggregate tests ---


def test_channel_created_successfully() -> None:
    chan = make_channel(platform=Platform.YOUTUBE)
    assert chan.platform == Platform.YOUTUBE
    assert "youtube" in chan.url


def test_channel_platform_enum_str() -> None:
    assert Platform.YOUTUBE.value == "youtube"
    assert Platform.TELEGRAM.value == "telegram"
    assert Platform.FACEBOOK.value == "facebook"


def test_channel_empty_url_raises() -> None:
    with pytest.raises(ValueError, match="non-empty"):
        Channel(
            channel_id=ChannelId("chan-x"),
            platform=Platform.TELEGRAM,
            url="",
            kol_id=KolId("kol-x"),
        )


def test_channel_all_platforms() -> None:
    platforms = list(Platform)
    assert len(platforms) == 5  # youtube + telegram + facebook + podcast + blog


# --- ChannelContent value object tests ---


def test_channel_content_valid() -> None:
    pub = datetime.now(UTC) - timedelta(hours=1)
    content = ChannelContent(
        content_id="abc12345",
        channel_id=ChannelId("chan-001"),
        source_url="https://www.youtube.com/watch?v=abc",
        published_at=pub,
        raw_text="HPG mua mạnh tay",
    )
    assert content.raw_text == "HPG mua mạnh tay"
    assert content.content_id == "abc12345"


def test_channel_content_future_published_at_raises() -> None:
    future = datetime.now(UTC) + timedelta(hours=2)
    with pytest.raises(ValueError, match="future"):
        ChannelContent(
            content_id="abc12345",
            channel_id=ChannelId("chan-001"),
            source_url="https://t.me/test/1",
            published_at=future,
        )


def test_channel_content_empty_source_url_raises() -> None:
    pub = datetime.now(UTC) - timedelta(hours=1)
    with pytest.raises(ValueError, match="BR-1 provenance"):
        ChannelContent(
            content_id="abc12345",
            channel_id=ChannelId("chan-001"),
            source_url="",
            published_at=pub,
        )


def test_channel_content_empty_content_id_raises() -> None:
    pub = datetime.now(UTC) - timedelta(hours=1)
    with pytest.raises(ValueError, match="non-empty"):
        ChannelContent(
            content_id="",
            channel_id=ChannelId("chan-001"),
            source_url="https://t.me/test/1",
            published_at=pub,
        )


def test_channel_content_frozen_immutable() -> None:
    pub = datetime.now(UTC) - timedelta(minutes=30)
    content = ChannelContent(
        content_id="xyz99",
        channel_id=ChannelId("chan-001"),
        source_url="https://t.me/test/2",
        published_at=pub,
    )
    with pytest.raises(AttributeError):
        content.raw_text = "changed"  # type: ignore[misc]


def test_channel_content_vietnamese_text_preserved() -> None:
    """I-S2 diacritic round-trip: Vietnamese diacritics survive ChannelContent construction."""
    vi_text = "Cổ phiếu HPG: mua mạnh tay, theo dõi kỹ lưỡng, cẩn thận rủi ro ổn định"
    pub = datetime.now(UTC) - timedelta(hours=2)
    content = ChannelContent(
        content_id="vi_test_01",
        channel_id=ChannelId("chan-vi"),
        source_url="https://www.youtube.com/watch?v=vi_test",
        published_at=pub,
        raw_text=vi_text,
    )
    assert content.raw_text == vi_text
    # Verify key diacritics are byte-identical (ổ = ổ, ạ = ạ, ỹ = ỹ)
    assert "ổ" in content.raw_text
    assert "ạ" in content.raw_text
    assert "ỹ" in content.raw_text
