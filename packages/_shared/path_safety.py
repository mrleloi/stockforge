"""Path safety helpers for StockForge file-access operations.

Implements the 5 path-safety invariants (4 public helpers + 1 cross-cutting UNC guard):

* ``safe_path(p, workdir)`` — sandbox containment (P1). Resolves ``p`` under
  ``workdir`` and rejects any escape. Used by tool calls where the LLM must stay
  inside a designated run directory.

* ``safe_user_path(p)`` — user-supplied broker/export files (P2). Accepts files
  only under explicit import roots, not the whole home directory or project tree.

* ``safe_document_path(p)`` — document-reader inputs (P3). Uses the same
  import-root boundary as ``safe_user_path()``; declared as separate helper for
  call-site intent clarity.

* ``safe_run_dir(p)`` — generated-code / backtest run directories (P4). Resolves
  under designated run roots only.

* ``_rejects_unc(p)`` — cross-cutting UNC path guard (P5). Called as FIRST guard
  in each of the 4 public helpers before any root-containment check.

All public helpers raise ``ValueError`` on rejection.

Attribution
-----------
Pattern adapted from Vibe-Trading (HKUDS/Vibe-Trading, MIT-licensed, 2026).
Upstream: agent/src/tools/path_utils.py (4 public helpers + _rejects_unc cross-cutting guard).
StockForge adaptation: VN-locale + stockforge-layout default roots (agent-workspace/memory/,
outputs/, human-workspace/, etc.); env-var renames; docstrings refreshed to cite 5 invariants.

See ADR: agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md
Plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
"""
# path-safety-ok: internal helper implementation — this file IS the path-safety module

from __future__ import annotations

import os
from pathlib import Path

_ALLOWED_FILE_ROOTS_ENV = "STOCKFORGE_ALLOWED_FILE_ROOTS"
_ALLOWED_RUN_ROOTS_ENV = "STOCKFORGE_ALLOWED_RUN_ROOTS"


def _rejects_unc(p: str) -> None:
    """Raise ValueError if ``p`` starts with a UNC share prefix (P5 cross-cutting guard).

    This is the FIRST guard called by every public helper. Rejects:
    - Windows UNC paths: ``\\\\server\\share`` (starts with ``\\\\``)
    - POSIX UNC-style paths: ``//server/share`` (starts with ``//``)

    Args:
        p: Path string to validate.

    Raises:
        ValueError: If ``p`` starts with a UNC share prefix.

    Source: Vibe-Trading agent/src/tools/path_utils.py:27-30
    """
    if p.startswith("\\\\") or p.startswith("//"):
        raise ValueError(f"UNC paths are not allowed: {p!r}")


def safe_path(p: str, workdir: Path) -> Path:
    """Resolve ``p`` under ``workdir`` and ensure it stays inside (P1 sandbox containment).

    Implements invariant P1: sandbox-relative path containment. The resolved path
    must not escape ``workdir`` via ``..`` traversal, absolute-path override, or
    UNC share prefix.

    Args:
        p: User-supplied path (relative or absolute).
        workdir: Workspace root. ``p`` must resolve to a location inside.

    Returns:
        Absolute resolved path inside ``workdir``.

    Raises:
        ValueError: If ``p`` uses a UNC share (P5), or its resolved form escapes
            ``workdir`` (P1). Callers should surface this back as a tool error.

    Source: Vibe-Trading agent/src/tools/path_utils.py:33-54
    """
    _rejects_unc(p)
    base = Path(workdir).resolve()
    resolved = (base / p).resolve()
    try:
        resolved.relative_to(base)
    except ValueError as exc:
        raise ValueError(f"Path {p!r} escapes workspace {base}") from exc
    return resolved


def _project_root() -> Path:
    """Return the StockForge project root (3 levels up from this file)."""
    return Path(__file__).resolve().parents[2]


def _configured_file_roots() -> list[Path]:
    """Return file roots configured through the environment.

    Reads ``STOCKFORGE_ALLOWED_FILE_ROOTS`` (comma-separated list of paths).
    Each path is UNC-checked before inclusion.
    """
    raw = os.getenv(_ALLOWED_FILE_ROOTS_ENV, "")
    roots: list[Path] = []
    for item in raw.split(","):
        item = item.strip()
        if not item:
            continue
        _rejects_unc(item)
        roots.append(Path(item).expanduser().resolve())
    return roots


def _default_file_roots() -> list[Path]:
    """Return default roots for uploaded/imported user files.

    StockForge-specific layout (differs from Vibe-Trading upstream defaults):
    - ``outputs/`` (project-relative — broker export landing zone)
    - ``data/`` (project-relative — data ingestion zone)
    - ``human-workspace/notifications/`` (agent → human write channel)
    - ``agent-workspace/uploads/`` (if present — future broker uploads)
    """
    project = _project_root()
    cwd = Path.cwd().resolve()
    return [
        project / "outputs",
        project / "data",
        project / "human-workspace" / "notifications",
        project / "agent-workspace" / "uploads",
        cwd / "outputs",
        cwd / "data",
    ]


