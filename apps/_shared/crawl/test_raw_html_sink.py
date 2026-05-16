"""Tests for RawHtmlSink (plan 020 DC-D2-3).

Covers (≥6 per spec):
1. Writes to expected path under data/raw/news/<source>/<date>/<hash>.html
2. Sub-dirs created automatically.
3. Atomic write (verify .tmp file disappears on success).
4. Unicode HTML round-trips correctly.
5. sha256 hash truncation matches existing cafef_scraper.py:212 (16 chars).
6. Naive datetime raises ValueError (D-059 R1).
"""

from __future__ import annotations

import hashlib
from datetime import UTC, datetime
from pathlib import Path

import pytest

from apps._shared.crawl.raw_html_sink import RawHtmlSink

_FETCHED_AT = datetime(2026, 5, 16, 8, 30, tzinfo=UTC)
_SOURCE_ID = "cafef"
_URL = "https://cafef.vn/vhm-q1-2026.chn"
_SAMPLE_HTML = "<html><body><h1>VHM Q1 2026</h1><p>Lãi 5000 tỷ</p></body></html>"


def _url_hash(url: str) -> str:
    return hashlib.sha256(url.encode("utf-8")).hexdigest()[:16]


def test_raw_html_sink_writes_to_correct_path(tmp_path: Path) -> None:
    """Written file lands at <base_dir>/<source>/<date>/<hash>.html."""
    sink = RawHtmlSink(base_dir=tmp_path / "raw")
    written = sink.write(
        source_id=_SOURCE_ID,
        url=_URL,
        html=_SAMPLE_HTML,
        fetched_at=_FETCHED_AT,
    )
    expected_hash = _url_hash(_URL)
    expected = tmp_path / "raw" / "cafef" / "2026-05-16" / f"{expected_hash}.html"
    assert written == expected
    assert written.exists()


def test_raw_html_sink_creates_subdirs(tmp_path: Path) -> None:
    """Parent directories are created automatically."""
    sink = RawHtmlSink(base_dir=tmp_path / "deep" / "nested" / "raw")
    written = sink.write(
        source_id=_SOURCE_ID,
        url=_URL,
        html=_SAMPLE_HTML,
        fetched_at=_FETCHED_AT,
    )
    assert written.exists()
    assert written.parent.is_dir()


def test_raw_html_sink_atomic_write_no_tmp_file_remains(tmp_path: Path) -> None:
    """After a successful write, the .tmp file is removed (atomic replace)."""
    sink = RawHtmlSink(base_dir=tmp_path / "raw")
    written = sink.write(
        source_id=_SOURCE_ID,
        url=_URL,
        html=_SAMPLE_HTML,
        fetched_at=_FETCHED_AT,
    )
    tmp_file = Path(str(written) + ".tmp")
    assert not tmp_file.exists()  # .tmp cleaned up by os.replace()
    assert written.exists()


def test_raw_html_sink_unicode_roundtrip(tmp_path: Path) -> None:
    """Vietnamese + emoji unicode HTML round-trips correctly (UTF-8 encoding)."""
    unicode_html = "<html><p>Vinhomes tăng trưởng 20% 🚀</p></html>"
    sink = RawHtmlSink(base_dir=tmp_path / "raw")
    written = sink.write(
        source_id=_SOURCE_ID,
        url=_URL,
        html=unicode_html,
        fetched_at=_FETCHED_AT,
    )
    content = written.read_text(encoding="utf-8")
    assert content == unicode_html


def test_raw_html_sink_sha256_hash_matches_cafef_scraper_convention(tmp_path: Path) -> None:
    """Filename hash (sha256[:16]) matches the same convention in cafef_scraper.py:212."""
    sink = RawHtmlSink(base_dir=tmp_path / "raw")
    written = sink.write(
        source_id=_SOURCE_ID,
        url=_URL,
        html=_SAMPLE_HTML,
        fetched_at=_FETCHED_AT,
    )
    expected_name = _url_hash(_URL) + ".html"
    assert written.name == expected_name
    assert len(written.stem) == 16  # exactly 16 hex chars


def test_raw_html_sink_naive_datetime_raises_value_error(tmp_path: Path) -> None:
    """Naive fetched_at (no tzinfo) raises ValueError per D-059 R1."""
    sink = RawHtmlSink(base_dir=tmp_path / "raw")
    naive_dt = datetime(2026, 5, 16, 8, 30)  # no tzinfo — D-059 R1 violation
    with pytest.raises(ValueError, match="timezone-aware"):
        sink.write(
            source_id=_SOURCE_ID,
            url=_URL,
            html=_SAMPLE_HTML,
            fetched_at=naive_dt,
        )


def test_raw_html_sink_date_from_fetched_at(tmp_path: Path) -> None:
    """The date in the file path comes from fetched_at (UTC)."""
    fetched_at = datetime(2026, 1, 31, 23, 59, tzinfo=UTC)
    sink = RawHtmlSink(base_dir=tmp_path / "raw")
    written = sink.write(
        source_id=_SOURCE_ID,
        url=_URL,
        html=_SAMPLE_HTML,
        fetched_at=fetched_at,
    )
    assert written.parent.name == "2026-01-31"


def test_raw_html_sink_content_written_correctly(tmp_path: Path) -> None:
    """Written file content matches the html argument."""
    sink = RawHtmlSink(base_dir=tmp_path / "raw")
    written = sink.write(
        source_id=_SOURCE_ID,
        url=_URL,
        html=_SAMPLE_HTML,
        fetched_at=_FETCHED_AT,
    )
    content = written.read_text(encoding="utf-8")
    assert content == _SAMPLE_HTML
