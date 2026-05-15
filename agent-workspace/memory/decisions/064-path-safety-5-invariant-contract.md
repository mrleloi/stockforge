---
id: D-064-path-safety-5-invariant-contract
title: Path-Safety 5-Invariant Contract
date: 2026-05-15
status: PROPOSED
level: IMPL

author:
  - "Claude Sonnet 4.6 (sandwich-dev S332)"

source_evidence:
  - path: "agent-workspace/memory/observations/master-planner-A-15-deepdive-Vibe-Trading.md § 0"
    quote: "W0-5 path-safety quad — RECONFIRMED in source: 4 public helpers + _rejects_unc cross-cutting = 5 invariants"
  - path: "agent-workspace/memory/decisions/061-wave-1-integration-ratification.md § Decision item 8"
    quote: "W0-5 ratified as 5-invariant (UNC reject cross-cutting) per Q-INT-bis SUPPLEMENT § L/N coverage of UNC"
  - path: "C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:27-30"
    quote: "def _rejects_unc(p: str) -> None: if p.startswith('\\\\') or p.startswith('//'): raise ValueError(f'UNC paths are not allowed: {p!r}')"
  - path: "C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:33-54"
    quote: "def safe_path(p, workdir) — P1 sandbox helper; first calls _rejects_unc(p)"
  - path: "C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:158-171"
    quote: "def safe_user_path(p) — P2 user-supplied helper; calls _safe_import_path"
  - path: "C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:174-187"
    quote: "def safe_document_path(p) — P3 document-reader helper; separate intent from P2"
  - path: "C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:190-213"
    quote: "def safe_run_dir(p) — P4 run-dir helper; resolves under allowed run roots"
  - path: "C:/htdocs/research/Vibe-Trading/agent/tests/test_path_safety.py:1-136"
    quote: "Full test surface for 4 helpers + UNC guard — 5-invariant coverage precedent"
  - path: "agent-workspace/memory/decisions/059-python-determinism-contract.md"
    quote: "Hook + firing-test + ADR triad pattern (W0-2 predecessor template)"
  - path: "agent-workspace/constitution/architecture.md"
    quote: "BC layer boundaries: domain = strictest (ZERO framework dependency), infrastructure = concrete implementations"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 40

options_considered:
  - id: A
    summary: "5 invariants via bash hook + Python helper module (4 helpers + UNC guard)"
    pros:
      - "Deterministic detection of all 5 invariants"
      - "Fix recipe ships alongside detector (packages/_shared/path_safety.py)"
      - "Directly ported from Vibe-Trading (MIT) with attribution"
      - "5 invariants: P5 UNC is cross-cutting (called first by all 4 helpers)"
    cons:
      - "P2/P3 detection is heuristic (regex, not AST) — may have false positives"
      - "P4 write-zone detection is heuristic — legitimate writes outside canonical zones may warn"
  - id: B
    summary: "Runtime enforcement only (no static analysis hook)"
    pros:
      - "Zero false positives"
    cons:
      - "Violations only caught at runtime; no early-warning capability"
      - "Doesn't satisfy Charter Principle 11 (hook + firing-test mandate)"

chosen: A
chosen_rationale: |
  Option A provides both static detection (hook) and a fix recipe (helper module) in one
  bundle. The P2/P3 and P4 heuristics are WARN-only, so false positives don't block.
  P1, P1b, and P5 are ERR and have lower false-positive risk (regex patterns are specific).
  The 5-invariant structure directly mirrors Vibe-Trading's 4+1 design, which has been
  empirically validated in agent/tests/test_path_safety.py:1-136.

approval_chain:
  - actor: "sandwich-dev S332"
    action: PROPOSED
    at: 2026-05-15
    via: "session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md task sequence"

verified_by:
  - mechanism: firing-test
    at: 2026-05-15
    result: PASS
    detail: "18/18 TC PASS (scripts/hooks/firing-tests/path-safety-check-fire-test.sh)"
  - mechanism: unit-test
    at: 2026-05-15
    result: PASS
    detail: "23/23 pytest PASS (packages/_shared/test_path_safety.py)"

affects:
  charter: false
  spec_files: []
  code_paths:
    - "packages/**/*.py"
    - "apps/**/*.py"
    - "packages/_shared/path_safety.py"
  config_files:
    - ".claude/settings.json"
  other_decisions:
    - "D-059"
    - "D-061"
    - "D-062"
    - "D-063"

depends_on:
  - "D-059"
  - "D-061"

supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: "N/A"

tags: ["wave-0", "substrate", "harness", "path-safety", "5-invariant", "UNC", "sandbox"]
---

# Decision 064 — Path-Safety 5-Invariant Contract

## Context

StockForge production code handles file paths from multiple sources: user input (broker
imports), LLM-generated paths (backtest runs), and internal state artifacts. Without
path-safety enforcement, an adversarial or buggy path can escape designated directories,
read/write sensitive files, or traverse to system locations.

Vibe-Trading (HKUDS/Vibe-Trading, MIT 2026) solves this with 4 public path-safety helpers
and 1 shared cross-cutting UNC-reject guard, totalling **5 invariants**. D-061 ratified the
"expansion from 4 to 5" (master plan § 4.15 called it "quad"; Q-INT-bis empirical survey
confirmed UNC reject is a fifth independent invariant per `path_utils.py:27-30`).

