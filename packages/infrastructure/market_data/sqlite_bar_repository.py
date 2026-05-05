"""SqliteBarRepository — local SQLite Bar persistence implementing BarRepository.

Phase 1 thin-slice substrate per spec 000 § A.5. TimescaleDB hypertable
deferred to Phase 2 when VN30-wide ingestion lands; SQLite proves the adapter
contract on a single ticker without Docker complexity.

Storage layout: one row per (ticker, period_end, source_provider) so multi-
source reconciliation audit trail is preserved on disk. Read methods dedupe
by (ticker, period_end), preferring SourceProvider.VNSTOCK over TCBS over
others (alphabetical tie-break) — keeps the BarRepository Protocol contract
returning one Bar per period.

`save_many` is the ingestion-side write method; per S27 `bar_repository.py`
docstring, the Protocol intentionally has no write methods — adapters write
directly through the concrete impl. Idempotent via ON CONFLICT REPLACE so
repeated CLI runs produce the same on-disk state.

Decimal precision preserved by storing amounts as TEXT and reconstructing via
`Decimal(str)` on read. SQLite numeric types would silently round; the
financial-data-protocol does not allow that.
"""

from __future__ import annotations

import sqlite3
from collections.abc import Iterable
from contextlib import closing
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

from packages.contracts import (
    AdjustmentType,
    BarId,
    Currency,
    Money,
    SourceProvider,
    Ticker,
)
from packages.domain.market_data.models import Bar

__all__ = ["SqliteBarRepository"]


_SCHEMA = """
CREATE TABLE IF NOT EXISTS bars (
    bar_id          TEXT PRIMARY KEY,
    ticker          TEXT NOT NULL,
    period_end      TEXT NOT NULL,
    filing_date     TEXT NOT NULL,
    ingested_at     TEXT NOT NULL,
    open_amount     TEXT NOT NULL,
    high_amount     TEXT NOT NULL,
    low_amount      TEXT NOT NULL,
    close_amount    TEXT NOT NULL,
    currency        TEXT NOT NULL,
    volume          INTEGER NOT NULL,
    foreign_buy     INTEGER NOT NULL,
    foreign_sell    INTEGER NOT NULL,
    adjustment_type TEXT NOT NULL,
    source_provider TEXT NOT NULL,
    UNIQUE(ticker, period_end, source_provider)
);
CREATE INDEX IF NOT EXISTS idx_bars_ticker_period ON bars(ticker, period_end);
CREATE INDEX IF NOT EXISTS idx_bars_filing ON bars(filing_date);
"""


_SOURCE_PRIORITY = (
    SourceProvider.VNSTOCK,
    SourceProvider.TCBS,
    SourceProvider.FIINPRO,
    SourceProvider.SSI,
    SourceProvider.WICHART,
    SourceProvider.MANUAL,
    SourceProvider.SCRAPED_OTHER,
)


