---
id: 079
title: Pre-Commit Pytest Regression Guard
status: ACCEPTED
date: 2026-05-17
authors: sandwich-dev S388
ratified_by: sandwich-verifier S389 PASS-WITH-CONCERNS (af4a86c2e696159e9); IMPL-tier auto-ratifies per severity-schema; 0 CRITICAL / 3 IMPORTANT (all documentation-layer F1+F2+F3 inline-resolved by main S390) / 4 MINOR
level: IMPL
supersedes: []
superseded-by: []
cross_refs:
  - D-052 (ghost-greening RCA — detection pattern precedent)
  - D-060 (agent-may-commit policy — the commit boundary this hook guards)
  - D-064 (path-safety 5-invariant — file-path helpers if extended)
  - D-062 (atomic-write doctrine — marker write for cache key uses atomic-ish touch)
plan_ref: agent-workspace/session-plans/completed/039-S387-harness-stabilization-sweep-N1.md (S387 architect; S388 dev; S389 verifier; S390 close)
source_evidence:
  - "scripts/hooks/pre-commit-pytest-regression-guard.sh (173 LOC NEW; F2 inline-fix at S390 added this field per L-S389-2 verifier finding)"
  - "scripts/hooks/firing-tests/pre-commit-pytest-regression-guard-fire-test.sh (199 LOC NEW; 10 TCs PASS)"
  - "agent-workspace/memory/observations/sandwich-dev-S388-harness-sweep-N1-impl.md (D2 sub-track section)"
  - "agent-workspace/memory/observations/sandwich-verifier-S389-harness-sweep-N1-verify.md (V8 settings.json wiring + V6 firing-test 10/10 empirical re-run)"
empirical_close_verify:
  - "scripts/hooks/pre-commit-pytest-regression-guard.sh exists and bash -n clean"
  - "grep STOCKFORGE_SKIP_PRECOMMIT_PYTEST scripts/hooks/pre-commit-pytest-regression-guard.sh = ≥1 hits"
  - "grep pre-commit-pytest-regression-guard .claude/settings.json = ≥1 hits (wired in PreToolUse)"
  - "scripts/hooks/firing-tests/pre-commit-pytest-regression-guard-fire-test.sh PASS 10/10"
---

## Decision

A NEW `scripts/hooks/pre-commit-pytest-regression-guard.sh` PreToolUse hook fires on every
`Bash(git commit:*)` invocation. It runs `pytest` on the test files directly related to any
staged/unstaged Python files. If pytest fails, the commit is BLOCKED (exit RC=2).

This closes L-S382-1 (PROMOTE-NOW; n=10 L-S345-1 cluster): M-S381-1 pattern where a
ctor-signature change was not propagated to test helpers, causing 4 pytest failures + 4 mypy
errors to slip from dev commit to verifier.

## Root Cause Addressed

M-S381-1 (ValidateThesisPhase1UseCase ctor changed; `_make_use_case` test helper not updated;
4 pytest failures + 4 mypy errors slipped to verifier). The commit was made AFTER the change
without running related tests; existing pre-commit hooks did not cover pytest scope.

## Architecture Decisions

| DD | Decision | Rationale |
|----|----------|-----------|
| DD-1 | Changed-file ancestry scope (NOT full project) | Full-project pytest at every commit is too slow (~50K cache-read tokens minimum; would gate dev commit speed). Changed-file ancestry catches the M-S381-1 class. S389 verifier gate catches full-project regressions. |
| DD-2 | Fires on Bash `git commit` matcher only | Per-commit triggering is minimum-coverage to catch commit-claim vs empirical-gate divergence; per-tool-call triggering would 10x cost. |
| DD-3 | `STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1` env bypass | WIP commits with intentional test gap need a bypass; mirrors `pre-dispatch-architect-commit-guard.sh:14` pattern (DD-4 DD-4). |
| DD-4 | SHA-keyed green cache (`agent-workspace/memory/.pre-commit-pytest-green-<sha>.last`) | Same-changeset re-commit (e.g. after `git commit --amend`) should not re-run pytest. Cache key = sha1 of sorted changed-file list. 1-hour TTL. |
| DD-5 | 60-second timeout + WARN-ALLOW on timeout | Pathological hangs should not block all commits; WARN logged to `.pre-commit-pytest-regression-guard.log`; emit exits 0 (allow). |
| DD-6 | Pattern precedent = `pre-dispatch-architect-commit-guard.sh` | Proven Windows spawn topology; stdin JSON parse + RC=2 block; same guard pattern. SPAWN-CONTEXT: stdin-json (PreToolUse) per L-S247-1 lint discipline. |

## Scope

- ONLY tests directly sibling to changed Python files (`test_<basename>.py` in same dir + `tests/test_<module>.py`)
- Does NOT run full project pytest (that is S389 verifier scope per DD-1)
- Does NOT run on non-commit Bash calls (early-exit at tool_name + command check)
- Does NOT run if no `.py` files changed (early-exit; non-Python commits are safe)
- Does NOT run if no test sibling found (WIP commits without test coverage = allow per DD-1)

## Files Shipped

| File | Action |
|------|--------|
| `scripts/hooks/pre-commit-pytest-regression-guard.sh` | NEW (PreToolUse hook) |
| `scripts/hooks/firing-tests/pre-commit-pytest-regression-guard-fire-test.sh` | NEW (10 TCs) |
| `.claude/settings.json` PreToolUse section | MODIFIED (wired after pre-dispatch-architect-commit-guard.sh) |
| `.claude/agents/sandwich-dev.md` STEP 0.11 | MODIFIED (ctor-grep doctrine) |

## Companion Firing-Test Coverage (10 TCs)

| TC | Scenario | Expected |
|----|----------|----------|
| TC1 | Bash + git commit + no .py changed → no git repo | ALLOW (exit 0) |
| TC2 | tool_name=Read (not Bash) | ALLOW (exit 0, not Bash) |
| TC3 | Bash + non-commit (git log) | ALLOW (exit 0, no commit keyword) |
| TC4 | STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1 bypass | ALLOW (exit 0, bypass honored) |
| TC5 | git commit + .py with no test sibling | ALLOW (exit 0, WIP commit) |
| TC6 | git commit --amend + no .py changed | ALLOW (exit 0) |
| TC7 | SHA-keyed green marker present + fresh | ALLOW (cache hit; no pytest re-run) |
| TC8 | stdin with empty JSON | ALLOW (exit 0, defensive) |
| TC9 | Bash + empty command | ALLOW (exit 0, no commit keyword) |
| TC10 | hook syntax (bash -n) clean | PASS |

## Revisit Triggers (per AP-7 anti-vacuous-defer)

1. **False-positive rate > 5% in 30 commits** (WIP commits blocked unintentionally) → expand
   no-test-sibling early-exit to cover more WIP patterns (e.g. `--allow-empty`)
2. **Hook missed a regression at commit boundary 2+ times** → extend scope to full-project
   pytest (review DD-1 cost tradeoff at that point)
3. **Windows spawn topology failure** → verify `pre-dispatch-architect-commit-guard.sh`
   still works on same OS + compare spawn patterns

## Risks

- RM1: Hook adds latency to every `git commit` (~1-3s warm per SHA-cache hit). Mitigated by cache + changed-file-only scope.
- RM2: False-positive blocks legitimate WIP commit. Mitigated by no-test-sibling early-exit + env bypass.
- RM3 (RM10 from plan): Windows spawn topology failure. Mitigated by pattern reference = pre-dispatch-architect-commit-guard.sh (proven on Windows).
