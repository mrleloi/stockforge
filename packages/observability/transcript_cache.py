"""TranscriptCache — generic file-content cache with mtime+size dual-check + LRU.

Source: Claude-Code-Agent-Monitor/server/lib/transcript-cache.js (caching mechanic only).
Token-extraction specifics from the original are out-of-scope for memory extraction; this
port parameterizes the parser callable so consumers (extract_l0, future telemetry) plug
their own logic.

Public API:
    TranscriptCache(parser, max_entries=200) where parser: Callable[[str], T | None]
        .extract(path) -> T | None
        .invalidate(path) -> None
        .clear() -> None
        .stats() -> dict
        .size -> int  (property)

Cache hit policy:
    - Hit when mtime + size both match cached values; returns cached result
    - File shrunk OR first-read → full parse via parser(content)
    - File grew → incremental: read bytes [bytesRead .. size], parse, parser must
      tolerate appended chunk (consumer's responsibility); cache merges via parser-controlled
      append (parser receives the FULL accumulated content on grow paths to keep the API
      simple for Phase 0 — mirrors `_fullRead` for "same size, different mtime" branch)
    - Same size, different mtime → full re-read (file rewritten / compacted)

LRU eviction at max_entries via OrderedDict move-to-end.
"""

from __future__ import annotations

import os
from collections import OrderedDict
from collections.abc import Callable
from typing import Generic, TypeVar

T = TypeVar("T")

MAX_CACHE_ENTRIES = 200


class TranscriptCache(Generic[T]):
    """File-keyed result cache with mtime+size invalidation and LRU eviction.

    Parameters
    ----------
    parser : Callable[[str], T | None]
        Function called with full file content (utf-8) on every miss / re-read.
        Should return parsed result or None if no signal extractable.
    max_entries : int
        LRU capacity. Default matches the JS source.
    """

    def __init__(
        self,
        parser: Callable[[str], T | None],
        max_entries: int = MAX_CACHE_ENTRIES,
    ) -> None:
        self._parser = parser
        self._max_entries = max_entries
        self._cache: OrderedDict[str, dict[str, object]] = OrderedDict()

    def extract(self, transcript_path: str) -> T | None:
        if not transcript_path:
            return None
        try:
            stat = os.stat(transcript_path)
        except OSError:
            return None

        key = transcript_path
        cached = self._cache.get(key)
        size = stat.st_size
        mtime = stat.st_mtime_ns  # high-precision; Python equivalent of mtimeMs

        # Cache hit: file unchanged.
        if cached is not None and cached["mtimeMs"] == mtime and cached["size"] == size:
            self._cache.move_to_end(key)
            return cached["result"]  # type: ignore[return-value]

        # File shrunk or first read → full re-read.
        bytes_read = int(cached["bytesRead"]) if cached is not None else 0
        if cached is None or size < bytes_read:
            result = self._full_read(transcript_path)
            self._set(
                key,
                {
                    "mtimeMs": mtime,
                    "size": size,
                    "bytesRead": size,
                    "result": result,
                },
            )
            return result

        # File grew → re-parse on full content (Phase 0 simplification: consumer's
        # incremental-merge logic varies; full re-read keeps semantics correct at the
        # cost of one extra file read on append. Token-extraction-style merge can be
        # added later if profiling justifies it).
        if size > bytes_read:
            result = self._full_read(transcript_path)
            self._set(
                key,
                {
                    "mtimeMs": mtime,
                    "size": size,
                    "bytesRead": size,
                    "result": result,
                },
            )
            return result

        # Same size, different mtime → content rewritten (compaction). Full re-read.
        result = self._full_read(transcript_path)
        self._set(
            key,
            {
                "mtimeMs": mtime,
                "size": size,
                "bytesRead": size,
                "result": result,
            },
        )
        return result

    def _full_read(self, path: str) -> T | None:
        try:
            with open(path, encoding="utf-8") as f:
                content = f.read()
        except OSError:
            return None
        return self._parser(content)

    def _set(self, key: str, entry: dict[str, object]) -> None:
        if key in self._cache:
            self._cache.move_to_end(key)
        self._cache[key] = entry
        while len(self._cache) > self._max_entries:
            self._cache.popitem(last=False)

    def invalidate(self, transcript_path: str) -> None:
        self._cache.pop(transcript_path, None)

    def clear(self) -> None:
        self._cache.clear()

    def stats(self) -> dict[str, object]:
        return {"entries": len(self._cache), "paths": list(self._cache.keys())}

    @property
    def size(self) -> int:
        return len(self._cache)
