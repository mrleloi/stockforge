---
id: D-062-atomic-write-doctrine
title: Atomic Temp-File-Replace Write Doctrine
date: 2026-05-15
status: PROPOSED
level: IMPL

author:
  - "Claude Sonnet 4.6 (sandwich-dev S332)"

source_evidence:
  - path: "agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md § 0"
    quote: "W0-3 — Atomic temp-file-replace doctrine — direct quotes from TradingAgents tradingagents/agents/utils/memory.py:109-114 docstring"
  - path: "C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:109-114"
    quote: "Uses a temp-file + os.replace() so a crash mid-write never corrupts the log."
  - path: "C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:161-163"
    quote: "tmp_path = self._log_path.with_suffix('.tmp'); tmp_path.write_text(new_text, encoding='utf-8'); tmp_path.replace(self._log_path)"
  - path: "C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:215-217"
    quote: "tmp_path = self._log_path.with_suffix('.tmp'); tmp_path.write_text(new_text, encoding='utf-8'); tmp_path.replace(self._log_path)"
  - path: "C:/htdocs/research/TradingAgents/tests/test_memory_log.py:426-437"
    quote: "test_update_atomic_write — proves stale-tmp survival semantic (tmp survives crash, old log unmodified)"
  - path: "agent-workspace/constitution/financial-data-protocol.md"
    quote: "Data integrity rules requiring every write to survive crash mid-operation without corruption"
  - path: "agent-workspace/memory/decisions/059-python-determinism-contract.md"
    quote: "Hook + firing-test + ADR triad pattern (W0-2 predecessor template); Charter Principle 11 alignment"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 30

options_considered:
  - id: A
    summary: "Enforce atomic write doctrine via bash hook + Python helper detection"
    pros:
      - "Deterministic detection of 4 banned patterns"
      - "RC=0 best-effort — never blocks Stop chain"
      - "Hour-bucket idempotency prevents re-scan spam"
      - "Matches W0-2 hook structural template (proven safe)"
    cons:
      - "Python helper adds subprocess overhead per file scan"
      - "Cannot catch runtime-constructed paths (heuristic only)"
  - id: B
    summary: "AST-based static analysis via ruff custom rule"
    pros:
      - "More accurate (full AST traversal)"
    cons:
      - "Requires ruff plugin development (significant scope expansion)"
      - "Slower integration with Stop chain"

chosen: A
chosen_rationale: |
  Option A matches the W0-2 DST-style hook pattern proven safe at S315 + S329. The Python
  subprocess helper for detection is a clean solution to the stdin-conflict problem (bash
  heredoc vs. stdin-consumed-by-cat). The heuristic limitations (runtime-path construction)
  are acceptable given the WARN→BLOCKING ratchet — initial WARN-only posture tolerates
  false-negatives while building calibration data. AST option deferred as out-of-scope
  per plan § "Out-of-scope explicit list" item N/A.

approval_chain:
  - actor: "sandwich-dev S332"
    action: PROPOSED
    at: 2026-05-15
    via: "session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md task sequence"

verified_by:
  - mechanism: firing-test
    at: 2026-05-15
    result: PASS
    detail: "15/15 TC PASS (scripts/hooks/firing-tests/atomic-write-check-fire-test.sh)"

affects:
  charter: false
  spec_files: []
  code_paths:
    - "packages/**/*.py"
    - "apps/**/*.py"
  config_files:
    - ".claude/settings.json"
  other_decisions:
    - "D-059"
    - "D-061"

depends_on:
  - "D-059"
  - "D-061"

supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: "N/A"

tags: ["wave-0", "substrate", "harness", "atomic-write", "data-integrity"]
---

# Decision 062 — Atomic Temp-File-Replace Write Doctrine

## Context

Wave 0 substrate W0-3 closes a data-integrity risk: production Python code in StockForge
writes state/audit/persistence files using raw `open(path, 'w'/'a')` + `.write()` or
`Path(path).write_text()` calls. If the process crashes mid-write, the file is left in a
partially-written state — corrupting the audit log, state snapshot, or memory zone entry.

TradingAgents v0.2.4 (Apache-2.0, Tauric Research) solved this with a temp-file + `os.replace()`
idiom documented in `tradingagents/agents/utils/memory.py:109-114`: _"Uses a temp-file +
os.replace() so a crash mid-write never corrupts the log."_ The concrete idiom repeats at
`:161-163` and `:215-217` (both `update_with_outcome` and `batch_update_with_outcomes`),
proving intentionality not accident. The companion test `test_memory_log.py:426-437`
(`test_update_atomic_write`) verifies the stale-tmp survival semantic.

This decision ports that doctrine into StockForge's enforcement harness as a banned-pattern
detector (W0-3), following the W0-2 hook + firing-test + ADR triad template (D-059).

**Attribution**: Pattern adapted from TradingAgents v0.2.4 (Tauric Research, Apache-2.0).
See `tradingagents/agents/utils/memory.py:109-217`.

## What Is Guaranteed

After this decision is enforced:

1. **Every state/audit write in `packages/**` + `apps/**` uses the sibling-tmp + atomic-replace idiom.**
   A crash mid-write leaves the stale `.tmp` file; the original file is unmodified.
