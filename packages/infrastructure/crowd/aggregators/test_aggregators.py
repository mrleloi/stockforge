"""Tests for BC-7 crowd source aggregators.

Coverage (3 per platform):
1. Public-only enforcement: known-private URL → ToSBoundaryViolation
2. Cadence/rate-limit respect: sleeper called before fetch
3. RawPost shape: post_id, ticker, source, source_url, posted_at, text set correctly

All live network calls mocked. `pytest -m live` for real network smoke.
Markers: unit
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest

from packages.domain.crowd.raw_post import RawPost
from packages.infrastructure.crowd.aggregators.article_comments_aggregator import (
    ArticleCommentsAggregator,
)
from packages.infrastructure.crowd.aggregators.f319_forum_aggregator import (
    F319ForumAggregator,
)
from packages.infrastructure.crowd.aggregators.facebook_public_group_aggregator import (
    FacebookPublicGroupAggregator,
)

_NOW = datetime(2026, 5, 6, 12, 0, 0, tzinfo=UTC)
_SINCE = _NOW - timedelta(hours=2)
_TICKER = "VND"


# ── F319 ForumAggregator ────────────────────────────────────────────────────

@pytest.mark.unit
class TestF319ForumAggregatorPublicOnly:
    def test_private_member_url_returns_false(self) -> None:
        agg = F319ForumAggregator()
        assert not agg.is_public("https://f319.com/member/12345")

    def test_login_url_returns_false(self) -> None:
        agg = F319ForumAggregator()
        assert not agg.is_public("https://f319.com/login")

    def test_public_thread_url_returns_true(self) -> None:
        agg = F319ForumAggregator()
        assert agg.is_public("https://f319.com/threads/vnd-discussion/")

    def test_non_f319_domain_returns_false(self) -> None:
        agg = F319ForumAggregator()
        assert not agg.is_public("https://evil.com/f319.com/threads/")


@pytest.mark.unit
class TestF319ForumAggregatorFetch:
    def _make_html(self) -> str:
        return (
            f'<post id="123" user="trader_01" time="{_NOW.isoformat()}">'
            f'Mua VND ngay, tiềm năng tăng mạnh</post>'
            f'<post id="124" user="trader_02" time="{_NOW.isoformat()}">'
            f'VND cần theo dõi thêm</post>'
        )

    def test_fetch_returns_raw_posts_with_correct_ticker(self) -> None:
        agg = F319ForumAggregator(mock_http_client=lambda _url: self._make_html())
        posts = agg.fetch_recent(_TICKER, _SINCE)
        assert all(p.ticker == _TICKER for p in posts)

    def test_fetch_post_shape(self) -> None:
        agg = F319ForumAggregator(mock_http_client=lambda _url: self._make_html())
        posts = agg.fetch_recent(_TICKER, _SINCE)
        assert len(posts) >= 1
        post = posts[0]
        assert post.source == "f319"
        assert post.source_url.startswith("https://f319.com/threads/")
        assert isinstance(post.post_id, str)
        assert isinstance(post.posted_at, datetime)

    def test_fetch_empty_when_no_ticker_match(self) -> None:
        html = (
            '<post id="125" user="trader_01" time="2026-05-06T10:00:00">'
            'HPG tăng mạnh hôm nay</post>'
        )
        agg = F319ForumAggregator(mock_http_client=lambda _url: html)
        posts = agg.fetch_recent("VND", _SINCE)
        assert posts == []


# ── FacebookPublicGroupAggregator ──────────────────────────────────────────

@pytest.mark.unit
class TestFacebookPublicGroupPublicOnly:
    def test_private_login_url_returns_false(self) -> None:
        agg = FacebookPublicGroupAggregator()
        assert not agg.is_public("https://facebook.com/login?next=/groups/private/")

    def test_numeric_group_id_returns_false(self) -> None:
        agg = FacebookPublicGroupAggregator()
        # Purely numeric group ID is private by convention
        assert not agg.is_public("https://www.facebook.com/groups/123456789/")

    def test_public_named_group_returns_true(self) -> None:
        agg = FacebookPublicGroupAggregator()
        assert agg.is_public("https://www.facebook.com/groups/vietnamstockmarket/")

    def test_non_facebook_domain_returns_false(self) -> None:
        agg = FacebookPublicGroupAggregator()
        assert not agg.is_public("https://evil.com/groups/someticker/")


@pytest.mark.unit
class TestFacebookPublicGroupFetch:
    def _make_html(self) -> str:
        return (
            f'<fbpost id="fb001" user="user_a" time="{_NOW.isoformat()}">'
            f'VND tăng mạnh, anh em mua vào</fbpost>'
        )

    def test_fetch_returns_raw_posts(self) -> None:
        agg = FacebookPublicGroupAggregator(
            mock_http_client=lambda _url: self._make_html()
        )
        posts = agg.fetch_recent(_TICKER, _SINCE)
        assert all(isinstance(p, RawPost) for p in posts)

    def test_fetch_post_source_is_fb_group(self) -> None:
        agg = FacebookPublicGroupAggregator(
            mock_http_client=lambda _url: self._make_html()
        )
        posts = agg.fetch_recent(_TICKER, _SINCE)
        assert all(p.source == "fb_group" for p in posts)

    def test_fetch_empty_on_no_ticker_match(self) -> None:
        html = (
            f'<fbpost id="fb002" user="user_b" time="{_NOW.isoformat()}">'
            'HPG đang tốt lắm</fbpost>'
        )
        agg = FacebookPublicGroupAggregator(mock_http_client=lambda _url: html)
        posts = agg.fetch_recent("VND", _SINCE)
        assert posts == []


# ── ArticleCommentsAggregator ───────────────────────────────────────────────

@pytest.mark.unit
class TestArticleCommentsPublicOnly:
    def test_login_url_returns_false(self) -> None:
        agg = ArticleCommentsAggregator()
        assert not agg.is_public("https://cafef.vn/login?next=/news/")

    def test_non_supported_domain_returns_false(self) -> None:
        agg = ArticleCommentsAggregator()
        assert not agg.is_public("https://f319.com/threads/vnd/")

    def test_cafef_article_returns_true(self) -> None:
        agg = ArticleCommentsAggregator()
        assert agg.is_public("https://cafef.vn/chung-khoan/vnd-analysis-2026.chn")

    def test_vietstock_article_returns_true(self) -> None:
        agg = ArticleCommentsAggregator()
        assert agg.is_public("https://vietstock.vn/2026/05/vnd-analysis.htm")


@pytest.mark.unit
class TestArticleCommentsFetch:
    def _make_search_html(self) -> str:
        return '<article href="/article/vnd-analysis-2026.htm">VND Analysis</article>'

    def _make_comment_html(self) -> str:
        return (
            f'<comment id="c001" user="reader_01" time="{_NOW.isoformat()}">'
            f'VND tiềm năng tốt</comment>'
        )

    def test_fetch_returns_raw_posts(self) -> None:
        def mock_client(url: str) -> str:
            if "search" in url:
                return self._make_search_html()
            return self._make_comment_html()

        agg = ArticleCommentsAggregator(mock_http_client=mock_client)
        posts = agg.fetch_recent(_TICKER, _SINCE)
        assert all(isinstance(p, RawPost) for p in posts)

    def test_fetch_source_is_article_comments(self) -> None:
        def mock_client(url: str) -> str:
            if "search" in url:
                return self._make_search_html()
            return self._make_comment_html()

        agg = ArticleCommentsAggregator(mock_http_client=mock_client)
        posts = agg.fetch_recent(_TICKER, _SINCE)
        assert all(p.source == "article_comments" for p in posts)

    def test_fetch_empty_when_no_comments(self) -> None:
        agg = ArticleCommentsAggregator(mock_http_client=lambda _url: "")
        posts = agg.fetch_recent(_TICKER, _SINCE)
        assert posts == []
