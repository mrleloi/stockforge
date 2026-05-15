"""Tests for path_safety.py — 5 invariants (P1-P5) with ≥3 cases each.

Mirrors Vibe-Trading agent/tests/test_path_safety.py:1-136 (MIT, 2026)
adapted for StockForge path layout and 5-invariant framing.

Test surface:
    P1 (Sandbox): safe_path(p, workdir) containment
    P1b (Absolute): absolute-path literals in domain layer (tested via regex in hook; unit test covers ValueError)
    P2 (User-supplied): safe_user_path(p) root validation
    P3 (Document): safe_document_path(p) root validation
    P4 (Run-dir): safe_run_dir(p) run root validation
    P5 (UNC): _rejects_unc(p) cross-cutting guard — called by all 4 public helpers

Source: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
ADR: agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md
"""
from pathlib import Path

import pytest

from packages._shared.path_safety import (
    _ALLOWED_FILE_ROOTS_ENV,
    _ALLOWED_RUN_ROOTS_ENV,
    _rejects_unc,
    safe_document_path,
    safe_path,
    safe_run_dir,
    safe_user_path,
)

# ============================================================
# P5 — UNC reject (cross-cutting 5th invariant)
# Tests: _rejects_unc directly + via public helpers
# ============================================================

class TestP5UNCReject:
    """P5 cross-cutting invariant: UNC paths rejected by all helpers."""

    def test_p5_rejects_windows_unc(self) -> None:
        """P5: Windows UNC \\\\server\\share rejected."""
        with pytest.raises(ValueError, match="UNC"):
            _rejects_unc("\\\\server\\share")

    def test_p5_rejects_posix_unc(self) -> None:
        """P5: POSIX UNC //server/share rejected."""
        with pytest.raises(ValueError, match="UNC"):
            _rejects_unc("//server/share/file")

    def test_p5_allows_normal_path(self) -> None:
        """P5: normal relative paths pass the UNC check."""
        _rejects_unc("relative/path/file.txt")  # no exception

    def test_p5_unc_via_safe_path(self, tmp_path: Path) -> None:
        """P5: UNC path raises ValueError when passed to safe_path."""
        with pytest.raises(ValueError, match="UNC"):
            safe_path("\\\\server\\share", tmp_path)

    def test_p5_unc_via_safe_user_path(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P5: UNC path raises ValueError when passed to safe_user_path."""
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(tmp_path))
        with pytest.raises(ValueError, match="UNC"):
            safe_user_path("//server/share/file.csv")

    def test_p5_unc_via_safe_run_dir(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P5: UNC path raises ValueError when passed to safe_run_dir."""
        monkeypatch.setenv(_ALLOWED_RUN_ROOTS_ENV, str(tmp_path))
        with pytest.raises(ValueError, match="UNC"):
            safe_run_dir("\\\\server\\share\\runs")


# ============================================================
# P1 — Sandbox containment: safe_path(p, workdir)
# ============================================================

class TestP1Sandbox:
    """P1 invariant: path must resolve inside workdir."""

    def test_p1_allows_relative_inside(self, tmp_path: Path) -> None:
        """P1: relative path inside workdir is allowed."""
        target = tmp_path / "subdir" / "file.txt"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text("content")
        result = safe_path("subdir/file.txt", tmp_path)
        assert result == target.resolve()

    def test_p1_rejects_dotdot_escape(self, tmp_path: Path) -> None:
        """P1: ../.. traversal that escapes workdir is rejected."""
        with pytest.raises(ValueError, match="escapes workspace"):
            safe_path("../../etc/passwd", tmp_path)

    def test_p1_rejects_absolute_path_outside(self, tmp_path: Path) -> None:
        """P1: absolute path outside workdir is rejected."""
        with pytest.raises(ValueError):
            safe_path("/etc/passwd", tmp_path)

    def test_p1_allows_nested_relative(self, tmp_path: Path) -> None:
        """P1: deeply nested relative path inside workdir is allowed."""
        deep = tmp_path / "a" / "b" / "c"
        deep.mkdir(parents=True, exist_ok=True)
        result = safe_path("a/b/c", tmp_path)
        assert result == deep.resolve()

    def test_p1_unc_rejected_before_root_check(self, tmp_path: Path) -> None:
        """P1: UNC path raises ValueError (P5 fires before P1 containment check)."""
        with pytest.raises(ValueError, match="UNC"):
            safe_path("\\\\server\\share", tmp_path)


# ============================================================
# P2 — User-supplied path: safe_user_path(p)
# ============================================================

class TestP2UserPath:
    """P2 invariant: user-supplied broker/export paths scoped to import roots."""

    def test_p2_allows_path_inside_configured_root(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P2: path inside STOCKFORGE_ALLOWED_FILE_ROOTS is allowed."""
        root = tmp_path / "uploads"
        root.mkdir()
        target = root / "import.csv"
        target.write_text("data")
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(root))
        result = safe_user_path(str(target))
        assert result == target.resolve()

    def test_p2_rejects_path_outside_all_roots(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P2: path outside all allowed roots raises ValueError."""
        root = tmp_path / "allowed"
        root.mkdir()
        outside = tmp_path / "forbidden" / "file.csv"
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(root))
        with pytest.raises(ValueError, match="outside allowed"):
            safe_user_path(str(outside))

    def test_p2_unc_rejected(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P2: UNC path raises ValueError via P5 guard."""
        root = tmp_path / "uploads"
        root.mkdir()
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(root))
        with pytest.raises(ValueError, match="UNC"):
            safe_user_path("//server/share/file.csv")

    def test_p2_allows_multiple_roots(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P2: path inside any of multiple configured roots is allowed."""
        root1 = tmp_path / "root1"
        root2 = tmp_path / "root2"
        root1.mkdir()
        root2.mkdir()
        target = root2 / "data.tsv"
        target.write_text("data")
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, f"{root1},{root2}")
        result = safe_user_path(str(target))
        assert result == target.resolve()


# ============================================================
# P3 — Document-reader path: safe_document_path(p)
# ============================================================

class TestP3DocumentPath:
    """P3 invariant: document-reader paths scoped to import roots (same as P2)."""

    def test_p3_allows_path_inside_configured_root(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P3: path inside STOCKFORGE_ALLOWED_FILE_ROOTS is allowed for document reads."""
        root = tmp_path / "docs"
        root.mkdir()
        target = root / "report.pdf"
        target.write_bytes(b"%PDF-1.4")
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(root))
        result = safe_document_path(str(target))
        assert result == target.resolve()

    def test_p3_rejects_path_outside_roots(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P3: document path outside allowed roots raises ValueError."""
        root = tmp_path / "allowed"
        root.mkdir()
        outside = tmp_path / "forbidden.md"
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(root))
        with pytest.raises(ValueError, match="outside allowed"):
            safe_document_path(str(outside))

    def test_p3_unc_rejected(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P3: UNC document path raises ValueError via P5 guard."""
        root = tmp_path / "docs"
        root.mkdir()
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(root))
        with pytest.raises(ValueError, match="UNC"):
            safe_document_path("//server/share/document.pdf")

    def test_p3_distinct_from_p2(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P3: safe_document_path is distinct from safe_user_path (separate call-site intent)."""
        root = tmp_path / "imports"
        root.mkdir()
        target = root / "analysis.md"
        target.write_text("analysis")
        monkeypatch.setenv(_ALLOWED_FILE_ROOTS_ENV, str(root))
        # Both should work — same root boundary, different intent label
        p2_result = safe_user_path(str(target))
        p3_result = safe_document_path(str(target))
        assert p2_result == p3_result


# ============================================================
# P4 — Run-dir validation: safe_run_dir(p)
# ============================================================

class TestP4RunDir:
    """P4 invariant: generated-code / backtest run directories scoped to run roots."""

    def test_p4_allows_path_inside_configured_run_root(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P4: run_dir inside STOCKFORGE_ALLOWED_RUN_ROOTS is allowed."""
        run_root = tmp_path / "runs"
        run_root.mkdir()
        run_dir = run_root / "backtest_20260515"
        run_dir.mkdir()
        monkeypatch.setenv(_ALLOWED_RUN_ROOTS_ENV, str(run_root))
        result = safe_run_dir(str(run_dir))
        assert result == run_dir.resolve()

    def test_p4_rejects_path_outside_run_roots(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P4: run_dir outside all allowed run roots raises ValueError."""
        run_root = tmp_path / "allowed_runs"
        run_root.mkdir()
        outside = tmp_path / "forbidden_run"
        monkeypatch.setenv(_ALLOWED_RUN_ROOTS_ENV, str(run_root))
        with pytest.raises(ValueError, match="outside allowed"):
            safe_run_dir(str(outside))

    def test_p4_unc_rejected(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P4: UNC run_dir raises ValueError via P5 guard."""
        run_root = tmp_path / "runs"
        run_root.mkdir()
        monkeypatch.setenv(_ALLOWED_RUN_ROOTS_ENV, str(run_root))
        with pytest.raises(ValueError, match="UNC"):
            safe_run_dir("\\\\server\\share\\runs")

    def test_p4_allows_multiple_run_roots(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """P4: run_dir inside any of multiple configured run roots is allowed."""
        run_root1 = tmp_path / "runs1"
        run_root2 = tmp_path / "runs2"
        run_root1.mkdir()
        run_root2.mkdir()
        run_dir = run_root2 / "backtest_2026"
        run_dir.mkdir()
        monkeypatch.setenv(_ALLOWED_RUN_ROOTS_ENV, f"{run_root1},{run_root2}")
        result = safe_run_dir(str(run_dir))
        assert result == run_dir.resolve()