2. **`os.replace()` is atomic on POSIX (Linux/macOS) and near-atomic on Windows ≥10 NTFS
   (documented in CPython docs: "On Windows, if dst exists, an OSError will be raised" for
   `os.rename`, but `os.replace` overwrites atomically even on Windows for same-filesystem
   moves — CPython 3.3+ guarantee).**
3. **A `# atomic-write-ok: <rationale>` inline marker on the offending line allows documented
   exceptions** (e.g. log-rotation code where the caller manages atomicity externally).

## The 4 Banned Patterns (AW-R1 through AW-R4)

| Rule | Pattern | Extension/Zone | Severity |
|------|---------|----------------|----------|
| AW-R1 | `open(path, 'w'/'a'/'wb'/'ab') ... f.write()` without `os.replace` within 10 lines | Any production path | ERR |
| AW-R2 | `Path(path).write_text()` or `.write_bytes()` on audited extensions (`.json`, `.jsonl`, `.tsv`, `.tsvl`, `.md`, `.log`, `.csv`) | Any production path | ERR |
| AW-R3 | `json.dump(obj, open(path, 'w'))` or `pickle.dump(obj, open(path, 'w'))` combined pattern | Any production path | ERR |
| AW-R4 | `write_text()` / `write_bytes()` on non-audited extensions inside persistence zones (`outputs/`, `logs/`, `state/`, `cache/`, `data/`) | Persistence zone paths | WARN |

## Required Idiom (Fix Recipe)

```python
# Correct atomic write pattern (ported from TradingAgents memory.py:161-163)
tmp_path = Path(target).with_suffix(Path(target).suffix + ".tmp")
tmp_path.write_text(new_text, encoding="utf-8")  # OR write_bytes
tmp_path.replace(target)   # atomic on POSIX; near-atomic Windows ≥10 NTFS
```

## Allow-List (Documented Exceptions)

| Context | Justification |
|---------|---------------|
| `test_*.py` + `*_test.py` filenames | Test code writes fixtures; failure mid-test = test failure, not audit corruption (W0-2 precedent) |
| Files inside `*/tests/*` subdirectory | Same rationale as test file exemption |
| `scripts/` directory | Dev tooling; not production audit-stream code |
| `examples/`, `docs/` | Sample/demo code; no audit-stream impact |
| `if __name__ == "__main__":` blocks | Dev-entry-point bottoms; same exception as W0-2 R2 |
| Inline `# atomic-write-ok: <rationale>` on the offending line | Allows manual opt-out with written justification; empty rationale does NOT qualify |

## Enforcement

**Hook**: `scripts/hooks/atomic-write-check.sh`
- PostToolUse mode: scans single edited `.py` file on `Edit|Write|MultiEdit`
- Stop mode: full tree audit of `packages/**/*.py` + `apps/**/*.py`
- Severity: ERR violations → `.session-hooks.log` as `severity=HIGH`; WARN → `severity=MEDIUM`
- RC=0 always (best-effort; never blocks Stop chain)
- Hour-bucket idempotency markers: `agent-workspace/memory/.aw-marker-*`
- Notification: `human-workspace/notifications/atomic-write-warn.md` (S318 idempotent fixed-name)

**Firing-test**: `scripts/hooks/firing-tests/atomic-write-check-fire-test.sh`
- 15/15 TC PASS (positive + negative + edge cases per architect-proposed TC1-TC15)
- Verifies all 4 rules (AW-R1..R4) + allow-list paths + RC=0 regression floor

**Compliance enforcement** (per Charter Principle 8 — calibration over confidence):
- **Sessions 1-5**: WARN-only posture; violations emitted but not blocking. Calibration window.
- **After 5 clean sessions**: promote AW-R1 + AW-R2 + AW-R3 to BLOCKING (modify hook's
  severity to `severity=CRITICAL` and let `severity-classifier.sh` block). AW-R4 remains WARN.
- Current production violations at S332 IMPL: **6** (deferred to W0-3.1 cleanup session per
  W0-2 → W0-2.1 precedent).

**Charter Principle 11** (companion firing-test mandate): satisfied.
Hook `atomic-write-check.sh` ships with companion `atomic-write-check-fire-test.sh` (15 TC).

## Live Audit Count (S332 IMPL, 2026-05-15)

W0-3 violations in `packages/` + `apps/` at HEAD (production, non-test files):

- `packages/infrastructure/influence/llm_recommendation_extractor.py:466` — `fname.write_text(payload, encoding="utf-8")`
- `apps/cli/ingest_fundamentals_vn30.py:199` — `path.write_text("\n".join(lines) + "\n", encoding="utf-8")`
- `apps/cli/ingest_news_cafef.py:309` — `path.write_text("\n".join(lines) + "\n", encoding="utf-8")`
- `apps/cli/ingest_vhm.py:138` — `path.write_text("\n".join(lines) + "\n", encoding="utf-8")`
- `apps/cli/ingest_vn30.py:202` — `path.write_text("\n".join(lines) + "\n", encoding="utf-8")`
- `apps/cli/validate_thesis.py:153` — `out_path.write_text(md, encoding="utf-8")`

**Total: 6 violations** → deferred to W0-3.1 cleanup session. Count is < 10 threshold; single
bundled cleanup session expected.

## Acceptance Record

- **2026-05-15**: PROPOSED by sandwich-dev S332 (Claude Sonnet 4.6) during W0-3+4+5 bundle IMPL