**Attribution**: Helpers adapted from Vibe-Trading (HKUDS/Vibe-Trading, MIT 2026).
See `agent/src/tools/path_utils.py`.

## The 5 Invariants

| # | Invariant | What it enforces | Source |
|---|-----------|-----------------|--------|
| **P1 (Sandbox)** | Sandbox-relative containment | Path must resolve under caller-supplied `workdir`; `..` escape rejected | `path_utils.py:33-54` |
| **P1b (Domain-abs)** | No absolute path literals in domain layer | Any `Path('/...')` or `Path('C:\\...')` literal in `packages/domain/**` | Architecture BC rule |
| **P2 (User-supplied)** | User path scoped to import roots | `Path(sys.argv[N])` or `Path(os.environ.get())` must be wrapped by `safe_user_path()` | `path_utils.py:158-171` |
| **P3 (Document)** | Document-reader paths scoped to import roots | Same boundary as P2; separate helper for call-site intent clarity | `path_utils.py:174-187` |
| **P4 (Run-dir)** | Write-zone containment | Writes to paths outside `outputs/`, `logs/`, `state/`, `cache/`, `data/`, `memory/` zones flagged | `path_utils.py:190-213` |
| **P5 (UNC)** | Cross-cutting UNC reject | `\\server\share` or `//server/share` prefix rejected by ALL public helpers as FIRST guard | `path_utils.py:27-30` (`_rejects_unc`) |

## Layer Scope

| Layer | Rule |
|-------|------|
| `packages/domain/**` | STRICTEST: P1b fires if ANY `Path('/...')` or `Path('C:\\...')` literal appears. Domain = pure Python, no filesystem code. Currently clean (0 violations at S332). |
| `packages/application/**` | Port abstractions only; no concrete filesystem. P2/P3 fires on direct user-input path. |
| `packages/infrastructure/**` | Filesystem allowed; MUST use `safe_*_path` helpers for user-supplied paths. |
| `apps/**` | Same as infrastructure. |

## Helper API (`packages/_shared/path_safety.py`)

```python
# P1 — sandbox containment
safe_path(p: str, workdir: Path) -> Path

# P2 — user-supplied broker file
safe_user_path(p: str) -> Path

# P3 — document-reader input
safe_document_path(p: str) -> Path

# P4 — generated-code run directory
safe_run_dir(p: str) -> Path

# P5 — cross-cutting UNC guard (called first by all 4 above)
_rejects_unc(p: str) -> None  # raises ValueError on UNC prefix
```

**Environment vars for extending allowed roots**:
- `STOCKFORGE_ALLOWED_FILE_ROOTS` — comma-separated roots for P2/P3
- `STOCKFORGE_ALLOWED_RUN_ROOTS` — comma-separated roots for P4

## Allow-List

| Mechanism | Effect |
|-----------|--------|
| `# path-safety-ok: <rationale>` inline marker | Line-level exemption; rationale required (non-empty) |
| Test files (`test_*.py`, `*_test.py`, `*/tests/*`) | Exempt (test code may craft adversarial paths) |
| `scripts/` directory | Exempt (dev tooling) |
| `packages/_shared/path_safety.py` itself | Exempt (the implementation IS the helper) |

## Enforcement

**Hook**: `scripts/hooks/path-safety-check.sh`
- PostToolUse mode: scans edited `.py` file if in `packages/` or `apps/`
- Stop mode: full tree audit
- P1, P1b, P5: `severity=HIGH` (ERR) → `.session-hooks.log`
- P2/P3, P4: `severity=MEDIUM` (WARN) — heuristic; higher false-positive tolerance
- RC=0 always; hour-bucket markers `.psafety-marker-*`
- Notification: `human-workspace/notifications/path-safety-warn.md` (S318 idempotent)

**Firing-test**: `scripts/hooks/firing-tests/path-safety-check-fire-test.sh`
- 18/18 TC PASS (3 cases per invariant + allow-list + edge cases + RC=0 regression floor)

**Unit tests**: `packages/_shared/test_path_safety.py`
- 23 tests covering P1-P5 via pytest parametrize + monkeypatch for env vars
- mypy --strict clean; ruff clean

**Compliance enforcement** (per Charter Principle 8):
- Sessions 1-5: WARN-only posture. P1/P1b/P5 emit ERR to log but classifier is lenient.
- After 5 clean sessions: promote P1/P1b/P5 to BLOCKING.
- Current production violations at S332 IMPL: P1=0, P1b=0, P5=0 (domain clean), P2/P3 and P4 not audited separately.

**Charter Principle 11** satisfied: hook ships with companion firing-test.

## Live Audit Count (S332 IMPL, 2026-05-15)

W0-5 violations in `packages/` + `apps/` at HEAD:
- P1 (traversal): 0
- P1b (domain absolute): 0 (domain layer is clean — 0 path expressions in packages/domain/)
- P2/P3 (unsanitized user path): not separately counted (heuristic WARN; full audit deferred to W0-5.1)
- P4 (write zone): not separately counted (heuristic WARN; full audit deferred to W0-5.1)
- P5 (UNC): 0

**Domain layer is clean.** Infrastructure/apps may have heuristic P2/P3 + P4 WARNs →
deferred to W0-5.1 cleanup session.

## Acceptance Record

- **2026-05-15**: PROPOSED by sandwich-dev S332 (Claude Sonnet 4.6) during W0-3+4+5 bundle IMPL
