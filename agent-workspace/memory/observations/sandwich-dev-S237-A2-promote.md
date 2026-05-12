---
observation_id: sandwich-dev-S237-A2-promote
type: impl-promotion
agent_id: sandwich-dev/claude-sonnet-4-6
session: S237
started_at: 2026-05-10
plan_ref: 008-S235-phase-4-master-plan.md
escalate: false
---

# S237 Dev Session — A2 Promote to Production Default

## Summary

A2 (retry-validator) promoted to production default per Q-P4-1 AUTO-PICK winner from
S236 probe (4/5 I-S3 compliance, $1.71 mean cost/thesis). All probe feature-flag gating
removed. Retry-validator is now always-on code path in `bull_agent.py`.

## Tasks Completed

[x] Step 1: Remove A1/A3 strategy code paths from bull_agent.py
[x] Step 2: Remove A3 ternary from use_case_builder.py
[x] Step 3: Add 11 unit tests for retry-validator path (test_bull_agent.py NEW)
[x] Step 4: 1-ticker LIVE smoke FPT — I-S3 compliant (4 bull points, 4 distinct cats)
[x] Step 5: ADR D-053 written
[x] Step 6: Probe scripts left in scripts/ (not deleted per plan)

## Code Produced

New files:
- `packages/infrastructure/analysis/perspectives/test_bull_agent.py` (+11 tests, ~180 LOC)
- `agent-workspace/memory/decisions/053-S237-bull-A2-retry-validator-promote.md`

Modified files:
- `packages/infrastructure/analysis/perspectives/bull_agent.py`
  (-`import os`, -`_PROBE_STRATEGY`, -`_STRICT_JSON_PREFIX`, -A1/A3 dispatch in `analyze()`,
   +docstring updates; `_analyze_with_retry` + `_validate_bull_output` kept as permanent code)
  Net LOC delta: -~25 lines
- `apps/_shared/use_case_builder.py`
  (-`import os as _os` inside func, -`_probe_strategy` read, -A3 ternary;
   +`bull_model = "claude-haiku-4-5"` always)
  Net LOC delta: -5 lines

## Verification

- mypy --strict (bull_agent.py): SUCCESS (0 errors)
- mypy --strict (use_case_builder.py): SUCCESS (0 errors; pre-existing claude_cli_news_transport.py:158 unrelated)
- mypy --strict (test_bull_agent.py): SUCCESS (0 errors; fixed explicit-Any by using top-level _AdapterStub class)
- ruff check (all 3 files): SUCCESS (all checks passed)
- pytest (test_bull_agent.py): 11/11 PASS
- pytest (full suite): 853/853 PASS (vs 818/818 S236 baseline; +35 new tests from S237+B+C tracks)

## 1-Ticker LIVE Smoke (FPT)

Result: I-S3 COMPLIANT
- Bull: 4 key_points, 4 distinct categories (FUNDAMENTAL/GROWTH/VALUATION/COMPETITIVE verified
  via SQLite query on `theses.payload_json -> perspectives -> key_points -> category`)
- Cost: $2.07 (under $3.00 Charter Principle 11 cap)
- Retry path activated: attempt 1 failed (prose output, key_points list empty per validate),
  attempt 2 timed out (haiku 300s CLI sub-timeout; existing issue), attempt 3 succeeded

Bear/quant INCOMPLETE (timeout; pre-existing issue unrelated to this ADR). Thesis written
as `status=submitted` with `gaps=['bear_case_insufficient']`. This is the known pre-existing
bear timeout issue — not regressed by A2 promotion.

Note: `STOCKFORGE_MOCK_LLM=false` was set correctly; bear LLM timeout is a separate S238
backlog item (bear prompt too large for 300s budget on haiku/sonnet).

## Deviations from Plan

None. All 6 steps executed as planned.

## Blockers

None.

## Staged for Commit

Files are ready but NOT committed per CLAUDE.md hard rule. Staged:
- packages/infrastructure/analysis/perspectives/bull_agent.py (modified)
- apps/_shared/use_case_builder.py (modified)
- packages/infrastructure/analysis/perspectives/test_bull_agent.py (new)
- agent-workspace/memory/decisions/053-S237-bull-A2-retry-validator-promote.md (new)
- agent-workspace/memory/observations/sandwich-dev-S237-A2-promote.md (new)

## S238 Next Action

Phase 4 SC-1 anti-flake LIVE 5-ticker dogfood run #1:
Run BID/BVH/CTG/FPT/GAS with A2 as production default; verify >= 4/5 I-S3 compliance
(bull key_points >= 3 with >= 3 distinct categories per SQLite query). BVH known persistent
gap (validation-exhausted). Per plan §S238.
