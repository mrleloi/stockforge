"""SqliteFundamentalRepository — local SQLite FinancialStatement persistence.

Phase 2 thin slice substrate. TimescaleDB hypertable + retention policies
deferred to Phase 3 per spec-T1-001 § B.1 + master-plan 005 § S34.

Storage layout: one row per (ticker, statement_type, period_end,
source_provider) so multi-source provenance is preserved on disk.
`line_items` serialized as JSON with amounts as strings (Decimal precision).

Implements `FundamentalRepository` Protocol. Idempotent via ON CONFLICT
REPLACE so repeated CLI runs converge on the same on-disk state.
"""

from __future__ import annotations

import json
import sqlite3
from collections.abc import Iterable
from contextlib import closing
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

from packages.contracts import Currency, Money, SourceProvider, Ticker
from packages.domain.fundamental.models import FinancialStatement
from packages.domain.fundamental.value_objects import StatementType

__all__ = ["SqliteFundamentalRepository"]


_SCHEMA = """
CREATE TABLE IF NOT EXISTS financial_statements (
    ticker          TEXT NOT NULL,
    statement_type  TEXT NOT NULL,
    period_end      TEXT NOT NULL,
    filing_date     TEXT NOT NULL,
    ingested_at     TEXT NOT NULL,
    line_items_json TEXT NOT NULL,
    currency        TEXT NOT NULL,
    source_provider TEXT NOT NULL,
    sector          TEXT,
    restated_at     TEXT,
    fiscal_period_label TEXT NOT NULL DEFAULT '',
    PRIMARY KEY(ticker, statement_type, period_end, source_provider)
);
CREATE INDEX IF NOT EXISTS idx_fund_ticker_period ON financial_statements(ticker, period_end);
CREATE INDEX IF NOT EXISTS idx_fund_filing ON financial_statements(filing_date);
"""


@dataclass
class SqliteFundamentalRepository:
    """SQLite-backed FinancialStatement persistence. Implements
    `FundamentalRepository` Protocol.
    """

    db_path: Path

    def __post_init__(self) -> None:
        self.db_path = Path(self.db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executescript(_SCHEMA)
            conn.commit()

    def save_many(self, statements: Iterable[FinancialStatement]) -> int:
        rows = [self._to_row(s) for s in statements]
        if not rows:
            return 0
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.executemany(
                """
                INSERT OR REPLACE INTO financial_statements (
                    ticker, statement_type, period_end, filing_date, ingested_at,
                    line_items_json, currency, source_provider, sector, restated_at,
                    fiscal_period_label
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                rows,
            )
            conn.commit()
        return len(rows)

    def save_many_by_ticker(
        self, statements_by_ticker: dict[Ticker, list[FinancialStatement]]
    ) -> dict[Ticker, int]:
        """Mirror SqliteBarRepository.save_many_by_ticker — per-ticker
        transaction isolation; partial failure tolerance per Q-S28-3 doctrine.
        """
        out: dict[Ticker, int] = {}
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            for ticker, statements in statements_by_ticker.items():
                rows = [self._to_row(s) for s in statements]
                if not rows:
                    out[ticker] = 0
                    continue
                try:
                    conn.executemany(
                        """
                        INSERT OR REPLACE INTO financial_statements (
                            ticker, statement_type, period_end, filing_date, ingested_at,
                            line_items_json, currency, source_provider, sector, restated_at,
                            fiscal_period_label
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        rows,
                    )
                    conn.commit()
                    out[ticker] = len(rows)
                except sqlite3.Error:
                    conn.rollback()
                    out[ticker] = 0
        return out

    def get_as_of(
        self,
        ticker: Ticker,
        as_of_date: date,
        statement_type: StatementType | None = None,
    ) -> list[FinancialStatement]:
        if statement_type is None:
            sql = """
                SELECT * FROM financial_statements
                WHERE ticker = ?
                  AND period_end <= ?
                  AND filing_date <= ?
                ORDER BY period_end ASC, statement_type ASC
            """
            params: tuple[object, ...] = (
                ticker.symbol, as_of_date.isoformat(), as_of_date.isoformat(),
            )
        else:
            sql = """
                SELECT * FROM financial_statements
                WHERE ticker = ?
                  AND statement_type = ?
                  AND period_end <= ?
                  AND filing_date <= ?
                ORDER BY period_end ASC
            """
            params = (
                ticker.symbol, statement_type.value,
                as_of_date.isoformat(), as_of_date.isoformat(),
            )
        return self._query(sql, params)

    def get_latest(self, ticker: Ticker) -> FinancialStatement | None:
        rows = self._query(
            "SELECT * FROM financial_statements WHERE ticker = ? "
            "ORDER BY period_end DESC, filing_date DESC LIMIT 1",
            (ticker.symbol,),
        )
        return rows[0] if rows else None

    def count(self) -> int:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            cur = conn.execute("SELECT COUNT(*) FROM financial_statements")
            return int(cur.fetchone()[0])

    def count_for(self, ticker: Ticker) -> int:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            cur = conn.execute(
                "SELECT COUNT(*) FROM financial_statements WHERE ticker = ?",
                (ticker.symbol,),
            )
            return int(cur.fetchone()[0])

    def _query(self, sql: str, params: tuple[object, ...]) -> list[FinancialStatement]:
        with closing(sqlite3.connect(str(self.db_path))) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(sql, params)
            return [self._from_row(dict(r)) for r in cur.fetchall()]

    @staticmethod
    def _to_row(s: FinancialStatement) -> tuple[object, ...]:
        line_items_json = json.dumps(
            {k: str(v.amount) for k, v in s.line_items.items()},
            ensure_ascii=False,
        )
        return (
            s.ticker.symbol,
            s.statement_type.value,
            s.period_end.isoformat(),
            s.filing_date.isoformat(),
            s.ingested_at.isoformat(),
            line_items_json,
            s.currency.value,
            s.source_provider.value,
            s.sector,
            s.restated_at.isoformat() if s.restated_at is not None else None,
            s.fiscal_period_label,
        )

    @staticmethod
    def _from_row(row: dict[str, object]) -> FinancialStatement:
        currency = Currency(str(row["currency"]))
        raw_items = json.loads(str(row["line_items_json"]))
        line_items = {k: Money(Decimal(str(v)), currency) for k, v in raw_items.items()}
        restated_raw = row.get("restated_at")
        return FinancialStatement(
            ticker=Ticker(str(row["ticker"])),
            statement_type=StatementType(str(row["statement_type"])),
            period_end=date.fromisoformat(str(row["period_end"])),
            filing_date=date.fromisoformat(str(row["filing_date"])),
            ingested_at=datetime.fromisoformat(str(row["ingested_at"])),
            line_items=line_items,
            source_provider=SourceProvider(str(row["source_provider"])),
            sector=str(row["sector"]) if row.get("sector") is not None else None,
            restated_at=datetime.fromisoformat(str(restated_raw)) if restated_raw else None,
            fiscal_period_label=str(row.get("fiscal_period_label") or ""),
        )
