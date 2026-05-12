---
observation_id: track-B-live-wiring-S240
type: track-B-live-wiring
agent_id: claude-sonnet-4-6-sandwich-dev-S240
started_at: 2026-05-10T09:00:00Z
completed_at: 2026-05-10T09:05:00Z
parent_session: S240
plan_ref: 008-S235-phase-4-master-plan.md
acceptance_gate: PASS
---

# Track B LIVE Wiring — S240 Observation

## 1. Executive Summary

Replaced the Phase 3 early-exit branch at `apps/cli/ingest_crowd_sentiment.py:162-168` with real LIVE
wirings: `_LiveClassifier`, `_LiveCoordinationDetector`, and `_LiveSnapshotRepo`. All three delegate
to existing concrete infrastructure classes (`LlmSentimentClassifier`, `CoordinationDetector`,
`SqliteSentimentSnapshotRepository`) discovered via empirical pre-reads (L-S204-1 compliance).

Created `packages/infrastructure/crowd/claude_cli_crowd_transport.py` — a BC-7-specific `(model,
prompt) -> str` transport callable for `LlmSentimentClassifier.llm_client`, with exponential backoff
(R-P4-5 mitigation) and no `ANTHROPIC_API_KEY` (D-050 / L-S227-1 compliance).

All acceptance gates PASS: 9/9 unit tests green, dry-run exits 0, LIVE-no-network exits 0 with 1
snapshot row written to SQLite. Full 3-platform SC-2 quantitative smoke is S241's gate.

No deviations from plan. No blockers. No Track A / C / D touches.

## 2. Files Touched + LOC Delta

| File | Action | LOC delta |
|---|---|---|
| `apps/cli/ingest_crowd_sentiment.py` | Modified | +73 LOC (live classes + helpers) |
| `packages/infrastructure/crowd/claude_cli_crowd_transport.py` | New file | +169 LOC |
| `apps/cli/test_ingest_crowd_sentiment.py` | New file | +186 LOC |

Total delta: ~428 LOC (including new test file). Excluding test file: ~242 LOC production code.

## 3. Test Results

### Unit tests (`pytest apps/cli/test_ingest_crowd_sentiment.py -v`)

```
9 passed in 0.84s
- test_t1_dry_run_exits_zero PASSED
- test_t2_dry_run_output_format PASSED
- test_t3_live_path_uses_live_classes PASSED
- test_t4_live_path_zero_posts_accepted PASSED
- test_t5_live_snapshot_repo_env_override PASSED
- test_t5b_live_snapshot_repo_default_path PASSED
- test_t6_unknown_platform_exits_nonzero PASSED
- test_live_coordination_detector_empty_posts PASSED
- test_live_classifier_delegates_to_llm_classifier PASSED
```

### Dry-run smoke

```
PYTHONPATH=. python apps/cli/ingest_crowd_sentiment.py --platform=comments --ticker=HPG --dry-run
Exit: 0
Output: "Complete: 1 snapshot(s) captured, 0 coordination alert(s). Research aid only — not financial advice."
```

### LIVE-no-network smoke (STOCKFORGE_DB_PATH override to tmp path)

```
PYTHONPATH=. STOCKFORGE_DB_PATH=C:/tmp/test_live_wiring.sqlite python apps/cli/ingest_crowd_sentiment.py --platform=comments --ticker=HPG
Exit: 0
DB verify: SELECT COUNT(*) FROM sentiment_snapshots → 1 row (ticker=HPG)
```

LIVE path executes end-to-end: aggregator fetches 0 posts (live network, 404 from cafef; vietstock
robots.txt disallow), use case creates 0-mention snapshot, `_LiveSnapshotRepo.save()` persists to
SQLite. No crash. No early exit. No `_LiveClassifier` invocation (correctly bypassed by use case
when raw_posts is empty).

### Quality gates

- mypy --strict --explicit-package-bases: Success, 0 errors (3 source files)
- ruff check: All checks passed
- pytest: 9/9 passed

## 4. Risks Observed (R-P4-5)

- **Real-network aggregators return 0 posts in dev environment**: cafef returns 404, vietstock
  blocks /search via robots.txt. This is expected dev-environment behavior. S241 LIVE smoke
  must run against real content (e.g., during market hours with real tickers having active threads).

- **`_LiveClassifier` uses claude CLI subprocess**: will fail if `claude` is not on PATH or
  if there are no posts to classify (short-circuit in use case handles the 0-post case). R-P4-5
  mitigation applied: exponential backoff (2s, 4s) + max 2 retries in `claude_cli_crowd_transport`.

- **Embedding-based TEMPLATE_SIMILARITY feature disabled**: `CoordinationDetector` initialized
  with `embedding_client=None` → uses Jaccard similarity fallback. Production embedding deferred
  to Phase 5 per plan § Phase 5 Deferrals.

- **No user-agent rotation at aggregator layer**: aggregators (f319, facebook, comments) are
  Phase 3 scaffolds. R-P4-5 user-agent rotation must be applied within aggregators in S241 if
  rate-limiting observed during multi-ticker smoke.

## 5. Handoff to S241

S241 needs to:

1. Run 3-platform LIVE smoke on real network during market/active hours:
   ```
   python -m apps.cli.ingest_crowd_sentiment --ticker=FPT --platform=f319
   python -m apps.cli.ingest_crowd_sentiment --ticker=FPT --platform=fb_group
   python -m apps.cli.ingest_crowd_sentiment --ticker=FPT --platform=comments
   # Repeat for 2 more tickers (e.g. VND, HPG)
   ```

2. Verify SC-2 quantitative gate:
   ```
   sqlite3 data/stockforge.sqlite "SELECT COUNT(*) FROM sentiment_snapshots WHERE captured_at > '<S241-start-iso>'"
   ```
   Expected: >=9 rows (3 platforms x 3 tickers).

3. If aggregators return 0 posts for all platforms (environment/network issue), investigate:
   - Check aggregator HTTP response codes in logs
   - Apply user-agent rotation in `packages/infrastructure/crowd/aggregators/` if rate-limited
   - Consider robots.txt compliance vs. research exemption (per crawler-reliability/SKILL.md)

4. `_LiveClassifier` will be exercised only when >0 posts are returned. First real LLM call
   via `claude_cli_crowd_transport` will happen in S241. If claude CLI not on PATH in target
   environment, `SubagentSubstrateError` will be raised with diagnostic message.

5. No code changes expected for S241 unless aggregators or `claude` CLI need patching for
   production-environment compatibility.
