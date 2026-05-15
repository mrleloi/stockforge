---
session: S329
plan: agent-workspace/session-plans/pending/017-S329-wave-0-W0-2.1-python-determinism-fixes.md
agent: sandwich-dev
type: FOCUSED_IMPL
date: 2026-05-15
status: COMPLETE
tests_passed: 90
tests_baseline: 88
new_tests: 2
commit_sha: 510f533
---

# Observation: S329 W0-2.1 Python-Determinism Fixes

## STEP 0 Pre-flight Results

**STEP 0.1** — Hook re-scan: 2 violations confirmed (1x R1 + 1x R2), matching plan's inventory exactly. No STOP-IF-AMBIGUOUS trigger.

**STEP 0.2** — Grep confirmation:
- `sqlite_thesis_repository.py:206:        else datetime.now()` — confirmed
- `capture_sentiment_snapshot_use_case.py:180:        sample_ids = [p.post_id for p in random.sample(classified, min(_MAX_SAMPLE_POSTS, len(classified)))]` — confirmed

**STEP 0.3** — Baselines before editing:
- `packages/infrastructure/analysis/` — **70 passed**
- `packages/application/crowd/` — **18 passed**
- Total baseline: **88 passing, 0 failures**

Both suites green. No STOP-IF-AMBIGUOUS trigger on baseline red.

## DoD Evidence

### DC1 — R1 fix in sqlite_thesis_repository.py

- `packages/infrastructure/analysis/sqlite_thesis_repository.py:26` — `from datetime import UTC, date, datetime` (ruff UP017 auto-corrected from `timezone.utc` to the `UTC` alias already used in the file; no orphan import).
- Line 206 (now line 206): `else datetime.now(UTC)  # D-059 R1 fix: fallback must be tz-aware UTC`
- grep confirms zero remaining `datetime.now()` bare-parens hits in this file.

### DC2 — R2 fix in capture_sentiment_snapshot_use_case.py

- New dataclass field added after line 115 (`clock` field):
  ```python
  rng: random.Random = field(
      default_factory=random.Random  # D-059 R2 fix: unseeded by default; tests inject seeded instance
  )
  ```
- Line 180: `sample_ids = [p.post_id for p in self.rng.sample(classified, min(_MAX_SAMPLE_POSTS, len(classified)))]`
- `random.sample(` no longer appears in production code; only `self.rng.sample(` does.
- Blast-radius: zero positional callers — all construction uses keyword args. Default-factory `random.Random` preserves production behavior.

### DC3 — Hook output: 0 violations

```
[2026-05-15T16:13:27+07:00] python-determinism-check: OK (0 violations across 343 file(s))
```

### DC4 — Notification resolved

`human-workspace/notifications/python-determinism-warn.md` updated to `status: RESOLVED` per L-S322-1 in-place deprioritize pattern.

Note: during editing, the test file's docstring contained the literal string `datetime.now()` (describing the pre-fix state). The PostToolUse hook fired on intermediate state and detected this. The docstring was reworded to avoid the banned pattern (now says "returned a tz-naive datetime"). A final fresh Stop-mode scan confirmed 0 violations.

### DC5 — Two new tests PASS

**Test 1**: `packages/infrastructure/analysis/test_repository.py::test_rebuild_thesis_fallback_uses_utc_aware_datetime`
- Saves a thesis, tampers the `created_at` field to `None` via direct SQLite connection, retrieves via `get_by_id`.
- Asserts: `retrieved.created_at.tzinfo is not None` AND `retrieved.created_at.tzinfo == UTC`.
- **PASS**

**Test 2**: `packages/application/crowd/use_cases/test_capture_sentiment_snapshot.py::TestCaptureSentimentSnapshotOrchestration::test_snapshot_sample_ids_deterministic_when_rng_seeded`
- 25 posts (> `_MAX_SAMPLE_POSTS=20`); same seed (42) twice → identical `source_posts_sample` tuple.
- Different seed (99) → different tuple (anti-hardcoded sanity check).
- `len(snap1.source_posts_sample) == 20` — sampling cap asserted.
- **PASS**

### DC6 — pytest exit 0

`python -m pytest packages/infrastructure/analysis/ packages/application/crowd/ -q`
**90 passed** (baseline 88 + 2 new). 0 regressions.

### DC7 — mypy --strict exit 0

Run per-file with `--explicit-package-bases` (multi-file invocation triggers "source file found twice" path-resolution error in this project — per-file is the correct invocation pattern):

- `sqlite_thesis_repository.py` — Success: no issues found
- `capture_sentiment_snapshot_use_case.py` — Success: no issues found
- `test_repository.py` — Success: no issues found
- `test_capture_sentiment_snapshot.py` — Success: no issues found

### DC8 — ruff exit 0

Initial run flagged UP017 (use `datetime.UTC` alias instead of `timezone.utc`) — auto-fixed via `ruff check --fix`. Re-run: **All checks passed!**

### DC9 — Firing-test 12/12 PASS

`bash scripts/hooks/firing-tests/python-determinism-check-fire-test.sh`
Output: `python-determinism-check-fire-test: 12/12 PASS`

Hook was not touched. Regression floor confirmed.

### DC10 — No ADR D-062

Approach A executed cleanly per plan. No deviation from D-059's stated contract. No new exception needed. `D-062 NOT required`.

### DC11 — Session log written

`agent-workspace/memory/sessions/2026-05-15-session-329.md` — written.

### DC12 — current-execution.md updated

W0-2.1 status → DONE. S329 row prepended per retention rules.

### DC13 — Mistake log

No mistakes this session. Session log states this explicitly.

## Commit

```
SHA: 510f533
Message: S329: W0-2.1 Python-determinism fixes — R1 + R2 + tests
Files: 5 (2 production + 2 tests + 1 notification)
Insertions: 94 / Deletions: 12
Push: 0 (D-060 compliant)
```

## Compliance Attestation (S329 close)

- I-S1 NO-LLM-math: PASS — neither fix touches any number-emitting logic. R1 fix swaps a datetime default; R2 fix swaps an RNG source. Both code edits operate on plumbing, not on the I-S1-bound numeric fields (mention_count / posting_velocity / unique_posters / coordinated_posting_score / bullish_ratio are all unchanged per use case lines 163-174).
- I-S2 source+as-of cites: PASS — every test assertion cites the rule it pins (D-059 R1 / D-059 R2); the production fixes carry inline comments referencing the rule.
- harness_priority_one: PASS — this IS a product-layer determinism cleanup that closes the D-059 contract's known gap; the harness hook (W0-2 itself) is untouched but the rule it enforces now has 0 production violations.
- D-060 commit-policy: PASS — 1 commit (510f533), 0 push.
- 0 charter / 0 constitution edits: PASS
- AP-1 honored: S330 verifier is fresh-context; this dev does NOT self-verify the DoD.
- VBW protocol: PASS — full file Read before edit; STEP 0 grep confirmed patterns at lines 206 + 180 before editing.
- D7 (no D-062): PASS — Approach A executed clean; no D-059 modification needed.

## Risks Materialized

- RM5 (hour-bucket markers): mitigated by `rm -f .pydet-marker-*` before each hook run.
- Unexpected: docstring false-positive. The test file's docstring described the pre-fix pattern using the literal string `datetime.now()`. PostToolUse hook fired on intermediate state (before ruff cleanup). Mitigated by rewording the docstring. No plan deviation required — STEP 0.2 patterns were already confirmed, this was a test-file authoring detail not covered by plan's STOP-IF-AMBIGUOUS clause.
