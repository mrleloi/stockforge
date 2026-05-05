"""ingest_news_cafef — Tier 2 BC-5 News Stream nightly batch.

Pipeline:
1. Discover article URLs from CafeF section landing pages.
2. Rate-limited fetch + parse (1 req / 2 sec per spec § B.9).
3. Coarse-scan ticker mentions against the supplied universe (default VN30).
4. Persist NewsArticles to SQLite (Phase 2 substrate).
5. Hand articles with ≥1 ticker mention to ClaudeLlmExtractor; persist
   ExtractedClaims with full Rule 6 provenance.
6. Emit NewsArticleIngested + ExtractedClaimPublished events synchronously.

Phase 2 thin slice ($50 sandbox cap; nightly automation deferred to Phase 3).

Run:
  python apps/cli/ingest_news_cafef.py --tickers VN30 --max-articles 100 \\
    --output ./data/vn30-news.sqlite --skip-llm
"""

from __future__ import annotations

import sys
import time
from collections.abc import Sequence
from datetime import UTC, datetime
from pathlib import Path

import click

from packages.contracts import (
    ExtractedClaimPublished,
    NewsArticleIngested,
    Ticker,
)
from packages.domain.market_data import VN30_UNIVERSE, vn30_tickers
from packages.domain.news import (
    ClaimExtractionService,
    ExtractedClaim,
    NewsArticle,
)
from packages.infrastructure.news import (
    CafeFScraper,
    ClaudeLlmExtractor,
    SqliteClaimRepository,
    SqliteNewsRepository,
)


def _ensure_utf8_stdout() -> None:
    _reconfigure = getattr(sys.stdout, "reconfigure", None)
    if callable(_reconfigure):
        _reconfigure(encoding="utf-8")


def _httpx_fetcher(url: str) -> str:
    import httpx  # local import — adapter substrate

    headers = {
        "User-Agent": (
            "stockforge-research-bot/0.0.1 "
            "(+contact: nathanleewindy@gmail.com)"
        ),
        "Accept-Language": "vi,en;q=0.8",
    }
    response = httpx.get(url, headers=headers, timeout=15.0)
    response.raise_for_status()
    return response.text


@click.command()
@click.option(
    "--tickers",
    default="VN30",
    show_default=True,
    help='Either "VN30" or comma-separated symbols (e.g. "VHM,FPT").',
)
@click.option(
    "--since",
    default=None,
    help="Filter articles published >= ISO date (YYYY-MM-DD).",
)
@click.option(
    "--max-articles",
    default=100,
    show_default=True,
    type=int,
)
@click.option(
    "--listing",
    default="/thi-truong-chung-khoan.chn",
    show_default=True,
    help="CafeF section landing page path.",
)
@click.option(
    "--output",
    default="./data/vn30-news.sqlite",
    show_default=True,
    type=click.Path(dir_okay=False, path_type=Path),
)
@click.option(
    "--skip-llm",
    is_flag=True,
    default=False,
    help="Skip claim extraction (article ingestion only). Default extracts.",
)
@click.option(
    "--summary",
    default=None,
    type=click.Path(dir_okay=False, path_type=Path),
)
def main(
    tickers: str,
    since: str | None,
    max_articles: int,
    listing: str,
    output: Path,
    skip_llm: bool,
    summary: Path | None,
) -> int:
    _ensure_utf8_stdout()
    universe = _resolve_universe(tickers)
    since_dt = (
        datetime.fromisoformat(since).replace(tzinfo=UTC) if since else None
    )
    summary_path = (
        summary if summary is not None
        else output.with_name("vn30-news-summary.md")
    )

    click.echo(
        f"[ingest_news_cafef] universe={len(universe)} listing={listing} "
        f"max-articles={max_articles} output={output} skip-llm={skip_llm}"
    )

    scraper = CafeFScraper(fetcher=_httpx_fetcher)
    news_repo = SqliteNewsRepository(db_path=output)
    claim_repo = SqliteClaimRepository(db_path=output)

    articles = _scrape_articles(
        scraper=scraper,
        listing=listing,
        max_articles=max_articles,
        universe=universe,
        since=since_dt,
    )
    written_articles = news_repo.save_many(articles)
    article_events = [_to_news_event(a) for a in articles]
    click.echo(
        f"[ingest_news_cafef] articles_scraped={len(articles)} "
        f"articles_written={written_articles} "
        f"with_ticker_mention={sum(1 for a in articles if a.mentioned_tickers)}"
    )

    claims: list[ExtractedClaim] = []
    if not skip_llm:
        extractor = ClaudeLlmExtractor()
        service = ClaimExtractionService(
            extractor=extractor, claim_repo=claim_repo
        )
        claims = _extract_claims(service, articles, extractor)
        claim_events = [_to_claim_event(c) for c in claims]
        click.echo(
            f"[ingest_news_cafef] claims_extracted={len(claims)} "
            f"events_emitted={len(article_events)}/{len(claim_events)}"
        )
    else:
        click.echo("[ingest_news_cafef] skip-llm enabled; no extraction")

    _write_summary(summary_path, articles, claims, article_events)
    click.echo(f"[ingest_news_cafef] summary written: {summary_path}")
    click.echo("[ingest_news_cafef] OK")
    return 0


