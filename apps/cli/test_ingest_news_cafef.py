"""CLI smoke tests for `apps/cli/ingest_news_cafef.py` (S36 Track D).

NO live network calls. The httpx fetcher is monkey-patched + the LLM
extractor is replaced with a stub that returns deterministic claims so
the whole pipeline (scrape → repo → extract → repo → summary) is exercised.
"""

from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path

import pytest
from click.testing import CliRunner

from apps.cli import ingest_news_cafef
from packages.domain.news.models import ExtractedClaim, NewsArticle
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment

_LISTING_HTML = """
<html><body>
<a href="/vhm-quy-1.chn">VHM Q1</a>
<a href="/fpt-doanh-thu.chn">FPT</a>
</body></html>
"""

_VHM_ARTICLE_HTML = """
<html><body>
<h1>VHM công bố lãi quý 1 2026</h1>
<span class="pdate">30-04-2026 09:00:00</span>
<div class="detail-content">
<p>Vinhomes (mã VHM) báo lãi 5.000 tỷ đồng trong quý 1.</p>
</div>
</body></html>
"""

_FPT_ARTICLE_HTML = """
<html><body>
<h1>FPT doanh thu tăng 25%</h1>
<span class="pdate">30-04-2026 10:00:00</span>
<div class="detail-content">
<p>FPT báo doanh thu tăng 25% trong quý 1 năm 2026.</p>
</div>
</body></html>
"""


def _fake_fetcher(url: str) -> str:
    if url.endswith("/thi-truong-chung-khoan.chn"):
        return _LISTING_HTML
    if "vhm" in url.lower():
        return _VHM_ARTICLE_HTML
    if "fpt" in url.lower():
        return _FPT_ARTICLE_HTML
    raise RuntimeError(f"unexpected url: {url}")


def _patch_pipeline(monkeypatch: pytest.MonkeyPatch) -> list[NewsArticle]:
    """Patch the CLI's httpx fetcher + LLM extractor with stubs.

    Returns the list that captures articles passed to the stub extractor for
    cross-test assertion.
    """
    monkeypatch.setattr(ingest_news_cafef, "_httpx_fetcher", _fake_fetcher)

    captured: list[NewsArticle] = []

    class _StubExtractor:
        def __init__(self) -> None:
            self.model = "stub"
            self.version = "0.0"
            self.system_prompt = "stub"
            self.transport = lambda _system, _body: ""
            self.clock = lambda: datetime(2026, 5, 1, 10, 0, tzinfo=UTC)

        @property
        def prompt_hash(self) -> str:
            return "stub-hash"

        def extract(self, article: NewsArticle) -> list[ExtractedClaim]:
            captured.append(article)
            if not article.mentioned_tickers:
                return []
            meta = ExtractorMetadata(
                extractor_model="stub",
                extractor_version="0.0",
                extractor_prompt_hash="stub-hash",
                extracted_at=datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
                confidence_extracted=0.8,
            )
            return [
                ExtractedClaim(
                    claim_id=f"{article.article_id}:0",
                    article_id=article.article_id,
                    source_url=article.source_url,
                    source_text_excerpt="recorded excerpt",
                    claim_text=f"claim for {article.title}",
                    sentiment=Sentiment.BULLISH,
                    extractor=meta,
                    mentioned_tickers=article.mentioned_tickers,
                )
            ]

    monkeypatch.setattr(ingest_news_cafef, "ClaudeLlmExtractor", _StubExtractor)
    return captured


def test_cli_runs_with_skip_llm(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    _patch_pipeline(monkeypatch)
    runner = CliRunner()
    output = tmp_path / "news.sqlite"
    result = runner.invoke(
        ingest_news_cafef.main,
        [
            "--tickers",
            "VHM,FPT",
            "--max-articles",
            "5",
            "--output",
            str(output),
            "--skip-llm",
        ],
        standalone_mode=False,
    )
    assert result.exit_code == 0, result.output
    assert output.exists()
    assert "skip-llm enabled" in result.output


def test_cli_extracts_claims_when_llm_enabled(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    captured = _patch_pipeline(monkeypatch)
    runner = CliRunner()
    output = tmp_path / "news.sqlite"
    result = runner.invoke(
        ingest_news_cafef.main,
        [
            "--tickers",
            "VHM,FPT",
            "--max-articles",
            "5",
            "--output",
            str(output),
        ],
        standalone_mode=False,
    )
    assert result.exit_code == 0, result.output
    assert "claims_extracted" in result.output
    assert any(a.mentioned_tickers for a in captured)


def test_cli_writes_summary_with_sentiment_distribution(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    _patch_pipeline(monkeypatch)
    runner = CliRunner()
    output = tmp_path / "news.sqlite"
    result = runner.invoke(
        ingest_news_cafef.main,
        [
            "--tickers",
            "VHM,FPT",
            "--max-articles",
            "5",
            "--output",
            str(output),
        ],
        standalone_mode=False,
    )
    assert result.exit_code == 0, result.output
    summary = output.with_name("vn30-news-summary.md").read_text(
        encoding="utf-8"
    )
    assert "Sentiment distribution" in summary
    assert "bullish" in summary


def test_cli_rejects_invalid_tickers(monkeypatch: pytest.MonkeyPatch) -> None:
    _patch_pipeline(monkeypatch)
    runner = CliRunner()
    result = runner.invoke(
        ingest_news_cafef.main,
        ["--tickers", "NOTREAL", "--skip-llm"],
        standalone_mode=False,
    )
    assert result.exit_code != 0
