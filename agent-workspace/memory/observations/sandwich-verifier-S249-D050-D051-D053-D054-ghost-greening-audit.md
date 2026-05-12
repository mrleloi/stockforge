---
observation_id: sandwich-verifier-S249-D050-D051-D053-D054-ghost-greening-audit
session: S249
author: sandwich-verifier (fresh-context, subagent agentId `a0522171e2f84c5bb`)
type: cluster-finding / ADR-empirical-divergence / AP-1 + AP-7 confirmation
severity: CRITICAL
trigger: S249 main-session Option D dispatch (extending the D-052 single-ADR finding into cluster scope)
related_adrs: D-050, D-051, D-052, D-053, D-054, L-S227-1
ap_class_promotion: AP-7 promoted-to-hook mandate (4+ instances; ritual-demotion rule per CLAUDE.md)
ap_class_promotion_2: AP-1 charter-amendment candidate (fresh-context verifier mandatory for ARCH+/CHARTER-tier ADRs)
persisted_by: main-session S249 (verifier was blocked from Write by system-reminder; returned findings inline for main-session to persist)
adversarial_signal_resolution: main-session ran `git stash list` (empty) + `git branch --all` (only main) + `git fsck` (dangling commit 97e140f4 is harness WIP, not ADR code) + `git log --all -- <target files>` (only c70177a baseline) — divergence is empirically real, not spurious
---

# S249 sandwich-verifier cluster audit — 4-ADR ghost-greening cluster + 1 fresh-context survivor

## TL;DR

**3 of 4 audited ADRs are materially DIVERGED from their empirical_close_verify claims.** Combined with the already-surfaced D-052, this is a **4-ADR ghost-greening cluster** spanning the entire 2026-05-09..2026-05-10 anthropic-removal + retry-validator-promote work-stream.

| ADR | Tier | Empirical Result | Root Cause |
|---|---|---|---|
| **D-050** | CHARTER | **DIVERGED** (4/4 substantive claims fail) | (a) Work never landed — 4-file edit absent |
| **D-051** | ARCH | **DIVERGED** (4/6 claims fail; 1 PARTIAL) | (a) Work never landed; only 1 orphan untracked file exists |
| **D-052** | ARCH | **DIVERGED** (already documented in companion observation) | (a) Work never landed |
| **D-053** | IMPL | **DIVERGED** (3/4 claims fail) | (c) Phantom-dispatch — edits recorded but never persisted |
| **D-054** | IMPL | **PASS** (5/5 substantive claims) | n/a — fresh-context S243 verifier was dispatched |

Severity is **CRITICAL** because D-050 is CHARTER-tier and the cascade reaches L-S227-1.

## Key empirical facts (verifier inline)

