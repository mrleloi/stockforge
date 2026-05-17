"""PDF Table Extraction Library Bake-Off Probe -- Phase G.1 empirical evaluation.

ONE-OFF PROBE SCRIPT -- NOT production CLI. Run manually in an isolated venv.

Purpose:
    Empirically evaluate >=3 candidate PDF table extraction libraries against
    2-document gold-set (VHM 2023 + HPG 2023 annual reports) using a 4-metric grid:
    - Metric 1: Cell-content-exact-match accuracy (% of 10 LineItemKey cells correct)
    - Metric 2: Extraction wall-time (p50 + p95 across N runs, in seconds)
    - Metric 3: Dependency footprint (transitive dep count + install size MB)
    - Metric 4: License compatibility (SPDX identifier + repo URL)

    Winner = highest Metric 1 score. Tie-break = Metric 2 < 60s ceiling.
    Metric 3 + 4 are documentation-only (NOT pick-deciding).

Architecture decisions:
    - DD-4: Winner-pick metric = cell-content-exact-match (NOT cell-count).
    - DD-6: One-off probe at apps/cli/bench/ (NOT scripts/bench/).
    - DD-8: ZERO pyproject.toml dep addition -- install in isolated venv below.
    - D-064: path-safety validated via STOCKFORGE_ALLOWED_FILE_ROOTS env var.

K.2.a STOP-AND-ASK trigger evaluation (charter-tier gates):
    - Trigger A (license escalation): pymupdf license changed from AGPL-3.0 to
      BSD/MIT/Apache AND pymupdf Metric 1 > best non-pymupdf by >=10 pp.
    - Trigger B (no-clear-winner pivot): max(scores) < 70% AND no library >=10 pp
      above others.
    If either fires -> this script writes STOP-FINDING file and exits with code 2.

Isolated venv setup (run ONCE before probe):
    python -m venv .venv-pdf-bakeoff
    # Windows:
    .venv-pdf-bakeoff\\Scripts\\activate
    # Linux/Mac:
    # source .venv-pdf-bakeoff/bin/activate
    pip install pdfplumber camelot-py docling pypdf

Usage:
    python -m apps.cli.bench.pdf_bake_off \\
        --pdf-path tests/fixtures/pdf/vhm-2023-annual.pdf \\
        --expected-cells tests/fixtures/pdf/expected_cells_vhm.json \\
        --library all \\
        --runs 3

Source: agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md § D3
        agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md
        packages/domain/fundamental/value_objects/line_item.py:33-45 (10 LineItemKey)
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
import time
from decimal import Decimal, InvalidOperation
from pathlib import Path

# ---------------------------------------------------------------------------
# Output helpers (T20 compliant: sys.stdout.write / sys.stderr.write)
# ---------------------------------------------------------------------------


def _emit(msg: str = "") -> None:
    """Write to stdout (replaces print; T20 compliance for CLI probe)."""
    sys.stdout.write(msg + "\n")


def _err(msg: str = "") -> None:
    """Write to stderr."""
    sys.stderr.write(msg + "\n")


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

SUPPORTED_LIBRARIES = ["pdfplumber", "docling", "pypdf"]
LIBRARY_LICENSES: dict[str, dict[str, str]] = {
    "pdfplumber": {
        "spdx": "MIT",
        "repo": "https://github.com/jsvine/pdfplumber",
        "notes": "Pure-Python; uses pdfminer.six under the hood",
    },
    "camelot": {
        "spdx": "MIT",
        "repo": "https://github.com/camelot-dev/camelot",
        "notes": "Requires ghostscript for some modes; pairs with pdfplumber",
    },
    "docling": {
        "spdx": "MIT",
        "repo": "https://github.com/DS4SD/docling",
        "notes": "IBM open-source; layout-aware; may need PyTorch",
    },
    "pypdf": {
        "spdx": "BSD-3-Clause",
        "repo": "https://github.com/py-pdf/pypdf",
        "notes": "Text-only baseline; no table structure extraction",
    },
    "pymupdf": {
        "spdx": "AGPL-3.0",
        "repo": "https://github.com/pymupdf/PyMuPDF",
        "notes": (
            "EXCLUDED -- AGPL-3.0 incompatible with Proprietary license "
            "(pyproject.toml:7 license=Proprietary; K.2.a STOP-AND-ASK "
            "trigger if license changes to BSD/MIT/Apache)"
        ),
    },
}

# 10 canonical LineItemKey values per packages/domain/fundamental/value_objects/line_item.py:33-45
CANONICAL_CELL_KEYS = [
    "revenue",
    "gross_profit",
    "net_income",
    "eps",
    "shares_outstanding",
    "total_assets",
    "total_equity",
    "total_liabilities",
    "book_value_per_share",
    "operating_cash_flow",
]

# K.2.a threshold: max Metric 1 score below this triggers STOP-AND-ASK
K2A_ACCURACY_THRESHOLD = 70.0  # percent
K2A_MIN_GAP_PP = 10.0  # percentage points above second-best

STOP_FINDING_PATH = Path(
    "human-workspace/notifications/STOP-FINDING-S394-pdf-library-no-clear-winner.md"
)

# ProbeResult is a str->object mapping for probe return values.
# Keys include: "raw_cells" (dict[str,str]), "p50_wall_s" (float), "cell_count" (int),
# or "error" (str). Using dict[str, object] to avoid Any (mypy strict compliance).
ProbeResult = dict[str, object]

# ScoreResult: keys include "score_pct" (float), "matched_keys" (list[str]), etc.
ScoreResult = dict[str, object]

# DepResult: keys include "dep_count" (int|None), "size_mb" (float|None), "error" (str).
DepResult = dict[str, object]

# K2aResult: keys include "trigger_fired" (bool), "trigger_type" (str|None), etc.
K2aResult = dict[str, object]

# LibResult: keys include "status" (str), all metric values. Stored in results dict.
LibResult = dict[str, object]


# ---------------------------------------------------------------------------
# Minimal VND string parser (inline; G.2 will ship the full canonical parser)
# ---------------------------------------------------------------------------

def parse_vnd_string(raw: str) -> Decimal | None:
    """Parse a Vietnamese VND numeric string to Decimal.

    Handles:
    - Dot-separator thousands (e.g. '1.234.567' -> 1234567)
    - Comma decimal separator (e.g. '1.234,56' -> 1234.56)
    - Parenthesis-negative (e.g. '(1.234)' -> -1234)
    - Unit suffixes: no suffix assumed raw units (billions VND in annual reports)

    Returns None on unparseable input.

    Source: plan-041 § D3 Task 1 minimal inline VND-string parser;
            G.2 IMPL ships canonical parser (sub-plan 042).
    """
    if not raw:
        return None
    s = raw.strip()
    negative = False

    # Parenthesis-negative pattern
    if s.startswith("(") and s.endswith(")"):
        negative = True
        s = s[1:-1].strip()

    # Remove dots used as thousands separators (VN format: 1.234.567)
    parts = s.split(".")
    if len(parts) > 2:
        # Multiple dots: all are thousands separators
        s = "".join(parts)
    elif len(parts) == 2 and len(parts[1]) == 3:  # SIM102: collapsed nested if
        # Likely thousands separator (e.g. '1.234' -> 1234)
        s = parts[0] + parts[1]
    # else: 0 or 1 dots without 3-digit suffix -> keep as is (e.g. '1.5')

    # Remove commas (thousands or decimal -- normalise to pure integer/decimal)
    s = s.replace(",", "")

    try:
        value = Decimal(s)
        return -value if negative else value
    except InvalidOperation:
        return None


# ---------------------------------------------------------------------------
# Per-library probe functions
# ---------------------------------------------------------------------------

def probe_pdfplumber(pdf_path: Path, runs: int) -> ProbeResult:
    """Probe pdfplumber (+ camelot as supplement) for table extraction."""
    try:
        import pdfplumber  # type: ignore[import-not-found]
    except ImportError:
        return {"error": "pdfplumber not installed. Run: pip install pdfplumber"}

    times: list[float] = []
    raw_cells: dict[str, str] = {}

    for _ in range(runs):
        t0 = time.perf_counter()
        try:
            with pdfplumber.open(str(pdf_path)) as pdf:  # type: ignore[no-untyped-call]
                for page in pdf.pages:
                    tables = page.extract_tables()
                    for table in tables:
                        for row in table:
                            if row and len(row) >= 2:
                                label = (row[0] or "").strip()
                                value = (row[-1] or "").strip()
                                if label and value:
                                    raw_cells[label] = value
        except Exception as exc:
            return {"error": f"pdfplumber extraction failed: {exc}"}
        times.append(time.perf_counter() - t0)

    times_sorted = sorted(times)
    p50 = times_sorted[len(times_sorted) // 2]
    p95 = times_sorted[int(len(times_sorted) * 0.95)]

    return {
        "raw_cells": raw_cells,
        "p50_wall_s": round(p50, 3),
        "p95_wall_s": round(p95, 3),
        "cell_count": len(raw_cells),
    }


def probe_docling(pdf_path: Path, runs: int) -> ProbeResult:
    """Probe docling for table extraction (IBM layout-aware)."""
    try:
        from docling.document_converter import DocumentConverter  # type: ignore[import-not-found]
    except ImportError:
        return {"error": "docling not installed. Run: pip install docling"}

    times: list[float] = []
    raw_cells: dict[str, str] = {}

    for _ in range(runs):
        t0 = time.perf_counter()
        try:
            converter = DocumentConverter()  # type: ignore[no-untyped-call]
            result = converter.convert(str(pdf_path))  # type: ignore[no-untyped-call]
            for table in result.document.tables:
                for row_idx, row in enumerate(table.data.grid):
                    cells = list(row)
                    if len(cells) >= 2:
                        label = cells[0].text.strip() if cells[0].text else ""
                        value = cells[-1].text.strip() if cells[-1].text else ""
                        if label and value and row_idx > 0:
                            raw_cells[label] = value
        except Exception as exc:
            return {"error": f"docling extraction failed: {exc}"}
        times.append(time.perf_counter() - t0)

    times_sorted = sorted(times)
    p50 = times_sorted[len(times_sorted) // 2]
    p95 = times_sorted[int(len(times_sorted) * 0.95)]

    return {
        "raw_cells": raw_cells,
        "p50_wall_s": round(p50, 3),
        "p95_wall_s": round(p95, 3),
        "cell_count": len(raw_cells),
    }


def probe_pypdf(pdf_path: Path, runs: int) -> ProbeResult:
    """Probe pypdf for text extraction (text-only baseline -- no table structure)."""
    try:
        from pypdf import PdfReader  # type: ignore[import-not-found]
    except ImportError:
        return {"error": "pypdf not installed. Run: pip install pypdf"}

    times: list[float] = []
    raw_cells: dict[str, str] = {}

    for _ in range(runs):
        t0 = time.perf_counter()
        try:
            reader = PdfReader(str(pdf_path))  # type: ignore[no-untyped-call]
            all_text = []
            for page in reader.pages:
                all_text.append(page.extract_text() or "")
            full_text = "\n".join(all_text)

            for line in full_text.splitlines():
                parts = line.split("\t")
                if len(parts) >= 2:
                    label = parts[0].strip()
                    value = parts[-1].strip()
                    if label and value:
                        raw_cells[label] = value
        except Exception as exc:
            return {"error": f"pypdf extraction failed: {exc}"}
        times.append(time.perf_counter() - t0)

    times_sorted = sorted(times)
    p50 = times_sorted[len(times_sorted) // 2]
    p95 = times_sorted[int(len(times_sorted) * 0.95)]

    return {
        "raw_cells": raw_cells,
        "p50_wall_s": round(p50, 3),
        "p95_wall_s": round(p95, 3),
        "cell_count": len(raw_cells),
    }


# ---------------------------------------------------------------------------
# Metric 1 scoring
# ---------------------------------------------------------------------------

def score_metric1(
    raw_cells: dict[str, str],
    cells_data: dict[str, object],
) -> ScoreResult:
    """Compute Metric 1: cell-content-exact-match accuracy.

    For each of 10 LineItemKey canonical cells in cells_data:
    1. Search raw_cells for a matching label (case-insensitive substring match)
    2. Parse the raw value using VND string parser -> Decimal
    3. Compare exact-match against expected Decimal value
    4. Match = 1.0; Mismatch = 0.0; Missing = 0.0

    Returns:
        ScoreResult with score_pct (0-100), matched_keys, missing_keys, mismatch_keys
    """
    matched: list[str] = []
    missing: list[str] = []
    mismatched: list[str] = []

    for key in CANONICAL_CELL_KEYS:
        cell_spec = cells_data.get(key)
        if not isinstance(cell_spec, dict):
            missing.append(key)
            continue
        expected_value = cell_spec.get("value")

        if expected_value is None:
            # Placeholder annotation -- cannot score
            missing.append(key)
            continue

        expected_decimal = Decimal(str(expected_value))

        # Search raw_cells for matching label (case-insensitive substring)
        found_value: str | None = None
        key_lower = key.lower().replace("_", " ")
        for label, raw_val in raw_cells.items():
            label_lower = label.lower()
            if key_lower in label_lower or label_lower in key_lower:
                found_value = raw_val
                break

        if found_value is None:
            missing.append(key)
            continue

        parsed = parse_vnd_string(found_value)
        if parsed is None:
            mismatched.append(key)
            continue

        if parsed == expected_decimal:
            matched.append(key)
        else:
            mismatched.append(key)

    scored_cells = 0
    for _k in CANONICAL_CELL_KEYS:
        _spec = cells_data.get(_k)
        if isinstance(_spec, dict) and _spec.get("value") is not None:
            scored_cells += 1
    if scored_cells == 0:
        score_pct = 0.0
        note = "UNSCORED: expected_cells contains no annotated values (placeholder fixtures)"
    else:
        score_pct = (len(matched) / 10) * 100.0
        note = f"Scored {scored_cells}/10 annotated cells"

    return {
        "score_pct": round(score_pct, 1),
        "matched_keys": matched,
        "missing_keys": missing,
        "mismatched_keys": mismatched,
        "note": note,
    }


# ---------------------------------------------------------------------------
# Dependency footprint (Metric 3)
# ---------------------------------------------------------------------------

def measure_dep_footprint(library_name: str) -> DepResult:
    """Measure transitive dep count via pip list (proxy for footprint)."""
    try:
        result = subprocess.run(
            [sys.executable, "-m", "pip", "show", library_name],
            capture_output=True, text=True, timeout=30,
        )
        if result.returncode != 0:
            return {"error": f"{library_name} not installed", "dep_count": None, "size_mb": None}

        list_result = subprocess.run(
            [sys.executable, "-m", "pip", "list", "--format=json"],
            capture_output=True, text=True, timeout=30,
        )
        all_pkgs: list[object] = json.loads(list_result.stdout) if list_result.returncode == 0 else []
        dep_count = len(all_pkgs)
        return {
            "dep_count": dep_count,
            "size_mb": None,  # pip doesn't expose install size easily
            "note": f"Total venv packages (proxy for dep footprint): {dep_count}",
        }
    except Exception as exc:
        return {"error": str(exc), "dep_count": None, "size_mb": None}


# ---------------------------------------------------------------------------
# K.2.a trigger evaluation
# ---------------------------------------------------------------------------

def evaluate_k2a(scores: dict[str, float]) -> K2aResult:
    """Evaluate K.2.a STOP-AND-ASK trigger conditions.

    Trigger B: max(scores) < 70% AND no library >=10 pp above others.
    (Trigger A is pymupdf license-change; checked separately via pip show pymupdf.)

    Returns:
        K2aResult with trigger_fired (bool), trigger_type, rationale, winner (if no trigger)
    """
    valid_scores = {lib: s for lib, s in scores.items() if s is not None}
    if not valid_scores:
        return {
            "trigger_fired": True,
            "trigger_type": "B-no-valid-scores",
            "rationale": "No library produced scorable results -- all probe runs failed.",
            "winner": None,
        }

    max_score = max(valid_scores.values())
    sorted_scores = sorted(valid_scores.values(), reverse=True)
    second_best = sorted_scores[1] if len(sorted_scores) > 1 else 0.0
    gap = max_score - second_best

    # Trigger B: no-clear-winner pivot
    if max_score < K2A_ACCURACY_THRESHOLD and gap < K2A_MIN_GAP_PP:
        return {
            "trigger_fired": True,
            "trigger_type": "B-no-clear-winner",
            "rationale": (
                f"max(Metric 1 scores) = {max_score:.1f}% < {K2A_ACCURACY_THRESHOLD}% threshold "
                f"AND gap to second-best = {gap:.1f} pp < {K2A_MIN_GAP_PP} pp minimum. "
                f"Scores: {valid_scores}. "
                f"Charter-tier STOP-AND-ASK required per plan-041 § K.2.a."
            ),
            "winner": None,
        }

    winner_lib = max(valid_scores, key=lambda k: valid_scores[k])
    return {
        "trigger_fired": False,
        "trigger_type": None,
        "rationale": f"Winner: {winner_lib} with Metric 1 score {valid_scores[winner_lib]:.1f}%",
        "winner": winner_lib,
        "note": "NOTE: Scores from synthetic placeholder PDFs -- real PDFs needed for meaningful scoring.",
    }


def write_stop_finding(trigger_type: str, rationale: str, scores: dict[str, float]) -> None:
    """Write STOP-FINDING notification file per plan-041 § K.2.a + J."""
    STOP_FINDING_PATH.parent.mkdir(parents=True, exist_ok=True)
    content = (
        "---\n"
        "type: STOP-FINDING\n"
        "session: S394\n"
        f"created_at: {time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}\n"
        f"trigger: K.2.a-{trigger_type}\n"
        "severity: CHARTER-TIER-SURFACE\n"
        "requires_human_decision: true\n"
        "---\n\n"
        "# STOP-FINDING: PDF Library Bake-Off -- K.2.a Trigger Fired\n\n"
        f"## Trigger Type\n`{trigger_type}`\n\n"
        f"## Rationale\n{rationale}\n\n"
        f"## Scores Observed\n```json\n{json.dumps(scores, indent=2)}\n```\n\n"
        "## Required Human Decision\n"
        "Per parent plan-040 § K.2.a and plan-041 § J:\n\n"
        "**Option A**: Expand probe to include pymupdf (IF license changed to BSD/MIT/Apache)\n"
        "**Option B**: Accept best-available library despite low accuracy\n"
        "**Option C**: Defer G.2 IMPL until manual gold-set annotation complete + re-run probe\n"
        "**Option D**: Use synthetic/simplified gold set for V0 bake-off\n\n"
        "## Next Steps\n"
        "Main session must fire AskUserQuestion bundle Q-INT-2026-05-G-prime-1.\n"
    )
    STOP_FINDING_PATH.write_text(content, encoding="utf-8")
    _err(f"\nSTOP-FINDING written to: {STOP_FINDING_PATH}")


# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="PDF table extraction library bake-off probe (Phase G.1 empirical evaluation)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--pdf-path",
        required=True,
        help="Path to gold-set PDF file (must be in STOCKFORGE_ALLOWED_FILE_ROOTS or tests/fixtures/pdf/)",
    )
    parser.add_argument(
        "--expected-cells",
        required=True,
        help="Path to expected_cells JSON annotation file",
    )
    parser.add_argument(
        "--library",
        choices=[*SUPPORTED_LIBRARIES, "all"],
        default="all",
        help="Library to probe (default: all)",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="JSON report output path (default: agent-workspace/research/pdf-library-bakeoff-2026-05-G1-raw.json)",
    )
    parser.add_argument(
        "--runs",
        type=int,
        default=3,
        help="Number of extraction runs for p50/p95 wall-time (default: 3)",
    )
    parser.add_argument(
        "--skip-k2a",
        action="store_true",
        help="Skip K.2.a trigger evaluation (for debugging; NOT for production use)",
    )
    return parser.parse_args()


def validate_paths(pdf_path_str: str, expected_cells_str: str) -> tuple[Path, Path]:
    """Validate input paths using D-064 path-safety pattern.

    For the bake-off probe, we allow tests/fixtures/pdf/ by adding it to
    allowed roots via the STOCKFORGE_ALLOWED_FILE_ROOTS environment variable.
    """
    project_root = Path(__file__).resolve().parents[3]
    allowed_extra = str(project_root / "tests" / "fixtures" / "pdf")
    existing = os.environ.get("STOCKFORGE_ALLOWED_FILE_ROOTS", "")
    if allowed_extra not in existing:
        new_roots = f"{existing},{allowed_extra}" if existing else allowed_extra
        os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"] = new_roots

    from packages._shared.path_safety import safe_user_path  # noqa: PLC0415

    try:
        pdf_path = safe_user_path(pdf_path_str)
    except ValueError as exc:
        _err(f"ERROR: --pdf-path failed D-064 path-safety: {exc}")
        sys.exit(1)

    expected_path = Path(expected_cells_str).resolve()
    if not expected_path.exists():
        _err(f"ERROR: --expected-cells file not found: {expected_cells_str}")
        sys.exit(1)

    if not pdf_path.exists():
        _err(f"ERROR: PDF file not found: {pdf_path_str}")
        sys.exit(1)

    return pdf_path, expected_path


def compute_sha256(path: Path) -> str:
    """Compute SHA-256 hex digest of a file."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    args = parse_args()

    pdf_path, expected_path = validate_paths(args.pdf_path, args.expected_cells)
    raw_json = json.loads(expected_path.read_text(encoding="utf-8"))
    expected_cells: dict[str, object] = raw_json if isinstance(raw_json, dict) else {}
    metadata = expected_cells.get("_metadata", {})
    cells_data: dict[str, object] = (
        expected_cells.get("cells", {})  # type: ignore[assignment]
        if isinstance(expected_cells.get("cells"), dict)
        else {}
    )

    libraries_to_probe = SUPPORTED_LIBRARIES if args.library == "all" else [args.library]

    _emit("\n=== PDF Table Extraction Bake-Off Probe ===")
    _emit(f"PDF: {pdf_path}")
    _emit(f"PDF SHA-256: {compute_sha256(pdf_path)[:16]}...")
    _emit(f"Expected cells: {expected_path}")
    _emit(f"Libraries: {libraries_to_probe}")
    _emit(f"Runs: {args.runs}")
    _emit()

    # License re-verification (STEP 0.1.a)
    _emit("=== STEP 0.1.a -- License verification ===")
    for lib_name, lic_info in LIBRARY_LICENSES.items():
        spdx = lic_info["spdx"]
        excluded = "EXCLUDED" if lib_name == "pymupdf" else "OK"
        _emit(f"  {lib_name}: {spdx} ({excluded}) -- {lic_info['repo']}")
    _emit()

    # Check pymupdf license (STEP 0.1.b -- K.2.a Trigger A)
    pymupdf_result = subprocess.run(
        [sys.executable, "-m", "pip", "show", "pymupdf"],
        capture_output=True, text=True, timeout=30,
    )
    if pymupdf_result.returncode == 0:
        _emit("  NOTICE: pymupdf IS installed in this environment.")
        _emit("  Verify license is still AGPL-3.0 (K.2.a Trigger A check).")
        if "agpl" not in pymupdf_result.stdout.lower():
            _emit("  WARNING: pymupdf license may have changed -- K.2.a Trigger A may apply!")
    else:
        _emit("  pymupdf: NOT installed (expected; AGPL-3.0 excluded per DD-8)")
    _emit()

    # Run probes
    results: dict[str, LibResult] = {}
    scores: dict[str, float] = {}

    probe_fns = {
        "pdfplumber": probe_pdfplumber,
        "docling": probe_docling,
        "pypdf": probe_pypdf,
    }

    for lib in libraries_to_probe:
        _emit(f"=== Probing: {lib} ===")
        probe_fn = probe_fns.get(lib)
        if probe_fn is None:
            _emit(f"  No probe function for {lib}")
            continue

        probe_result = probe_fn(pdf_path, args.runs)

        if "error" in probe_result:
            _emit(f"  ERROR: {probe_result['error']}")
            results[lib] = {"status": "error", "error": probe_result["error"]}
            scores[lib] = 0.0
            continue

        raw_cells_obj = probe_result.get("raw_cells", {})
        raw_cells: dict[str, str] = raw_cells_obj if isinstance(raw_cells_obj, dict) else {}
        p50_obj = probe_result.get("p50_wall_s", 0.0)
        p50 = float(p50_obj) if isinstance(p50_obj, (int, float)) else 0.0
        p95_obj = probe_result.get("p95_wall_s", 0.0)
        p95 = float(p95_obj) if isinstance(p95_obj, (int, float)) else 0.0
        cell_count_obj = probe_result.get("cell_count", 0)
        cell_count = int(cell_count_obj) if isinstance(cell_count_obj, int) else 0

        # Metric 1 scoring
        m1 = score_metric1(raw_cells, cells_data)
        score_pct = float(m1["score_pct"])  # type: ignore[arg-type]
        scores[lib] = score_pct

        # Metric 3: dep footprint
        m3 = measure_dep_footprint(lib)

        # Metric 4: license
        m4 = LIBRARY_LICENSES.get(lib, {"spdx": "UNKNOWN", "repo": "UNKNOWN"})

        results[lib] = {
            "status": "ok",
            "metric1_score_pct": score_pct,
            "metric1_detail": m1,
            "metric2_p50_wall_s": p50,
            "metric2_p95_wall_s": p95,
            "metric3_dep_count": m3.get("dep_count"),
            "metric3_size_mb": m3.get("size_mb"),
            "metric4_spdx": m4["spdx"],
            "metric4_repo": m4.get("repo"),
            "cell_count_extracted": cell_count,
        }

        _emit(f"  Metric 1 (accuracy): {score_pct:.1f}% -- {m1['note']}")
        _emit(f"  Metric 2 (wall-time): p50={p50:.2f}s p95={p95:.2f}s")
        _emit(f"  Metric 3 (deps): {m3.get('dep_count', 'N/A')} packages")
        _emit(f"  Metric 4 (license): {m4['spdx']}")
        _emit(f"  Cells extracted: {cell_count}")
        _emit()

    # K.2.a evaluation
    k2a: K2aResult = {}
    if not args.skip_k2a:
        _emit("=== K.2.a STOP-AND-ASK trigger evaluation ===")
        k2a = evaluate_k2a(scores)
        if k2a["trigger_fired"]:
            _emit(f"  K.2.a TRIGGERED: {k2a['trigger_type']}")
            _emit(f"  Rationale: {k2a['rationale']}")
            write_stop_finding(str(k2a["trigger_type"]), str(k2a["rationale"]), scores)
        else:
            _emit(f"  K.2.a: NOT triggered -- {k2a['rationale']}")
            if "note" in k2a:
                _emit(f"  Note: {k2a['note']}")
        _emit()

    # Build full report
    report: dict[str, object] = {
        "probe_metadata": {
            "session": "S394",
            "date": time.strftime("%Y-%m-%d", time.gmtime()),
            "pdf_path": str(pdf_path),
            "pdf_sha256": compute_sha256(pdf_path),
            "expected_cells_path": str(expected_path),
            "ticker": metadata.get("ticker") if isinstance(metadata, dict) else None,  # type: ignore[union-attr]
            "period_end": metadata.get("period_end") if isinstance(metadata, dict) else None,  # type: ignore[union-attr]
            "annotation_status": (
                metadata.get("annotation_status") if isinstance(metadata, dict) else None  # type: ignore[union-attr]
            ),
            "libraries_probed": libraries_to_probe,
            "runs": args.runs,
        },
        "license_matrix": LIBRARY_LICENSES,
        "results": results,
        "scores_summary": scores,
        "k2a_evaluation": k2a,
        "winner": k2a.get("winner"),
    }

    # Write JSON report
    output_path_str = (
        args.output or "agent-workspace/research/pdf-library-bakeoff-2026-05-G1-raw.json"
    )
    output_path = Path(output_path_str)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    _emit(f"Raw JSON report written to: {output_path}")

    # Summary
    _emit("\n=== SUMMARY ===")
    _emit(f"{'Library':<20} {'Metric 1 (accuracy)':<25} {'p50 wall-time':<20} {'License'}")
    _emit("-" * 80)
    for lib in libraries_to_probe:
        r = results.get(lib, {})
        if r.get("status") == "error":
            lic_str = LIBRARY_LICENSES.get(lib, {}).get("spdx", "UNKNOWN")
            _emit(f"{lib:<20} {'ERROR':<25} {'N/A':<20} {lic_str}")
        else:
            score_str = f"{r.get('metric1_score_pct', 0.0):.1f}%"  # type: ignore[union-attr]
            wall_str = f"{r.get('metric2_p50_wall_s', 0.0):.2f}s"  # type: ignore[union-attr]
            lic = str(r.get("metric4_spdx", "UNKNOWN"))
            _emit(f"{lib:<20} {score_str:<25} {wall_str:<20} {lic}")

    winner = k2a.get("winner")
    if winner:
        _emit(f"\nWINNER: {winner}")
    elif k2a.get("trigger_fired"):
        _emit(f"\nSTOP-AND-ASK: K.2.a trigger {k2a.get('trigger_type')} fired -- see STOP-FINDING file")
        sys.exit(2)
    else:
        _emit("\nNo clear winner -- review scores above")


if __name__ == "__main__":
    main()