def _default_run_roots() -> list[Path]:
    """Return default roots for generated backtest/tool run directories.

    StockForge layout:
    - ``outputs/runs/`` (backtest outputs)
    - ``state/runs/`` (stateful run artifacts)
    """
    project = _project_root()
    cwd = Path.cwd().resolve()
    return [
        project / "outputs" / "runs",
        project / "state" / "runs",
        cwd / "outputs" / "runs",
    ]


def _allowed_file_roots() -> list[Path]:
    """Return all roots allowed for document and broker-file reads (deduplicated)."""
    roots: list[Path] = []
    for root in [*_default_file_roots(), *_configured_file_roots()]:
        resolved = root.resolve() if root.exists() else root
        if resolved not in roots:
            roots.append(resolved)
    return roots


def _allowed_run_roots() -> list[Path]:
    """Return all roots allowed for run-dir tools (deduplicated)."""
    raw = os.getenv(_ALLOWED_RUN_ROOTS_ENV, "")
    configured: list[Path] = []
    for item in raw.split(","):
        item = item.strip()
        if not item:
            continue
        _rejects_unc(item)
        configured.append(Path(item).expanduser().resolve())

    roots: list[Path] = []
    for root in [*_default_run_roots(), *configured]:
        resolved = root.resolve() if root.exists() else root
        if resolved not in roots:
            roots.append(resolved)
    return roots


def _safe_import_path(p: str, *, purpose: str) -> Path:
    """Validate a user-supplied path against explicit import roots.

    Args:
        p: User-supplied path. ``~`` expansion is supported.
        purpose: Human-readable purpose for error messages.

    Returns:
        Absolute resolved path inside an allowed import root.

    Raises:
        ValueError: If ``p`` is a UNC share or resolves outside all allowed import roots.

    Source: Vibe-Trading agent/src/tools/path_utils.py:131-155
    """
    _rejects_unc(p)
    resolved = Path(p).expanduser().resolve()

    for root in _allowed_file_roots():
        try:
            resolved.relative_to(root)
            return resolved
        except ValueError:
            continue

    raise ValueError(
        f"Path {p!r} is outside allowed {purpose} roots. "
        f"Set {_ALLOWED_FILE_ROOTS_ENV} to add an import directory."
    )


def safe_user_path(p: str) -> Path:
    """Validate a user-supplied broker/export file path (P2 user-supplied invariant).

    Accepts files only under StockForge import roots (``outputs/``, ``data/``, etc.)
    or roots added via ``STOCKFORGE_ALLOWED_FILE_ROOTS``.

    Args:
        p: User-supplied path. ``~`` expansion is supported.

    Returns:
        Absolute resolved path inside an allowed import root.

    Raises:
        ValueError: If ``p`` is a UNC share (P5) or resolves outside all allowed
            import roots (P2).

    Source: Vibe-Trading agent/src/tools/path_utils.py:158-171
    """
    return _safe_import_path(p, purpose="user-file")


def safe_document_path(p: str) -> Path:
    """Validate a document-reader file path (P3 document-reader invariant).

    Same root boundary as ``safe_user_path()``; declared as separate helper
    for call-site intent clarity (document reads have different UX context than
    user broker imports).

    Args:
        p: User-supplied document path. ``~`` expansion is supported.

    Returns:
        Absolute resolved path inside an allowed import root.

    Raises:
        ValueError: If ``p`` is a UNC share (P5) or resolves outside all allowed
            import roots (P3).

    Source: Vibe-Trading agent/src/tools/path_utils.py:174-187
    """
    return _safe_import_path(p, purpose="document")


def safe_run_dir(p: str) -> Path:
    """Validate a run directory used by generated-code / backtest tools (P4 run-dir invariant).

    Accepts paths only under StockForge run roots (``outputs/runs/``, ``state/runs/``)
    or roots added via ``STOCKFORGE_ALLOWED_RUN_ROOTS``.

    Args:
        p: User/LLM-supplied run directory. ``~`` expansion is supported.

    Returns:
        Absolute resolved path inside an allowed run root.

    Raises:
        ValueError: If ``p`` is a UNC share (P5) or resolves outside all allowed run
            roots (P4).

    Source: Vibe-Trading agent/src/tools/path_utils.py:190-213
    """
    _rejects_unc(p)
    resolved = Path(p).expanduser().resolve()

    for root in _allowed_run_roots():
        try:
            resolved.relative_to(root)
            return resolved
        except ValueError:
            continue

    raise ValueError(
        f"run_dir {p!r} is outside allowed run roots. "
        f"Set {_ALLOWED_RUN_ROOTS_ENV} to add a run directory."
    )
