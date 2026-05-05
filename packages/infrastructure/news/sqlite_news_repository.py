"""SqliteNewsRepository / SqliteClaimRepository — local SQLite persistence.

Phase 2 thin slice substrate per master-plan 005 § S36. Pgvector / R2 raw
body storage deferred to Phase 3 per spec-T1-001 § B.6.

Schema layout:
- `news_articles(article_id PK, source, source_url, title, body_excerpt,
  published_at, ingested_at, mentioned_tickers_json, language)`
- `extracted_claims(claim_id PK, article_id FK, source_url,
  source_text_excerpt, claim_text, sentiment, mentioned_tickers_json,
  mentioned_sectors_json, key_phrases_json, tone_indicators_json,
  extractor_model, extractor_version, extractor_prompt_hash, extracted_at,
  confidence_extracted, verified_by_human)`

Both tables: `INSERT OR REPLACE` so idempotent re-runs converge.
"""

from __future__ import annotations

import json
import sqlite3
from contextlib import closing
from dataclasses import dataclass
from datetime import date, datetime
from pathlib import Path

from packages.contracts import Ticker
from packages.domain.news.models import ExtractedClaim, NewsArticle
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment

__all__ = ["SqliteClaimRepository", "SqliteNewsRepository"]


_NEWS_SCHEMA = """
CREATE TABLE IF NOT EXISTS news_articles (
    article_id              TEXT PRIMARY KEY,
    source                  TEXT NOT NULL,
    source_url              TEXT NOT NULL,
    title                   TEXT NOT NULL,
    body_excerpt            TEXT NOT NULL,
    published_at            TEXT NOT NULL,
    ingested_at             TEXT NOT NULL,
    mentioned_tickers_json  TEXT NOT NULL DEFAULT '[]',
    language                TEXT NOT NULL DEFAULT 'vi'
);
CREATE INDEX IF NOT EXISTS idx_news_published ON news_articles(published_at);
CREATE INDEX IF NOT EXISTS idx_news_ingested ON news_articles(ingested_at);
"""

_CLAIM_SCHEMA = """
CREATE TABLE IF NOT EXISTS extracted_claims (
    claim_id                 TEXT PRIMARY KEY,
    article_id               TEXT NOT NULL,
    source_url               TEXT NOT NULL,
    source_text_excerpt      TEXT NOT NULL,
    claim_text               TEXT NOT NULL,
    sentiment                TEXT NOT NULL,
    mentioned_tickers_json   TEXT NOT NULL DEFAULT '[]',
    mentioned_sectors_json   TEXT NOT NULL DEFAULT '[]',
    key_phrases_json         TEXT NOT NULL DEFAULT '[]',
    tone_indicators_json     TEXT NOT NULL DEFAULT '[]',
    extractor_model          TEXT NOT NULL,
    extractor_version        TEXT NOT NULL,
    extractor_prompt_hash    TEXT NOT NULL,
    extracted_at             TEXT NOT NULL,
    confidence_extracted     REAL NOT NULL,
    verified_by_human        INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_claim_article ON extracted_claims(article_id);
"""


