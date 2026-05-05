"""Test TranscriptCache — mtime+size dual-check + LRU eviction."""

import os
import tempfile
import time
from pathlib import Path

from packages.observability import TranscriptCache


def _write(path: str, content: str) -> None:
    Path(path).write_text(content, encoding="utf-8")


def _identity_parser(text: str) -> str | None:
    return text if text else None


def _line_count_parser(text: str) -> int | None:
    if not text:
        return None
    return len([line for line in text.split("\n") if line])


def test_extract_returns_none_for_missing_file() -> None:
    cache = TranscriptCache(_identity_parser)
    assert cache.extract("/nonexistent/path.jsonl") is None


def test_extract_returns_none_for_empty_path() -> None:
    cache = TranscriptCache(_identity_parser)
    assert cache.extract("") is None


def test_first_read_calls_parser() -> None:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False, encoding="utf-8") as f:
        f.write("alpha\nbeta\ngamma")
        path = f.name
    try:
        cache = TranscriptCache(_line_count_parser)
        assert cache.extract(path) == 3
        assert cache.size == 1
    finally:
        os.unlink(path)


def test_cache_hit_skips_parser() -> None:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False, encoding="utf-8") as f:
        f.write("a\nb\nc")
        path = f.name
    call_count = [0]

    def counting_parser(text: str) -> int:
        call_count[0] += 1
        return len(text)

    try:
        cache = TranscriptCache(counting_parser)
        cache.extract(path)
        cache.extract(path)
        cache.extract(path)
        assert call_count[0] == 1, f"parser called {call_count[0]} times; expected 1"
    finally:
        os.unlink(path)


def test_file_grow_triggers_reread() -> None:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False, encoding="utf-8") as f:
        f.write("a\nb")
        path = f.name
    try:
        cache = TranscriptCache(_line_count_parser)
        assert cache.extract(path) == 2
        time.sleep(0.05)  # ensure mtime delta on filesystems with sub-ms granularity
        with open(path, "a", encoding="utf-8") as f:
            f.write("\nc\nd")
        assert cache.extract(path) == 4
    finally:
        os.unlink(path)


def test_file_shrink_triggers_full_reread() -> None:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False, encoding="utf-8") as f:
        f.write("a\nb\nc\nd")
        path = f.name
    try:
        cache = TranscriptCache(_line_count_parser)
        assert cache.extract(path) == 4
        time.sleep(0.05)
        _write(path, "x")
        assert cache.extract(path) == 1
    finally:
        os.unlink(path)


def test_invalidate_removes_entry() -> None:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False, encoding="utf-8") as f:
        f.write("a")
        path = f.name
    try:
        cache = TranscriptCache(_identity_parser)
        cache.extract(path)
        assert cache.size == 1
        cache.invalidate(path)
        assert cache.size == 0
    finally:
        os.unlink(path)


def test_clear_empties_cache() -> None:
    paths = []
    try:
        for i in range(3):
            with tempfile.NamedTemporaryFile(
                mode="w", suffix=".jsonl", delete=False, encoding="utf-8"
            ) as f:
                f.write(f"file{i}")
                paths.append(f.name)
        cache = TranscriptCache(_identity_parser)
        for p in paths:
            cache.extract(p)
        assert cache.size == 3
        cache.clear()
        assert cache.size == 0
    finally:
        for p in paths:
            os.unlink(p)


def test_lru_eviction_at_max_entries() -> None:
    paths = []
    try:
        for i in range(5):
            with tempfile.NamedTemporaryFile(
                mode="w", suffix=".jsonl", delete=False, encoding="utf-8"
            ) as f:
                f.write(f"file{i}")
                paths.append(f.name)
        cache = TranscriptCache(_identity_parser, max_entries=3)
        for p in paths:
            cache.extract(p)
        assert cache.size == 3
        # First 2 paths should have been evicted.
        stats = cache.stats()
        assert paths[0] not in stats["paths"]
        assert paths[1] not in stats["paths"]
        assert paths[4] in stats["paths"]
    finally:
        for p in paths:
            os.unlink(p)


def test_lru_recency_promotes_on_access() -> None:
    paths = []
    try:
        for i in range(3):
            with tempfile.NamedTemporaryFile(
                mode="w", suffix=".jsonl", delete=False, encoding="utf-8"
            ) as f:
                f.write(f"file{i}")
                paths.append(f.name)
        cache = TranscriptCache(_identity_parser, max_entries=3)
        for p in paths:
            cache.extract(p)
        # Access path[0] to promote it to most-recent.
        cache.extract(paths[0])
        # Add a 4th path → path[1] should be evicted (was least-recent after promotion).
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".jsonl", delete=False, encoding="utf-8"
        ) as f:
            f.write("new")
            paths.append(f.name)
        cache.extract(paths[3])
        stats = cache.stats()
        assert paths[0] in stats["paths"]
        assert paths[1] not in stats["paths"]
        assert paths[3] in stats["paths"]
    finally:
        for p in paths:
            os.unlink(p)
