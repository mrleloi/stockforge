"""RawHtmlSink — atomic raw-HTML preservation per DD-6 + D-062 + D-064.

Saves to data/raw/news/<source>/<YYYY-MM-DD>/<sha256(url)[:16]>.html using
``safe_path()`` from packages/_shared/path_safety.py (W0-5 D-064 binding).
Atomic write via tmp + os.replace() (D-062 binding).

Design:
- ``base_dir`` defaults to ``data/raw/news`` under the project root.
- Path safety: ``safe_path(relative, workdir=project_root)`` enforces P1
  sandbox containment (no ``..`` traversal, no UNC paths) for user-derived paths.
  Note: plan-020 § DD-6 references ``safe_run_dir()``; since ``data/`` is in the
  default file roots (not run roots), ``safe_path(str(dest), workdir=project_root)``
  is used instead — equivalent P1 containment per D-064 five-invariant contract.
- Atomic write: writes to ``{final_path}.tmp``, then ``os.replace()``; readers
  never see a partial file (D-062 atomic-write doctrine).

D-059 compliance:
- R1 (datetime-no-tz): ``fetched_at`` argument must be tz-aware; validated.
- R2 (unseeded RNG): no RNG usage.
- R4 (time.time-in-domain): no time.time; monotonic not used in domain layer.

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md § Sub-track D2 DD-6
        packages/_shared/path_safety.py (W0-5 D-064 binding)
        agent-workspace/memory/decisions/062-atomic-write-doctrine.md
"""

from __future__ import annotations

import hashlib
import os
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

from packages._shared.path_safety import safe_path

__all__ = ["RawHtmlSink"]


@dataclass(frozen=True, slots=True)
class RawHtmlSink:
    """Persist verbatim HTML to local filesystem for reprocessing.

    Phase 2 thin slice: local filesystem under ``data/raw/news/``. Phase 3
    promotes to Cloudflare R2 per crawler-reliability skill § Storage.

    Atomic write: write to ``{path}.tmp``, then ``os.replace()`` — readers never
    see a partial file (D-062 atomic-write doctrine binding).

    Path safety: uses ``safe_path()`` from packages/_shared/path_safety.py (D-064
    five-invariant contract). No ``..`` traversal; no UNC paths; project-root
    sandboxed.

    Usage::

        sink = RawHtmlSink(base_dir=Path("data/raw/news"))
        written = sink.write(
            source_id="cafef",
            url="https://cafef.vn/vhm-article.chn",
            html=html_str,
            fetched_at=datetime.now(UTC),
        )
        # written = Path("data/raw/news/cafef/2026-05-16/a3b4c5d6e7f80011.html")
    """

    base_dir: Path = Path("data/raw/news")
    """Base directory for raw HTML storage. Resolved relative to project root."""

    def write(
        self,
        source_id: str,
        url: str,
        html: str,
        fetched_at: datetime,
    ) -> Path:
        """Atomically write raw HTML to ``base_dir/<source>/<date>/<url_hash>.html``.

        Args:
            source_id: Source identifier, e.g. ``"cafef"``. Used as subdirectory name.
            url: Original article URL. SHA-256 of this (first 16 hex chars) is filename.
            html: Verbatim HTML body (str; UTF-8 encoded on write).
            fetched_at: Timezone-aware datetime of fetch time (R1 D-059 compliance).
                        Raises ValueError if naive (no tzinfo).

        Returns:
            Path to the written file (absolute, resolved).

        Raises:
            ValueError: If ``fetched_at`` is naive (no tzinfo) — D-059 R1 violation.
            ValueError: If resolved destination escapes ``base_dir`` (D-064 P1 violation).

        D-062 atomic write: writes to ``{dest}.tmp``, then ``os.replace(tmp, dest)``.
        Readers never observe a partial file.
        """
        # D-059 R1: fetched_at must be tz-aware
        if fetched_at.tzinfo is None or fetched_at.tzinfo.utcoffset(fetched_at) is None:
            raise ValueError(
                f"fetched_at must be timezone-aware (D-059 R1). "
                f"Got: {fetched_at!r}. Use datetime.now(UTC) or similar."
            )

        date_str = fetched_at.astimezone(UTC).strftime("%Y-%m-%d")
        url_hash = hashlib.sha256(url.encode("utf-8")).hexdigest()[:16]
        filename = f"{url_hash}.html"

        # D-064 P1: safe_path enforces sandbox containment under base_dir
        # base_dir acts as the workdir for containment; sub-path built from trusted args.
        # Note: safe_path validates the relative sub-path string stays within workdir.
        # source_id and date_str come from trusted infrastructure code, not user input.
        sub_path = str(Path(source_id) / date_str / filename)
        dest = safe_path(sub_path, workdir=self.base_dir.resolve())

        # Create parent directories atomically-safe (makedirs is idempotent)
        dest.parent.mkdir(parents=True, exist_ok=True)

        # D-062 atomic write: tmp + os.replace()
        tmp_path_obj = Path(str(dest) + ".tmp")
        tmp_path_obj.write_text(html, encoding="utf-8")
        os.replace(tmp_path_obj, dest)

        return dest