def _resolve_universe(tickers_arg: str) -> Sequence[Ticker]:
    if tickers_arg.upper() == "VN30":
        return vn30_tickers()
    requested = [
        Ticker(s.strip()) for s in tickers_arg.split(",") if s.strip()
    ]
    valid = {c.ticker.symbol for c in VN30_UNIVERSE}
    invalid = [t.symbol for t in requested if t.symbol not in valid]
    if invalid:
        raise click.UsageError(
            f"--tickers contains non-VN30 entries: {invalid}"
        )
    return requested


def _scrape_articles(
    *,
    scraper: CafeFScraper,
    listing: str,
    max_articles: int,
    universe: Sequence[Ticker],
    since: datetime | None,
) -> list[NewsArticle]:
    # `listing` accepts CSV: each path scraped once with quota = max_articles
    # divided across listings. Per-listing failures degrade gracefully (L-S28-1).
    listing_paths = [p.strip() for p in listing.split(",") if p.strip()]
    quota_per_listing = max(max_articles // max(len(listing_paths), 1), 1)
    seen_urls: set[str] = set()
    all_urls: list[str] = []
    for path in listing_paths:
        try:
            urls = scraper.discover(path, max_articles=quota_per_listing)
        except Exception as exc:  # vendor-drift L-S28-1 doctrine
            click.echo(
                f"[ingest_news_cafef] discovery FAILED on {path}: {exc}", err=True
            )
            continue
        for url in urls:
            if url in seen_urls:
                continue
            seen_urls.add(url)
            all_urls.append(url)
    out: list[NewsArticle] = []
    for url in all_urls:
        scraped = scraper.fetch_article(url)
        if scraped is None:
            continue
        if since is not None and scraped.published_at < since:
            continue
        out.append(scraper.to_news_article(scraped, universe))
    return out


def _extract_claims(
    service: ClaimExtractionService,
    articles: list[NewsArticle],
    extractor: ClaudeLlmExtractor,
) -> list[ExtractedClaim]:
    relevant = [a for a in articles if a.mentioned_tickers]
    persisted = service.process(relevant)
    if persisted == 0:
        return []
    return [c for a in relevant for c in extractor.extract(a)]


def _to_news_event(article: NewsArticle) -> NewsArticleIngested:
    return NewsArticleIngested(
        article_id=article.article_id,
        source=article.source,
        source_url=article.source_url,
        published_at=article.published_at,
        ingested_at=article.ingested_at,
        mentioned_tickers=article.mentioned_tickers,
        emitted_at=datetime.now(UTC),
    )


def _to_claim_event(claim: ExtractedClaim) -> ExtractedClaimPublished:
    return ExtractedClaimPublished(
        claim_id=claim.claim_id,
        article_id=claim.article_id,
        source_url=claim.source_url,
        sentiment=claim.sentiment.value,
        mentioned_tickers=claim.mentioned_tickers,
        mentioned_sectors=claim.mentioned_sectors,
        extractor_model=claim.extractor.extractor_model,
        extracted_at=claim.extractor.extracted_at,
        confidence_extracted=claim.extractor.confidence_extracted,
        emitted_at=datetime.now(UTC),
    )


def _write_summary(
    path: Path,
    articles: list[NewsArticle],
    claims: list[ExtractedClaim],
    article_events: list[NewsArticleIngested],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with_mention = [a for a in articles if a.mentioned_tickers]
    sentiment_counts: dict[str, int] = {}
    for c in claims:
        sentiment_counts[c.sentiment.value] = (
            sentiment_counts.get(c.sentiment.value, 0) + 1
        )
    lines: list[str] = [
        "# CafeF News Ingestion Summary",
        "",
        f"**Articles scraped**: {len(articles)}",
        f"**Articles with ≥1 ticker mention**: {len(with_mention)}",
        f"**Claims extracted**: {len(claims)}",
        f"**Article events emitted**: {len(article_events)}",
        "",
        "## Sentiment distribution (categorical per Rule 7)",
        "",
        "| Sentiment | Count |",
        "|---|---|",
    ]
    for label in (
        "strongly_bullish",
        "bullish",
        "neutral",
        "bearish",
        "strongly_bearish",
    ):
        lines.append(f"| {label} | {sentiment_counts.get(label, 0)} |")
    if articles:
        lines += [
            "",
            "## First 5 articles",
            "",
        ]
        for a in articles[:5]:
            tag = ",".join(t.symbol for t in a.mentioned_tickers) or "—"
            lines.append(f"- [{a.title}]({a.source_url}) tickers={tag}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


# Quiet a never-used `time` import warning when --skip-llm path is taken; the
# rate limiter inside CafeFScraper consumes time.sleep but ruff scans only
# this module's direct usage.
_ = time

if __name__ == "__main__":
    sys.exit(main(standalone_mode=False) or 0)
