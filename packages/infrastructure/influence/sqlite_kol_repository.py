"""SqliteKolRepository — SQLite-backed Kol persistence (D-027 § a).

Schema follows spec § B.6 adapted for SQLite (TEXT[] → TEXT json-array).

`secondary_channel_ids` + `sectors_covered` are stored as TEXT json arrays.
Single connection-per-call pattern; the file path may live anywhere on disk.
"""

from __future__ import annotations

import json
import sqlite3
from contextlib import closing
from datetime import datetime
from pathlib import Path

from packages.domain.influence.models.kol import Kol
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.kol_status import KolStatus
from packages.domain.influence.value_objects.kol_style import KolStyle

__all__ = ["SqliteKolRepository"]


_SCHEMA = """
CREATE TABLE IF NOT EXISTS kols (
    kol_id                TEXT PRIMARY KEY,
    name                  TEXT NOT NULL,
    primary_channel_id    TEXT NOT NULL,
    style                 TEXT NOT NULL,
    status                TEXT NOT NULL,
    sectors_covered_json  TEXT NOT NULL DEFAULT '[]',
    secondary_channels_json TEXT NOT NULL DEFAULT '[]',
    profile_summary       TEXT,
    last_active_at        TEXT,
    created_at            TEXT
);
CREATE INDEX IF NOT EXISTS idx_kols_status ON kols(status);
"""


def _isofmt(value: datetime | None) -> str | None:
    return value.isoformat() if value is not None else None


def _isoparse(value: object) -> datetime | None:
    if value in (None, ""):
        return None
    return datetime.fromisoformat(str(value))


class SqliteKolRepository:
    """Concrete SQLite KolRepositoryPort."""

    def __init__(self, db_path: Path) -> None:
        self._db_path = Path(db_path)
        self._init_schema()

    def _init_schema(self) -> None:
        with closing(sqlite3.connect(self._db_path)) as conn:
            conn.executescript(_SCHEMA)
            conn.commit()

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self._db_path)
        conn.row_factory = sqlite3.Row
        return conn

    async def get(self, kol_id: KolId) -> Kol | None:
        with closing(self._connect()) as conn:
            row = conn.execute(
                "SELECT * FROM kols WHERE kol_id = ?", (str(kol_id),)
            ).fetchone()
        return self._row_to_kol(row) if row is not None else None

    async def save(self, kol: Kol) -> None:
        with closing(self._connect()) as conn:
            conn.execute(
                """
                INSERT OR REPLACE INTO kols (
                    kol_id, name, primary_channel_id, style, status,
                    sectors_covered_json, secondary_channels_json,
                    profile_summary, last_active_at, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    str(kol.kol_id),
                    kol.name,
                    str(kol.primary_channel_id),
                    kol.style.value,
                    kol.status.value,
                    json.dumps(list(kol.sectors_covered)),
                    json.dumps([str(c) for c in kol.secondary_channel_ids]),
                    kol.profile_summary,
                    _isofmt(kol.last_active_at),
                    _isofmt(kol.created_at),
                ),
            )
            conn.commit()

    async def list_all(self) -> list[Kol]:
        with closing(self._connect()) as conn:
            rows = conn.execute("SELECT * FROM kols").fetchall()
        return [self._row_to_kol(row) for row in rows]

    @staticmethod
    def _row_to_kol(row: sqlite3.Row) -> Kol:
        secondary = [
            ChannelId(c) for c in json.loads(row["secondary_channels_json"] or "[]")
        ]
        sectors = list(json.loads(row["sectors_covered_json"] or "[]"))
        return Kol(
            kol_id=KolId(row["kol_id"]),
            name=row["name"],
            primary_channel_id=ChannelId(row["primary_channel_id"]),
            style=KolStyle(row["style"]),
            status=KolStatus(row["status"]),
            sectors_covered=sectors,
            secondary_channel_ids=secondary,
            profile_summary=row["profile_summary"],
            last_active_at=_isoparse(row["last_active_at"]),
            created_at=_isoparse(row["created_at"]),
        )
