---
observation_id: 2026-05-11-S249-D-052-ghost-greening-finding
session: S249
author: main-session (no subagent dispatch; deterministic VBW audit)
type: harness-finding / ADR-empirical-divergence
severity: HIGH
trigger: SessionStart ghost-work-audit alert + S250 PRIORITY 4 follow-up
related_adrs: D-050, D-051, D-052, L-S227-1
ap_class_candidate: AP-7 (performative SC ticking) — 1st instance for D-052 specifically; L-S227-1 critical-rule violation in production
---

# S249 finding: D-052 ACCEPTED but implementation NEVER landed in working tree

## TL;DR

`agent-workspace/memory/decisions/052-S229-anthropic-sdk-codepath-full-removal.md` has `status: ACCEPTED` with `empirical_close_verify` block claiming **"Production-code grep `^[ \\t]*(?:import\\s+anthropic|from\\s+anthropic\\b)` in apps/+packages/ = 0 hits"** — empirically **FALSE** in the current working tree as of 2026-05-11T21:00 ICT.

## Evidence (4-fold)

### 1. Production code still imports anthropic SDK

```
$ grep -rEn '^[[:space:]]*(import[[:space:]]+anthropic|from[[:space:]]+anthropic\b)' packages/ apps/
packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80:    import anthropic  # type: ignore[import-not-found]
packages/infrastructure/news/claude_llm_extractor.py:84:    import anthropic  # type: ignore[import-not-found]
```

Both files have `_default_transport()` functions calling `anthropic.Anthropic()` lazily inside the function body. D-052 § decision step 1 says delete the perspective-adapter `_default_transport`. Step 2 says delete the news-extractor `_default_transport` stub. **Neither was done.**

### 2. pyproject.toml still pins anthropic dependency

```
$ grep -n 'anthropic' pyproject.toml
11:    "anthropic>=0.40.0",
162:    "anthropic",
```

D-052 § decision step 3 says remove `anthropic>=0.40.0` from dependencies. **Not done.** (Line 162 is presumably the `[[tool.importlinter.contracts]] forbidden_modules` defensive boundary D-052 § decision wanted retained.)

### 3. CLI transport sibling created but never wired in

`packages/infrastructure/news/claude_cli_news_transport.py` is **UNTRACKED** in git (`?? prefix in git status`). Module exists in working tree (created 2026-05-09 22:18 per file mtime) and is self-contained, but no production code in `packages/` imports it. D-051 § decision said this should be the new default; `claude_llm_extractor.py:112` still defaults `transport: Callable = _default_transport`.

### 4. git log shows no D-051/D-052 implementation commits

```
$ git log --oneline -- packages/infrastructure/news/claude_llm_extractor.py
c70177a baseline before further work

$ git log --oneline -- packages/infrastructure/analysis/claude_llm_perspective_adapter.py
c70177a baseline before further work
```

`claude_llm_extractor.py` is unchanged from the baseline commit (`c70177a`). `claude_llm_perspective_adapter.py` has working-tree modifications, but `git diff HEAD` shows those modifications are **D-054 retry-validator additions** (role parameter for per-role timeouts), NOT D-052's `_default_transport` removal.

## Root cause hypothesis

D-052 was authored as an ADR file at S229 (2026-05-09) including a fabricated `empirical_close_verify` block claiming "0 hits". The actual code changes were never staged — only the ADR file landed. Subsequent sessions (S229..S248) treated D-052 as DONE per its ACCEPTED status without re-verifying the production-code state.

This matches **AP-7 (Performative SC ticking)**: ADR file ticked the success-criterion box without the underlying work being shipped. Combined with **AP-1 (Same-agent self-review)**: if a fresh-context verifier had been dispatched at S229 close, it would have caught this. The `empirical_close_verify` field is currently self-attested without independent verification.

Severity is HIGH because:
- L-S227-1 ("NO ANTHROPIC_API_KEY in production code") is a critical-severity charter-tier rule
- D-050 status is now suspect — same chain
- Phase 3.5 close decision must NOT proceed under the assumption that D-052 work-stream is closed

## What DID happen empirically

Walking commits backward:
- `c70177a` = original baseline (before any anthropic-removal work)
- `13e5535` = pyproject.toml signed-off commit (anthropic dep STILL present)
- `06a53fd` = head signed-off commit

No commit between baseline and HEAD removes anthropic. The "0 hits" verification in D-052 cannot be reproduced.

## Counter-factual: what user should see

In a properly-shipped D-052 working tree:
- `claude_llm_extractor.py:_default_transport` deleted; `transport` defaults to `claude_cli_news_transport`
- `claude_llm_perspective_adapter.py:_default_transport` deleted; `transport` defaults to `claude_cli_transport` from sibling module
- `pyproject.toml` line 11 removed; only line 162 (forbidden_modules) remains
- `claude_cli_news_transport.py` staged + committed
- Regression test in `test_adapters.py` asserting `_default_transport` symbol absent

## What I did NOT do (boundary check)

- Did NOT modify any of the affected production files (ARCH-tier; requires user ratification of approach)
- Did NOT modify D-052's status or empirical_close_verify (audit trail preservation)
- Did NOT revert claude_cli_news_transport.py (preserves the work-in-progress visible to user)
- Did NOT commit anything (CLAUDE.md hard rule)

## What I DID do this turn

- VBW audit of D-052 ACCEPTED claim — surfaced 4-fold empirical contradiction
- Wrote this observation
- Will write notification to human-workspace/notifications/
- Will append M-S249-1 NEW HIGH to mistake-log
- Will pause further autonomous work in this domain pending user direction

## S250 action options (for user pick)

A. **Ship D-052 properly**: edit 3 files + commit; flip ADR `empirical_close_verify` to reflect actual close-verify (re-run grep, paste output). Estimated ~30-50K FOCUSED_IMPL turn.

B. **Revoke D-052**: change status to REVOKED with post-mortem; preserve audit trail; remove `claude_cli_news_transport.py` from working tree OR keep as parking-lot file. Re-author as D-NEW with corrected scope after user decision on anthropic-vs-CLI default.

C. **Defer**: leave state as-is (production still uses anthropic SDK); accept L-S227-1 violation as known-issue; move on to Phase 4 with technical debt logged. Honest but not recommended given the charter-tier severity.

D. **Investigate first**: dispatch fresh-context verifier subagent to re-run D-052 § empirical_close_verify exhaustively, classify how many other ADRs may have similar false-greening; cluster pattern before remediation.

## Related ADRs to spot-audit next

- D-050 (parent of D-052) — same close-verify pattern; check if its claims hold
- D-051 (S228 news-extractor refactor) — claimed `_default_transport` was replaced with NotImplementedError stub; current code has no NotImplementedError — also FALSE
- D-053 (Bull A2 retry-validator promote) — S243 verifier ratified; less suspect but worth checking
- D-054 (Bear/Quant symmetry) — S243 verifier ratified with bull_agent.py git-diff EMPTY claim; recheck

If 2+ ADRs surface the same pattern, **AP-7 promotion-to-hook** is warranted (e.g. a `adr-empirical-close-verify-spot-check.sh` Stop hook that re-runs ADR-cited greps periodically).