@dataclass
class SqliteBarRepository:
    """SQLite-backed Bar persistence. Implements `BarRepository` Protocol."""

    db_path: Path

    def __post_init__(self) -> None:
        self.db_path = Path(self.db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executescript(_SCHEMA)
            conn.commit()

    def save_many(self, bars: Iterable[Bar]) -> int:
        rows = [self._to_row(b) for b in bars]
        if not rows:
            return 0
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executemany(
                """
                INSERT OR REPLACE INTO bars (
                    bar_id, ticker, period_end, filing_date, ingested_at,
                    open_amount, high_amount, low_amount, close_amount, currency,
                    volume, foreign_buy, foreign_sell,
                    adjustment_type, source_provider
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                rows,
            )
            conn.commit()
        return len(rows)

    def save_many_by_ticker(self, bars_by_ticker: dict[Ticker, list[Bar]]) -> dict[Ticker, int]:
        """Persist multiple tickers' bars with per-ticker transaction isolation.

        S33 Track B: VN30 batch ingestion calls this once per CLI run with up
        to 30 tickers. Each ticker commits independently; a malformed batch
        for ticker X does not roll back tickers Y/Z that already succeeded.
        Caller observes per-ticker outcome via the returned `{Ticker: rows_written}`
        map. Tickers that raise mid-flush surface as a `0` entry plus the
        underlying SqliteError logged on stderr; the partial-failure tolerance
        matches Q-S28-3 doctrine ("log + continue, not block").
        """
        out: dict[Ticker, int] = {}
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            for ticker, bars in bars_by_ticker.items():
                rows = [self._to_row(b) for b in bars]
                if not rows:
                    out[ticker] = 0
                    continue
                try:
                    conn.executemany(
                        """
                        INSERT OR REPLACE INTO bars (
                            bar_id, ticker, period_end, filing_date, ingested_at,
                            open_amount, high_amount, low_amount, close_amount, currency,
                            volume, foreign_buy, foreign_sell,
                            adjustment_type, source_provider
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        rows,
                    )
                    conn.commit()
                    out[ticker] = len(rows)
                except sqlite3.Error:
                    conn.rollback()
                    out[ticker] = 0
        return out

    def count_for(self, ticker: Ticker) -> int:
        """Return number of stored rows for a single ticker (all sources)."""
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            cur = conn.execute(
                "SELECT COUNT(*) FROM bars WHERE ticker = ?", (ticker.symbol,)
            )
            return int(cur.fetchone()[0])

    def get_as_of(self, ticker: Ticker, as_of_date: date) -> list[Bar]:
        sql = """
            SELECT * FROM bars
            WHERE ticker = ?
              AND period_end <= ?
              AND filing_date <= ?
            ORDER BY period_end ASC
        """
        return self._dedupe(self._query(sql, (ticker.symbol, as_of_date.isoformat(), as_of_date.isoformat())))

    def get_latest(self, ticker: Ticker) -> Bar | None:
        bars = self._dedupe(
            self._query(
                "SELECT * FROM bars WHERE ticker = ? ORDER BY period_end DESC LIMIT 10",
                (ticker.symbol,),
            )
        )
        return bars[-1] if bars else None

    def get_range_adjusted(
        self, ticker: Ticker, start: date, end: date
    ) -> list[Bar]:
        sql = """
            SELECT * FROM bars
            WHERE ticker = ?
              AND period_end BETWEEN ? AND ?
              AND adjustment_type = ?
            ORDER BY period_end ASC
        """
        return self._dedupe(
            self._query(sql, (ticker.symbol, start.isoformat(), end.isoformat(), AdjustmentType.BOTH.value))
        )

    def count(self) -> int:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            cur = conn.execute("SELECT COUNT(*) FROM bars")
            return int(cur.fetchone()[0])

    def _query(self, sql: str, params: tuple[object, ...]) -> list[Bar]:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(sql, params)
            return [self._from_row(dict(r)) for r in cur.fetchall()]

    @staticmethod
    def _dedupe(bars: list[Bar]) -> list[Bar]:
        by_period: dict[date, Bar] = {}
        priority = {sp: i for i, sp in enumerate(_SOURCE_PRIORITY)}
        for b in bars:
            existing = by_period.get(b.period_end)
            if existing is None or priority.get(b.source_provider, 999) < priority.get(existing.source_provider, 999):
                by_period[b.period_end] = b
        return sorted(by_period.values(), key=lambda x: x.period_end)

    @staticmethod
    def _to_row(b: Bar) -> tuple[object, ...]:
        return (
            b.bar_id,
            b.ticker.symbol,
            b.period_end.isoformat(),
            b.filing_date.isoformat(),
            b.ingested_at.isoformat(),
            str(b.open.amount),
            str(b.high.amount),
            str(b.low.amount),
            str(b.close.amount),
            b.currency,
            b.volume,
            b.foreign_buy,
            b.foreign_sell,
            b.adjustment_type.value,
            b.source_provider.value,
        )

    @staticmethod
    def _from_row(row: dict[str, object]) -> Bar:
        currency = Currency(str(row["currency"]))
        return Bar(
            ticker=Ticker(str(row["ticker"])),
            period_end=date.fromisoformat(str(row["period_end"])),
            filing_date=date.fromisoformat(str(row["filing_date"])),
            ingested_at=datetime.fromisoformat(str(row["ingested_at"])),
            open=Money(Decimal(str(row["open_amount"])), currency),
            high=Money(Decimal(str(row["high_amount"])), currency),
            low=Money(Decimal(str(row["low_amount"])), currency),
            close=Money(Decimal(str(row["close_amount"])), currency),
            volume=int(str(row["volume"])),
            foreign_buy=int(str(row["foreign_buy"])),
            foreign_sell=int(str(row["foreign_sell"])),
            adjustment_type=AdjustmentType(str(row["adjustment_type"])),
            source_provider=SourceProvider(str(row["source_provider"])),
            bar_id=BarId(str(row["bar_id"])),
        )
