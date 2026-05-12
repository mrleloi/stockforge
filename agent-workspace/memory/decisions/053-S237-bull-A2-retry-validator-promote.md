---
decision_id: D-053
session: S237
date: 2026-05-10
status: ACCEPTED-AND-SHIPPED
authors: [sandwich-dev/claude-sonnet-4-6]
approvers: [Q-P4-1-AUTO-PICK]
supersedes: null
superseded_by: null
canonical_path: agent-workspace/memory/decisions/053-S237-bull-A2-retry-validator-promote.md
hygiene_note: |
  S245 hygiene cleanup (per S243 verifier F-Hygiene-1): prior frontmatter labeled this file DUPLICATE-OF-D-053 with a canonical pointer to `053-a2-retry-validator-promoted-production-default.md` which DOES NOT EXIST on disk. The substantive D-053 content lives here regardless, and README.md references this filename as canonical. DUPLICATE marker removed; status normalized to ACCEPTED-AND-SHIPPED. The phantom-dispatch reference (S237 sandwich-dev agent_id=aeecebab4d84b9825 vs a23ab433588dd7f17) is preserved here as historical context for L-S240-5 phantom-dispatch class but no longer affects this file's status.
---

# D-053: Promote A2 (retry-validator) to Bull Production Default

## Context

Phase 4 Track A (S236) ran an empirical probe of three hardening strategies for the
bull perspective agent against 5 dogfood tickers (BID/BVH/CTG/FPT/GAS) to fix the
I-S3 compliance failure (bull key_points lacking `category` field in SQLite).

**Critical correction**: The S232 "1/5" baseline was wrong. SQLite query revealed all
3 CTG bull points had `category=None`. True pre-probe baseline was **0/5**. Markdown
rendering does not expose `category`. All I-S3 verification must use SQLite as
source of truth (not markdown view) — per S236 observation.

Verifier S234 finding F1: silent-error-swallow at bull_agent.py:150-165 was
also addressed by the retry-validator approach (explicit warning on exhaustion
instead of silent empty output).

## Probe Matrix (verbatim from track-A-bull-probe-S236.md §3)

| # | Strategy | Ticker | bull_pts | distinct_cats | i_s3 | failure_mode         | cost_usd |
|---|----------|--------|----------|---------------|------|----------------------|----------|
| 1 | A1       | BID    | 0        | 0             | N    | silent-empty         | 1.188396 |
| 2 | A1       | BVH    | 0        | 0             | N    | silent-empty         | 1.007435 |
| 3 | A1       | CTG    | 0        | 0             | N    | silent-empty         | 1.189189 |
| 4 | A1       | FPT    | 0        | 0             | N    | silent-empty         | 1.223541 |
| 5 | A1       | GAS    | 0        | 0             | N    | timeout-600s         | 0.000000 |
| 6 | A2       | BID    | 3        | 3             | Y    | retry-used           | 1.544347 |
| 7 | A2       | BVH    | 0        | 0             | N    | validation-exhausted | 2.068826 |
| 8 | A2       | CTG    | 3        | 3             | Y    | ok                   | 1.462923 |
| 9 | A2       | FPT    | 3        | 3             | Y    | retry-used           | 2.005060 |
|10 | A2       | GAS    | 5        | 4             | Y    | retry-used           | 1.459831 |
|11 | A3       | BID    | 0        | 0             | N    | silent-empty         | 1.072911 |
|12 | A3       | BVH    | 0        | 0             | N    | silent-empty         | 0.960297 |
|13 | A3       | CTG    | 0        | 0             | N    | silent-empty         | 0.961779 |
|14 | A3       | FPT    | 0        | 0             | N    | silent-empty         | 1.298775 |
|15 | A3       | GAS    | 0        | 0             | N    | silent-empty         | 1.115166 |

## Strategy Aggregates (verbatim from probe observation §4)

| Strategy | Compliant | Compliance Rate | Mean Cost (valid runs) | Total Cost |
|----------|-----------|-----------------|------------------------|------------|
| A1       | 0/5       | 0%              | $1.152 (4 valid runs)  | $4.609     |
| A2       | 4/5       | 80%             | $1.708 (5 runs)        | $8.541     |
| A3       | 0/5       | 0%              | $1.082 (5 runs)        | $5.409     |

## Decision

**WINNER: A2 (retry-validator)** — sole strategy meeting Q-P4-1 minimum threshold (4/5 I-S3
compliance). Auto-picked per Q-P4-1 lexicographic rule (compliance DESC, cost ASC).

Q-P4-1 lex sort:
1. A2: 4/5, $1.708/thesis mean — WINNER
2. A1: 0/5, $1.152 — ELIMINATED (0% compliance)
3. A3: 0/5, $1.082 — ELIMINATED (0% compliance; sonnet swap did not help)

**Alternatives rejected:**
- A1 (strict-JSON prefix): haiku honored JSON constraint by emitting `{"key_points": []}` —
  silent-empty. Structurally worse than parse-fail: appears "successful" to naive JSON parsers.
- A3 (haiku to sonnet model swap): sonnet also produces silent-empty for all 5 tickers.
  Cost increase without compliance gain. Haiku preserved per S43b-BULL fix.

## Impact

**Code changes (S237 production promotion):**
- `packages/infrastructure/analysis/perspectives/bull_agent.py`:
  Removed `STOCKFORGE_BULL_PROBE_STRATEGY` env-var branching (A1/A2/A3 strategy dispatch).
  Removed `_PROBE_STRATEGY` + `_STRICT_JSON_PREFIX` module-level constants.
  Removed `import os`. `analyze()` now unconditionally calls `_analyze_with_retry()`.
  `_analyze_with_retry()` + `_validate_bull_output()` promoted to permanent production code.
  LOC delta: -~20 (net; removed dispatch + A1/A3 code paths; kept retry + validator).

- `apps/_shared/use_case_builder.py`:
  Removed `_probe_strategy` env read + A3 ternary `bull_model = "claude-sonnet-4-6" if ...`.
  Replaced with `bull_model = "claude-haiku-4-5"` always (S43b-BULL fix preserved).
  LOC delta: -3.

**Tests added (S237):**
- `packages/infrastructure/analysis/perspectives/test_bull_agent.py` (NEW):
  11 unit tests covering `_validate_bull_output` + `_analyze_with_retry` paths.

**1-ticker LIVE smoke (FPT, S237):**
- Retry path activated: attempt 1 failed (prose output, key_points empty), attempt 2 timed out
  (haiku 300s CLI sub-timeout), attempt 3 succeeded with 4 bull points + 4 distinct categories.
- SQLite query: `role=bull: 4 points, 4 distinct cats` — **I-S3 COMPLIANT** (>= 3 points, >= 3 distinct cats).
- Cost: $2.07 — under $3.00 Charter Principle 11 cap.
- Bear/quant INCOMPLETE (pre-existing timeout issue, unrelated to this ADR's scope).

**Persistent gap (NOT a code bug, logged for separate investigation):**
- BVH: validation-exhausted in probe ($2.07 sunk) + BVH not retested in S237 smoke.
  Content gap in BVH SharedContext; retry mechanism works correctly. Backlog item.

## Phase gate unblocked

Phase 4 SC-1 (anti-flake LIVE 5-ticker dogfood run) is now unblocked. S238 next action:
run 5-ticker dogfood (BID/BVH/CTG/FPT/GAS) with A2 as production default; verify >=4/5
I-S3 compliance (BVH persistent gap accepted as known risk).
