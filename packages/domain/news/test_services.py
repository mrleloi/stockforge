"""BC-5 News services — ClaimExtractionService tests (S36 Track D)."""

from __future__ import annotations

from datetime import UTC, datetime

from packages.contracts import Ticker
from packages.domain.news import (
    ClaimExtractionService,
    ExtractedClaim,
    NewsArticle,
)
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment


class _StubRepo:
    def __init__(self) -> None:
        self.saved: list[ExtractedClaim] = []

    def save_many(self, claims: list[ExtractedClaim]) -> int:
        self.saved.extend(claims)
        return len(claims)

    def get_for_ticker(
        self, ticker: Ticker, as_of_date: object | None = None
    ) -> list[ExtractedClaim]:
        del as_of_date  # stub ignores the cutoff
        return [c for c in self.saved if ticker in c.mentioned_tickers]

    def count(self) -> int:
        return len(self.saved)


class _StubExtractor:
    def __init__(self, claims_per_article: int = 1) -> None:
        self.claims_per_article = claims_per_article
        self.calls: list[NewsArticle] = []

    def extract(self, article: NewsArticle) -> list[ExtractedClaim]:
        self.calls.append(article)
        meta = ExtractorMetadata(
            extractor_model="stub",
            extractor_version="0.0",
            extractor_prompt_hash="stub-hash",
            extracted_at=datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
            confidence_extracted=0.7,
        )
        return [
            ExtractedClaim(
                claim_id=f"{article.article_id}:{i}",
                article_id=article.article_id,
                source_url=article.source_url,
                source_text_excerpt="excerpt-" * 3,
                claim_text=f"claim-{i}",
                sentiment=Sentiment.NEUTRAL,
                extractor=meta,
                mentioned_tickers=article.mentioned_tickers,
            )
            for i in range(self.claims_per_article)
        ]


def _article(article_id: str, tickers: tuple[Ticker, ...]) -> NewsArticle:
    return NewsArticle(
        article_id=article_id,
        source="cafef",
        source_url=f"https://cafef.vn/{article_id}.chn",
        title=f"Title {article_id}",
        body_excerpt="body",
        published_at=datetime(2026, 5, 1, 9, 0, tzinfo=UTC),
        ingested_at=datetime(2026, 5, 1, 9, 5, tzinfo=UTC),
        mentioned_tickers=tickers,
    )


def test_service_persists_extracted_claims() -> None:
    repo = _StubRepo()
    extractor = _StubExtractor(claims_per_article=2)
    service = ClaimExtractionService(extractor=extractor, claim_repo=repo)
    n = service.process(
        [_article("a1", (Ticker("VHM"),)), _article("a2", (Ticker("FPT"),))]
    )
    assert n == 4
    assert repo.count() == 4


def test_service_skips_articles_without_ticker_mentions() -> None:
    repo = _StubRepo()
    extractor = _StubExtractor()
    service = ClaimExtractionService(extractor=extractor, claim_repo=repo)
    n = service.process([_article("noisy", ())])
    assert n == 0
    assert extractor.calls == []


def test_service_returns_zero_when_extractor_emits_nothing() -> None:
    repo = _StubRepo()
    extractor = _StubExtractor(claims_per_article=0)
    service = ClaimExtractionService(extractor=extractor, claim_repo=repo)
    n = service.process([_article("a1", (Ticker("VHM"),))])
    assert n == 0
    assert repo.count() == 0