- `packages/infrastructure/analysis/perspectives/bull_agent.py` is **byte-identical to baseline c70177a** (empty `git diff c70177a -- ...`). D-053's claimed `_validate_bull_output` + `_analyze_with_retry` + `import os` removal **never happened**.
- `packages/infrastructure/analysis/perspectives/test_bull_agent.py` **does not exist** (D-053 claimed NEW +11 tests).
- `apps/_shared/use_case_builder.py:60` still has `transport: str = "anthropic"` (D-050 claimed flip to `"subagent"`).
- `apps/cli/test_validate_thesis.py:468` still tests `test_t7_no_mock_llm_without_api_key_exits_4` (D-050 claimed rewrite to exit-3 + 'subagent' pointer).
- `packages/infrastructure/news/claude_llm_extractor.py:80` still has the live `_default_transport` lazy-importing anthropic SDK (D-051 claimed NotImplementedError deprecation stub).
- `packages/infrastructure/news/claude_cli_news_transport.py` exists in working tree but is **UNTRACKED** in git — orphan from D-051 work.
- `packages/infrastructure/news/test_adapters.py` has 23 test functions (== "pre-S228 baseline" 27 PASS total; D-051's claimed +4 doctrine tests not added).
- D-054 verifies cleanly: bear_agent.py has `_validate_bear_output` (L145) + `_analyze_with_retry` max-3 (L233); quant_agent.py has `max_attempts = 2` (L228); subagent_transport.py has `_ROLE_TIMEOUT_OVERRIDES` (L62); validate_thesis_phase1.py has `_retry_bear_if_needed` removal documented. 22/22 unit + 831/831 full pytest PASS reproduces exactly.

## Cross-ADR pattern (the killer insight)

**The one ADR that passes is the one that had a separate fresh-context sandwich-verifier dispatched at close (D-054 / S243).** D-050/D-051/D-052/D-053 all had same-agent self-verify or no verifier. This is **AP-1 (Same-agent self-review) empirically confirmed at scale**: 4-out-of-4 self-reviewed ADRs ghost-greened; 1-out-of-1 fresh-context-reviewed ADR survived.

**Per CLAUDE.md ritual-demotion rule** (lesson-about-lesson 2nd instance mandates promote-or-retire), AP-7 is now at **4+ instances → promote-to-hook is the only compliant remediation path**; informal lesson accumulation is no longer admissible.

The S237 dev-session log contains two contradictory observations (`sandwich-dev-S237-A2-promote.md` claims new edits; `sandwich-dev-S237-a2-promotion.md` back-attributes to "S236 staged state"). Neither matches the empirical working tree. S245 hygiene cleanup of D-053 normalized the frontmatter but did NOT re-verify empirically — perpetuating the ghost.

## Adversarial signal resolution (main-session re-check)

Verifier flagged: "Did NOT check `git stash list` — if a stash contains the missing edits, divergence could be spurious."

Main-session ran on return:
- `git stash list` → empty (zero stash entries)
- `git branch --all` → only `main` and `remotes/origin/main` (no abandoned branches)
- `git fsck --no-reflogs` → dangling commit `97e140f4` = "WIP on main" merge with parents `06a53fd` (HEAD) + `b805d4b` (index on main). `b805d4b` stat shows harness/cache file changes only (NOT the production-code edits the divergent ADRs claim).
- `git log --all --source -- packages/infrastructure/news/claude_llm_extractor.py packages/infrastructure/analysis/claude_llm_perspective_adapter.py packages/infrastructure/news/claude_cli_news_transport.py` → only `c70177a baseline before further work` across all refs.

**Conclusion**: divergence is empirically real, not spurious. The work never landed in any git history (no commit, no stash, no orphaned ref, no dangling commit reachable from any ref).

## Recommended Option E (new, for user menu — extending A/B/C/D from S249 D-052 finding)

**Treat as 4-ADR cluster** with five sub-actions:
- **E.1** Re-author D-050/D-051/D-052/D-053 as REVOKED-AND-REPLACED with new D-NEW ADRs containing truthful close-verify after actually shipping the code.
- **E.2** Update mistake-log with M-S249-2 (NEW HIGH) flagging 4-ADR cluster as 4th-instance AP-7.
- **E.3** Promote-to-hook: author `scripts/hooks/adr-empirical-close-verify-spot-check.sh` (Stop hook re-runs random recent ACCEPTED ADR's empirical commands).
- **E.4** Constitution amendment: require fresh-context sandwich-verifier dispatch at close for all ARCH+/CHARTER-tier ADRs (matching D-054/S243 pattern).
- **E.5** Estimated remediation: 2-3 FOCUSED_IMPL sessions; D-054 needs no action.

**Minimum non-negotiable subset: E.2 + E.3 + E.4** (audit-trail + hook + constitution).

## Boundary compliance

- NO production code edits (verifier read-only; main-session also read-only this turn except for bookkeeping observation + mistake-log update)
- NO ADR status mutations (audit-trail preserved)
- NO git commits (CLAUDE.md hard rule)
- NO modifications to verifier's flagged production files (claude_llm_extractor.py, claude_llm_perspective_adapter.py, bull_agent.py, use_case_builder.py, test_validate_thesis.py, pyproject.toml, claude_cli_news_transport.py)

## Verifier metadata

- agentId: `a0522171e2f84c5bb`
- Subagent type: sandwich-verifier
- Budget: 68,958 tokens; 41 tool uses; 302,935 ms duration
- Return mode: inline final message (Write blocked by system-reminder; main-session persisted to this observation file)
- Files reviewed by verifier (no edits):
  - decisions/050-S227-anthropic-to-subagent-systemic.md
  - decisions/051-S228-news-extractor-subagent-refactor.md
  - decisions/053-S237-bull-A2-retry-validator-promote.md
  - decisions/054-bear-quant-retry-validator-symmetry.md
  - observations/2026-05-11-S249-D-052-ghost-greening-finding.md
  - observations/sandwich-dev-S237-A2-promote.md
  - observations/sandwich-dev-S237-a2-promotion.md
  - packages/infrastructure/analysis/perspectives/bull_agent.py (177 LOC, baseline-identical)
  - packages/infrastructure/analysis/perspectives/bear_agent.py (334 LOC, D-054 applied)
  - packages/infrastructure/news/claude_llm_extractor.py (anthropic SDK still live at L80)
  - packages/infrastructure/news/claude_cli_news_transport.py (untracked orphan)
  - apps/_shared/use_case_builder.py (transport default still "anthropic")
  - apps/cli/test_validate_thesis.py (t7 still tests exit-4 / ANTHROPIC_API_KEY)