@dataclass
class SqliteNewsRepository:
    """SQLite-backed NewsRepository implementation."""

    db_path: Path

    def __post_init__(self) -> None:
        self.db_path = Path(self.db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executescript(_NEWS_SCHEMA)
            conn.commit()

    def save_many(self, articles: list[NewsArticle]) -> int:
        if not articles:
            return 0
        rows = [self._to_row(a) for a in articles]
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executemany(
                """
                INSERT OR REPLACE INTO news_articles (
                    article_id, source, source_url, title, body_excerpt,
                    published_at, ingested_at, mentioned_tickers_json, language
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                rows,
            )
            conn.commit()
        return len(rows)

    def get_known_as_of(
        self,
        ticker: Ticker,
        as_of_date: date,
        acting_lag_minutes: int = 0,
    ) -> list[NewsArticle]:
        cutoff = datetime.combine(
            as_of_date, datetime.min.time()
        ).isoformat()
        rows = self._query(
            """
            SELECT * FROM news_articles
            WHERE published_at <= ?
              AND ingested_at <= ?
            ORDER BY published_at DESC
            """,
            (cutoff, cutoff),
        )
        # In-memory ticker filter — keeps schema simple (avoids FTS index
        # in Phase 2 thin slice; pgvector + JSONB array contains in Phase 3).
        # acting_lag_minutes adjusts the published_at cutoff per Rule 8.
        del acting_lag_minutes  # no-op in Phase 2; reserved for Phase 3
        return [a for a in rows if ticker in a.mentioned_tickers]

    def get_recent(self, ticker: Ticker, since: datetime) -> list[NewsArticle]:
        rows = self._query(
            """
            SELECT * FROM news_articles
            WHERE ingested_at >= ?
            ORDER BY published_at DESC
            """,
            (since.isoformat(),),
        )
        return [a for a in rows if ticker in a.mentioned_tickers]

    def count(self) -> int:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            cur = conn.execute("SELECT COUNT(*) FROM news_articles")
            return int(cur.fetchone()[0])

    def _query(
        self, sql: str, params: tuple[object, ...]
    ) -> list[NewsArticle]:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(sql, params)
            return [self._from_row(dict(r)) for r in cur.fetchall()]

    @staticmethod
    def _to_row(a: NewsArticle) -> tuple[object, ...]:
        return (
            a.article_id,
            a.source,
            a.source_url,
            a.title,
            a.body_excerpt,
            a.published_at.isoformat(),
            a.ingested_at.isoformat(),
            json.dumps([t.symbol for t in a.mentioned_tickers]),
            a.language,
        )

    @staticmethod
    def _from_row(row: dict[str, object]) -> NewsArticle:
        ticker_symbols = json.loads(str(row["mentioned_tickers_json"]))
        return NewsArticle(
            article_id=str(row["article_id"]),
            source=str(row["source"]),
            source_url=str(row["source_url"]),
            title=str(row["title"]),
            body_excerpt=str(row["body_excerpt"]),
            published_at=datetime.fromisoformat(str(row["published_at"])),
            ingested_at=datetime.fromisoformat(str(row["ingested_at"])),
            mentioned_tickers=tuple(Ticker(s) for s in ticker_symbols),
            language=str(row["language"]),
        )


@dataclass
class SqliteClaimRepository:
    """SQLite-backed ClaimRepository implementation. Shares db_path with
    `SqliteNewsRepository` so a single DB file holds both tables.
    """

    db_path: Path

    def __post_init__(self) -> None:
        self.db_path = Path(self.db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executescript(_CLAIM_SCHEMA)
            conn.commit()

    def save_many(self, claims: list[ExtractedClaim]) -> int:
        if not claims:
            return 0
        rows = [self._to_row(c) for c in claims]
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executemany(
                """
                INSERT OR REPLACE INTO extracted_claims (
                    claim_id, article_id, source_url, source_text_excerpt,
                    claim_text, sentiment, mentioned_tickers_json,
                    mentioned_sectors_json, key_phrases_json,
                    tone_indicators_json, extractor_model, extractor_version,
                    extractor_prompt_hash, extracted_at, confidence_extracted,
                    verified_by_human
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                rows,
            )
            conn.commit()
        return len(rows)

    def get_for_ticker(
        self,
        ticker: Ticker,
        as_of_date: date | None = None,
    ) -> list[ExtractedClaim]:
        rows = self._query(
            "SELECT * FROM extracted_claims ORDER BY extracted_at DESC",
            (),
        )
        result = [c for c in rows if ticker in c.mentioned_tickers]
        if as_of_date is not None:
            cutoff = datetime.combine(as_of_date, datetime.min.time())
            result = [c for c in result if c.extractor.extracted_at <= cutoff]
        return result

    def count(self) -> int:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            cur = conn.execute("SELECT COUNT(*) FROM extracted_claims")
            return int(cur.fetchone()[0])

    def _query(
        self, sql: str, params: tuple[object, ...]
    ) -> list[ExtractedClaim]:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(sql, params)
            return [self._from_row(dict(r)) for r in cur.fetchall()]

    @staticmethod
    def _to_row(c: ExtractedClaim) -> tuple[object, ...]:
        return (
            c.claim_id,
            c.article_id,
            c.source_url,
            c.source_text_excerpt,
            c.claim_text,
            c.sentiment.value,
            json.dumps([t.symbol for t in c.mentioned_tickers]),
            json.dumps(list(c.mentioned_sectors)),
            json.dumps(list(c.key_phrases)),
            json.dumps(list(c.tone_indicators)),
            c.extractor.extractor_model,
            c.extractor.extractor_version,
            c.extractor.extractor_prompt_hash,
            c.extractor.extracted_at.isoformat(),
            c.extractor.confidence_extracted,
            int(c.extractor.verified_by_human),
        )

    @staticmethod
    def _from_row(row: dict[str, object]) -> ExtractedClaim:
        meta = ExtractorMetadata(
            extractor_model=str(row["extractor_model"]),
            extractor_version=str(row["extractor_version"]),
            extractor_prompt_hash=str(row["extractor_prompt_hash"]),
            extracted_at=datetime.fromisoformat(str(row["extracted_at"])),
            confidence_extracted=float(row["confidence_extracted"]),  # type: ignore[arg-type]
            verified_by_human=bool(row["verified_by_human"]),
        )
        return ExtractedClaim(
            claim_id=str(row["claim_id"]),
            article_id=str(row["article_id"]),
            source_url=str(row["source_url"]),
            source_text_excerpt=str(row["source_text_excerpt"]),
            claim_text=str(row["claim_text"]),
            sentiment=Sentiment(str(row["sentiment"])),
            extractor=meta,
            mentioned_tickers=tuple(
                Ticker(s) for s in json.loads(str(row["mentioned_tickers_json"]))
            ),
            mentioned_sectors=tuple(
                json.loads(str(row["mentioned_sectors_json"]))
            ),
            key_phrases=tuple(json.loads(str(row["key_phrases_json"]))),
            tone_indicators=tuple(
                json.loads(str(row["tone_indicators_json"]))
            ),
        )
